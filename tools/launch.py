#!/usr/bin/env python3
"""Run rasterize_tiles.py then launch RetroArch for the Mahjong ROM."""

from __future__ import annotations

import subprocess
import sys
from datetime import datetime
from pathlib import Path

RETROARCH_PATH = "/Applications/RetroArch.app/Contents/MacOS/RetroArch"
CORE_PATH = Path("~/Library/Application Support/RetroArch/cores/lutro_libretro.dylib").expanduser()
LOG_PATH = "retroarch.log"


def main() -> int:
    repo_root = Path(__file__).resolve().parent.parent
    log_path = repo_root / LOG_PATH

    if not Path(RETROARCH_PATH).exists():
        print(f"RetroArch executable not found at {RETROARCH_PATH}", file=sys.stderr)
        return 1

    if not CORE_PATH.exists():
        print(f"RetroArch core not found at {CORE_PATH}", file=sys.stderr)
        return 1

    rasterize = repo_root / "tools" / "rasterize_tiles.py"
    if rasterize.exists():
        print("Running rasterize_tiles.py…")
        subprocess.run([sys.executable, str(rasterize)], cwd=repo_root, check=True)
    else:
        print(f"rasterize_tiles.py not found at {rasterize}", file=sys.stderr)

    command = [RETROARCH_PATH, "-L", str(CORE_PATH), str(repo_root)+"/src", "-vvvv"]

    with log_path.open("w", encoding="utf-8") as log_file:
        log_file.write(f"\n=== Launching RetroArch at {datetime.now().isoformat()} ===\n")
        process = subprocess.Popen(
            command,
            cwd=repo_root,
            stdout=log_file,
            stderr=subprocess.STDOUT,
        )

    print(f"Started RetroArch with PID {process.pid}")
    print(f"Logs are being written to {log_path}")
    return process.wait()


if __name__ == "__main__":
    sys.exit(main())
