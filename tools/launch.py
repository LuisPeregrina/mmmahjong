#!/usr/bin/env python3
"""Launch RetroArch for the Mahjong ROM from the repository root."""

from __future__ import annotations

import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

RETROARCH_PATH = "/Applications/RetroArch.app/Contents/MacOS/RetroArch"
CORE_PATH = os.path.expanduser("~/Library/Application Support/RetroArch/cores/lutro_libretro.dylib")
ROM_PATH = "out/mahjong.zip"
LOG_PATH = "retroarch.log"


def main() -> int:
    repo_root = Path(__file__).resolve().parent.parent
    rom_path = repo_root / ROM_PATH
    log_path = repo_root / LOG_PATH

    if not Path(RETROARCH_PATH).exists():
        print(f"RetroArch executable not found at {RETROARCH_PATH}", file=sys.stderr)
        return 1

    if not Path(CORE_PATH).exists():
        print(f"RetroArch core not found at {CORE_PATH}", file=sys.stderr)
        return 1

    if not rom_path.exists():
        print(f"ROM not found at {rom_path}", file=sys.stderr)
        return 1

    command = [RETROARCH_PATH, "-L", CORE_PATH, str(rom_path.relative_to(repo_root)), "-v"]

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
