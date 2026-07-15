# Miyoo Mahjong Solitaire

A mouse-free, retro-optimized Mahjong Solitaire game written in Python 2.7 and Pygame, specifically configured for the **Miyoo Mini** (and Miyoo Mini Plus) running OnionOS.

---

## 🎮 Game Overview

Mahjong Solitaire is a classic tile-matching game. While traditionally played with a mouse to click on matching tiles, this version uses a **smart grid cursor system** designed explicitly for a D-pad controller layout, making selection snappy and natural without a pointer.

### Screen & Engine Constraints
* **Platform:** Miyoo Mini & Miyoo Mini Plus
* **Resolution:** 640 x 480 (Standard 4:3 display ratio)
* **Language:** Python 2.7
* **Framework:** Pygame (1.9.x native build for OnionOS)

---

## 🕹️ Controls (Miyoo Mini Mapping)

Since the Miyoo Mini lacks a mouse, all actions are driven by keyboard event mappings that OnionOS translates from the physical handheld buttons:

| Physical Button | Keyboard Event (Pygame Key) | Action |
|:---|:---|:---|
| **D-Pad** | `K_UP` / `K_DOWN` / `K_LEFT` / `K_RIGHT` | Move Tile Cursor (Smart Nearest-Neighbor jump) |
| **A Button** | `K_LCTRL` (or Space/Return) | Select / Match Tile |
| **B Button** | `K_LALT` (or Backspace) | Deselect / Cancel |
| **X Button** | `K_LSHIFT` | Undo Last Move |
| **Y Button** | `K_SPACE` | Shuffle remaining tiles (when stuck) |
| **L/R Buttons** | `K_e` / `K_t` | Cycle through board styles |
| **Menu Button** | `K_ESCAPE` | Exit to OnionOS |

---

## 🛠️ Smart D-Pad Navigation Engine

Implementing a tile-matching game without a mouse requires an intuitive cursor pathing logic. Because Mahjong Solitaire uses layered 3D tiles (often stacked up to 5 levels high), simple grid increments will feel clunky. 

This game uses a **Raycast Distance-Weighted Pathing** algorithm to determine where the cursor goes when you press a direction:

1. **Directional Masking:** If you press `RIGHT`, the game filters out all tiles whose X-coordinate is less than or equal to the current tile.
2. **Euclidean Distance Penalty:** It calculates the distance ($d$) from the current tile to all valid candidate tiles in that direction:
   $$d = \sqrt{(x_2 - x_1)^2 + \gamma(y_2 - y_1)^2 + \lambda(z_2 - z_1)^2}$$
3. **Weight Bias ($\gamma$ and $\lambda$):** A penalty multiplier is added to height differences ($z$) and perpendicular directions ($y$ when moving horizontally) to prioritize logical linear movements on the same plane.
4. **Auto-Jump:** The cursor jumps instantly to the best-weighted candidate tile.

---

## 📂 Project Structure

```text
miyoo-mahjong/
├── app/
│   ├── main.py            # Main game loop (640x480 surface initialization)
│   ├── board.py           # 3D layout math & matching validation
│   ├── cursor.py          # D-Pad raycast navigation engine
│   ├── assets/
│   │   ├── tiles/         # Optimized 32x40 tile assets (PNG-8)
│   │   ├── sfx/           # Low-bitrate matching and error sound effects (WAV)
│   │   └── fonts/         # TrueType pixel fonts for low-res readability
│   └── config.json        # Key mapping and screen settings
├── dist/                  # Output package ready for OnionOS
│   └── App/
│       └── Mahjong/
│           ├── launch.sh  # OnionOS execution shell script
│           └── icon.png   # 80x80 app icon
├── README.md
└── requirements.txt
