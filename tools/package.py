"""Package game into .lutro zipfile for Lutro."""

import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_ZIP = ROOT / "out" / "mahjong.zip"
SRC = ROOT / "src"
GENERATED_DIR = ROOT / "assets" / "generated"
ASSETS = [GENERATED_DIR / "tiles.png"]

BUILD_DIR = ROOT / "out" / "build"
if BUILD_DIR.exists():
    shutil.rmtree(BUILD_DIR)

BUILD_DIR.mkdir(parents=True, exist_ok=True)
(BUILD_DIR / "assets" / "generated").mkdir(parents=True, exist_ok=True)

for fname in SRC.iterdir():
    if fname.is_file() and fname.suffix == ".lua":
        shutil.copy2(fname, BUILD_DIR / fname.name)

for asset in ASSETS:
    if not asset.exists():
        print(f"Generating missing asset: {asset.relative_to(ROOT)}")
        rasterizer = ROOT / "tools" / "rasterize_tiles.py"
        subprocess.run([sys.executable, str(rasterizer)], cwd=ROOT, check=True)

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

for cleanup_path in [GENERATED_DIR / "tiles.png", GENERATED_DIR / "tiles.csv"]:
    if cleanup_path.exists():
        cleanup_path.unlink()
