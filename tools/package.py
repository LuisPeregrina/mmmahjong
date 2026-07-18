"""Package game into .lutro zipfile for Lutro."""

import argparse
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_ZIP = ROOT / "out" / "mahjong.lutro"
SRC = ROOT / "src"
GENERATED_DIR = ROOT / "assets" / "generated"
ASSETS = [
    GENERATED_DIR / "tiles.png",
    GENERATED_DIR / "font.png",
    ROOT / "assets" / "music" / "Lotus Pond - Loop.ogg",
    ROOT / "assets" / "music" / "Dragon Dance - Loop.ogg",
    ROOT / "assets" / "sounds" / "ceramic.wav",
]

BUILD_DIR = ROOT / "out" / "build"
if BUILD_DIR.exists():
    shutil.rmtree(BUILD_DIR)

BUILD_DIR.mkdir(parents=True, exist_ok=True)
(BUILD_DIR / "assets" / "generated").mkdir(parents=True, exist_ok=True)

for fname in SRC.iterdir():
    if fname.is_file() and fname.suffix == ".lua":
        shutil.copy2(fname, BUILD_DIR / fname.name)

parser = argparse.ArgumentParser()
parser.add_argument("--compile", action="store_true", help="precompile .lua to .luac with luac5.1")
args = parser.parse_args()

if args.compile:
    for f in list(BUILD_DIR.iterdir()):
        if f.suffix == ".lua":
            luac = BUILD_DIR / (f.stem + ".luac")
            subprocess.run(["luac5.1", "-o", str(luac), str(f)], check=True)
            f.unlink()

for asset in ASSETS:
    if not asset.exists():
        print(f"Generating missing asset: {asset.relative_to(ROOT)}")
        if asset.parent == GENERATED_DIR:
            generator = ROOT / ("tools/gen_font_image.py" if asset.name == "font.png" else "tools/rasterize_tiles.py")
            subprocess.run([sys.executable, str(generator)], cwd=ROOT, check=True)

    if not asset.exists():
        print(f"Skip missing asset: {asset.relative_to(ROOT)}")
        continue

    dst = BUILD_DIR / asset.relative_to(ROOT)
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(asset, dst)

OUT_ZIP.parent.mkdir(parents=True, exist_ok=True)
if OUT_ZIP.exists():
    OUT_ZIP.unlink()

with zipfile.ZipFile(OUT_ZIP, "w", zipfile.ZIP_DEFLATED) as zf:
    for path in BUILD_DIR.rglob("*"):
        if path.is_file():
            arcname = path.relative_to(BUILD_DIR).as_posix()
            zf.write(path, arcname)

shutil.rmtree(BUILD_DIR)

size = OUT_ZIP.stat().st_size
print(f"Package: {OUT_ZIP.relative_to(ROOT)} ({size} bytes)")
with zipfile.ZipFile(OUT_ZIP, "r") as zf:
    for info in zf.infolist():
        print(f"  {info.filename}  ({info.file_size} bytes, compressed {info.compress_size})")
