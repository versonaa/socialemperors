import com.jpexs.decompiler.flash.SWF;
import com.jpexs.decompiler.flash.abc.ABC;
import com.jpexs.decompiler.flash.abc.avm2.parser.script.AbcIndexing;
import com.jpexs.decompiler.flash.abc.avm2.parser.script.ActionScript3Parser;
import com.jpexs.decompiler.flash.tags.ABCContainerTag;
import com.jpexs.decompiler.flash.tags.SymbolClassTag;
import com.jpexs.decompiler.flash.tags.Tag;
import com.jpexs.decompiler.flash.tags.base.CharacterIdTag;
import com.jpexs.decompiler.flash.tags.base.CharacterTag;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Copies library symbols (with all the graphics they use) from one SWF into
 * another and links them to a new, empty dynamic MovieClip class.
 *
 * Only the copied root symbol gets a class. Nested symbols are copied as plain
 * graphics, because the same class name can point to different graphics in
 * different game versions (e.g. BotonPutInStorage_MC). Named children stay
 * reachable as dynamic properties, like in any classless MovieClip.
 *
 * The symbols and class are placed next to an existing class of the target
 * (anchor), so they load in the same frame and ABC.
 *
 * Usage (classpath: FFDec's lib folder):
 *   java -cp "ffdec/lib/*" SwfTransplant.java target.swf output.swf anchorClass source.swf Class [Class...]
 */
public class SwfTransplant {

    public static void main(String[] args) throws Exception {
        if (args.length < 5) {
            System.err.println("usage: SwfTransplant target.swf output.swf anchorClass source.swf Class [Class...]");
            System.exit(2);
        }
        SWF target = open(args[0]);
        String anchorClass = args[2];
        SWF source = open(args[3]);

        SymbolClassTag symbolClass = findSymbolClass(target, anchorClass);
        ABCContainerTag abcContainer = findAbc(target, anchorClass);

        for (int i = 4; i < args.length; i++) {
            String className = args[i];
            if (findCharacter(target, className) != null) {
                fail("class " + className + " already exists in " + args[0]);
            }
            CharacterTag root = findCharacter(source, className);
            if (root == null) {
                fail("class " + className + " not found in " + args[3]);
            }
            int newId = copyWithDependencies(source, root, target, target.indexOfTag(symbolClass));
            symbolClass.tags.add(newId);
            symbolClass.names.add(className);
            symbolClass.setModified(true);
            addEmptyClass(target, abcContainer, className);
            System.out.println(" * Transplanted " + className + " (" + args[3] + " #" + root.getCharacterId() + " -> #" + newId + ")");
        }

        target.assignClassesToSymbols();
        target.clearAllCache();
        try (OutputStream os = new BufferedOutputStream(new FileOutputStream(args[1]))) {
            target.saveTo(os);
        }
    }

    // Copies root and every character it needs, before position. Returns root's new id.
    private static int copyWithDependencies(SWF source, CharacterTag root, SWF target, int position) throws Exception {
        Set<Integer> needed = new LinkedHashSet<>();
        root.getNeededCharactersDeep(needed, new LinkedHashSet<>());
        needed.add(root.getCharacterId());

        Map<Integer, Integer> newIds = new HashMap<>();
        List<Tag> copies = new ArrayList<>();
        int nextId = target.getNextCharacterId();
        // Keep the source order so every character is defined before it is used.
        for (Tag tag : source.getTags()) {
            if (!(tag instanceof CharacterTag) || !needed.contains(((CharacterTag) tag).getCharacterId())) {
                continue;
            }
            CharacterTag copy = (CharacterTag) tag.cloneTag();
            copy.setSwf(target, true);
            copy.setTimelined(target);
            newIds.put(copy.getCharacterId(), nextId);
            copy.setCharacterId(nextId++);
            copies.add(copy);
            // Tags attached to the character (e.g. DefineFontName, DefineScalingGrid)
            for (CharacterIdTag attached : source.getCharacterIdTags(((CharacterTag) tag).getCharacterId())) {
                if (attached instanceof Tag && !(attached instanceof CharacterTag) && !(attached instanceof SymbolClassTag)) {
                    Tag attachedCopy = ((Tag) attached).cloneTag();
                    attachedCopy.setSwf(target, true);
                    attachedCopy.setTimelined(target);
                    copies.add(attachedCopy);
                }
            }
        }
        for (Tag copy : copies) {
            for (Map.Entry<Integer, Integer> e : newIds.entrySet()) {
                copy.replaceCharacter(e.getKey(), e.getValue());
            }
            if (copy instanceof CharacterIdTag && !(copy instanceof CharacterTag)) {
                CharacterIdTag attached = (CharacterIdTag) copy;
                attached.setCharacterId(newIds.get(attached.getCharacterId()));
            }
            copy.setModified(true);
            target.addTag(position++, copy);
        }
        target.updateCharacters();
        target.computeDependentCharacters();
        return newIds.get(root.getCharacterId());
    }

    private static void addEmptyClass(SWF swf, ABCContainerTag container, String className) throws Exception {
        String script = "package {"
                + " import flash.display.MovieClip;"
                + " public dynamic class " + className + " extends MovieClip {"
                + "  public function " + className + "() { super(); }"
                + " }"
                + "}";
        AbcIndexing abcIndex = swf.getAbcIndex();
        ABC abc = container.getABC();
        abcIndex.selectAbc(abc);
        new ActionScript3Parser(abcIndex).addScript(script, className, 0, 0, swf.getDocumentClass(), abc);
        ((Tag) container).setModified(true);
    }

    private static CharacterTag findCharacter(SWF swf, String className) {
        for (CharacterTag ct : swf.getCharacters(false).values()) {
            if (ct.getClassNames().contains(className)) {
                return ct;
            }
        }
        return null;
    }

    private static SymbolClassTag findSymbolClass(SWF swf, String className) {
        for (Tag t : swf.getTags()) {
            if (t instanceof SymbolClassTag && ((SymbolClassTag) t).names.contains(className)) {
                return (SymbolClassTag) t;
            }
        }
        fail("anchor class " + className + " has no SymbolClass tag");
        return null;
    }

    private static ABCContainerTag findAbc(SWF swf, String className) {
        for (ABCContainerTag c : swf.getAbcList()) {
            if (c.getABC().findClassByName(className) >= 0) {
                return c;
            }
        }
        fail("anchor class " + className + " not found in any ABC");
        return null;
    }

    private static SWF open(String path) throws Exception {
        try (BufferedInputStream is = new BufferedInputStream(new FileInputStream(path))) {
            return new SWF(is, false);
        }
    }

    private static void fail(String message) {
        System.err.println("error: " + message);
        System.exit(1);
    }
}
