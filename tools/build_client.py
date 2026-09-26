import argparse
import os
import subprocess
import sys
import tempfile

# Builds a patched game client from an original SWF in assets/flash:
#   1. copies library symbols (graphics) from other game versions, if any
#   2. recompiles the ActionScript classes found in client/<patch>/scripts
# Needs a JDK and the JPEXS FFDec command line jar (ffdec-cli.jar or ffdec.jar),
# with FFDec's lib folder next to it.
#
#   python tools/build_client.py --ffdec path/to/ffdec-cli.jar

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
FLASH_DIR = os.path.join(ROOT, "assets", "flash")
CLIENT_DIR = os.path.join(ROOT, "client")
TRANSPLANT = os.path.join(ROOT, "tools", "SwfTransplant.java")

PATCHES = {
    "1.0.0-se": {
        "base": "SocialEmpires0926bsec.swf",
        "output": "SocialEmpires1.0.0-sesec.swf",
        # (source swf, class placed next to, [classes to copy])
        "symbols": [
            ("SocialEmpires1.1.5sec.swf", "EP_BARRACKS_MC", ["EP_NewBarracksMC"]),
        ],
    },
}

def run(cmd: list) -> str:
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    output = "\n".join(l for l in result.stdout.splitlines() if not l.startswith("Picked up JAVA_TOOL_OPTIONS"))
    if output:
        print(output)
    if result.returncode != 0:
        sys.exit(f" [!] Failed: {' '.join(cmd[:4])} ...")
    return output

def build(ffdec: str, name: str) -> None:
    patch = PATCHES[name]
    base = os.path.join(FLASH_DIR, patch["base"])
    output = os.path.join(FLASH_DIR, patch["output"])
    lib = os.path.join(os.path.dirname(os.path.abspath(ffdec)), "lib", "*")
    print(f" [+] Building {patch['output']} from {patch['base']} + client/{name}")

    with tempfile.TemporaryDirectory() as tmp:
        current = base
        for i, (source, anchor, classes) in enumerate(patch["symbols"]):
            step = os.path.join(tmp, f"step{i}.swf")
            run(["java", "-Xmx3g", "-cp", lib, TRANSPLANT, current, step, anchor, os.path.join(FLASH_DIR, source)] + classes)
            current = step

        # FFDec only logs compile errors, so look for them in its output
        log = run(["java", "-Xmx3g", "-jar", ffdec, "-importScript", current, output, os.path.join(CLIENT_DIR, name)])
        if "SEVERE" in log or " on line " in log:
            os.remove(output)
            sys.exit(" [!] ActionScript compile errors, see above")
    print(f" [+] Done: assets/flash/{patch['output']}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build patched Social Empires clients.")
    parser.add_argument("--ffdec", default=os.environ.get("FFDEC_JAR"), help="path to ffdec-cli.jar (or set FFDEC_JAR)")
    parser.add_argument("patch", nargs="*", default=list(PATCHES), help="patches to build (default: all)")
    args = parser.parse_args()
    if not args.ffdec:
        sys.exit("FFDec jar not given: use --ffdec or set FFDEC_JAR")
    for patch in args.patch:
        build(args.ffdec, patch)
