"""Rasterize SVG tile assets to PNG sprite sheet for Lutro."""

import cairosvg
import os
import math
from PIL import Image
import io

TILE_W, TILE_H = 48, 60

# Face inset within tile viewBox "0 0 50.3 63.5":
# white face rect is M0 10.6h39.7v52.9H0z → top=10.6, left=(50.3-39.7)/2=5.3, w=39.7, h=52.9
FACE_TOP  = int(10.6 / 63.5 * TILE_H + 0.5)   # 10
FACE_LEFT = int(5.3 / 60.3 * TILE_W + 0.5)    # 5
FACE_W    = TILE_W - FACE_LEFT * 4        # 38
FACE_H    = TILE_H - FACE_TOP             # 50

# SVG declared dimensions (width/height attributes, not viewBox)
BLANK_SVG_W, BLANK_SVG_H = 190, 240
FACE_SVG_W, FACE_SVG_H = 150, 200
OUT = "assets/generated"

SUIT_COLORS = {
    "bamboo": "green",
    "dot":    "blue",
    "character": "fuiscia",
    "wind":   "yellow",
    "dragon": "pink",
    "season": "gray",
    "flower": "gray",
}

BLANK_SVG_CACHE = {}

def get_blank_svg(suit):
    if suit not in BLANK_SVG_CACHE:
        color = SUIT_COLORS[suit]
        path = f"assets/colors/{color}/02.svg"
        with open(path) as f:
            BLANK_SVG_CACHE[suit] = f.read()
    return BLANK_SVG_CACHE[suit]

def svg_to_png(svg_str, target_w, target_h, svg_w=BLANK_SVG_W, svg_h=BLANK_SVG_H):
    scale = min(target_w / svg_w, target_h / svg_h)
    png_data = cairosvg.svg2png(bytestring=svg_str.encode(), scale=scale)
    img = Image.open(io.BytesIO(png_data)).convert("RGBA")
    if img.size == (target_w, target_h):
        return img
    img2 = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    ox = (target_w - img.width) // 2
    oy = (target_h - img.height) // 2
    img2.paste(img, (ox, oy), img)
    return img2

def render_tile(suit, type_name, face_file):
    blank_svg = get_blank_svg(suit)
    blank = svg_to_png(blank_svg, TILE_W, TILE_H)

    face_path = f"assets/tiles/{suit}/{face_file}"
    with open(face_path) as f:
        face_svg = f.read()

    face_data = cairosvg.svg2png(bytestring=face_svg.encode(), scale=min(FACE_W / FACE_SVG_W, FACE_H / FACE_SVG_H))
    face_img = Image.open(io.BytesIO(face_data)).convert("RGBA")

    if face_img.size != (FACE_W, FACE_H):
        f2 = Image.new("RGBA", (FACE_W, FACE_H), (0, 0, 0, 0))
        ox = (FACE_W - face_img.width) // 2
        oy = (FACE_H - face_img.height) // 2
        f2.paste(face_img, (ox, oy), face_img)
        face_img = f2

    blank.paste(face_img, (FACE_LEFT, FACE_TOP), face_img)
    return blank


TILE_DEFS = []

for num in range(1, 10):
    TILE_DEFS.append(("bamboo", f"bamboo_{num}", f"{num:02d}.svg"))
for num in range(1, 10):
    TILE_DEFS.append(("dot", f"dot_{num}", f"{num:02d}.svg"))
for num in range(1, 10):
    TILE_DEFS.append(("character", f"char_{num}", f"{num:02d}.svg"))

for name in ["east", "south", "west", "north"]:
    TILE_DEFS.append(("wind", f"wind_{name}", f"{name}.svg"))

DRAGON_FACES = [("red", "01.svg"), ("green", "02.svg"), ("white", "03.svg")]
for dname, dfile in DRAGON_FACES:
    TILE_DEFS.append(("dragon", f"dragon_{dname}", dfile))

for num in range(1, 5):
    TILE_DEFS.append(("season", f"season_{num}", f"{num:02d}.svg"))
for num in range(1, 5):
    TILE_DEFS.append(("flower", f"flower_{num}", f"{num:02d}.svg"))

assert len(TILE_DEFS) == 42, f"Expected 42 tile types, got {len(TILE_DEFS)}"

os.makedirs(OUT, exist_ok=True)

images = []
for suit, type_name, face_file in TILE_DEFS:
    print(f"  {type_name}")
    img = render_tile(suit, type_name, face_file)
    images.append(img)

cols = 12
rows = math.ceil(len(images) / cols)
sheet = Image.new("RGBA", (cols * TILE_W, rows * TILE_H), (0, 0, 0, 0))
for i, img in enumerate(images):
    r = i // cols
    c = i % cols
    sheet.paste(img, (c * TILE_W, r * TILE_H), img)

sheet.save(f"{OUT}/tiles.png")

with open(f"{OUT}/tiles.csv", "w") as f:
    i = 0
    for suit, type_name, face_file in TILE_DEFS:
        r = i // cols
        c = i % cols
        x = c * TILE_W
        y = r * TILE_H
        f.write(f"{type_name},{suit},{x},{y},{TILE_W},{TILE_H}\n")
        i += 1

print(f"\nDone: {len(images)} tiles in {OUT}/tiles.png ({sheet.width}x{sheet.height})")
