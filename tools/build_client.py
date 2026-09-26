import argparse
import os
import subprocess
import sys

# Builds a patched game client: takes an original SWF from assets/flash and
# recompiles the ActionScript classes found in client/<patch>/scripts into it.
# Needs Java and the JPEXS FFDec command line jar (ffdec-cli.jar or ffdec.jar).
#
#   python tools/build_client.py --ffdec path/to/ffdec-cli.jar

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
FLASH_DIR = os.path.join(ROOT, "assets", "flash")
CLIENT_DIR = os.path.join(ROOT, "client")

# patch folder -> (original swf, output swf)
PATCHES = {
    "0926-se": ("SocialEmpires0926bsec.swf", "SocialEmpires0926-sesec.swf"),
}

def build(ffdec: str, patch: str) -> None:
    base, output = PATCHES[patch]
    scripts = os.path.join(CLIENT_DIR, patch)
    cmd = ["java", "-Xmx3g", "-jar", ffdec, "-importScript",
           os.path.join(FLASH_DIR, base), os.path.join(FLASH_DIR, output), scripts]
    print(f" [+] Building {output} from {base} + client/{patch}")
    subprocess.run(cmd, check=True)
    print(f" [+] Done: assets/flash/{output}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build patched Social Empires clients.")
    parser.add_argument("--ffdec", default=os.environ.get("FFDEC_JAR"), help="path to ffdec-cli.jar (or set FFDEC_JAR)")
    parser.add_argument("patch", nargs="*", default=list(PATCHES), help="patches to build (default: all)")
    args = parser.parse_args()
    if not args.ffdec:
        sys.exit("FFDec jar not given: use --ffdec or set FFDEC_JAR")
    for patch in args.patch:
        build(args.ffdec, patch)
