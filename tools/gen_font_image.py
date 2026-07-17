"""Generate a font image using shanghai.ttf for use as bitmap font.

Each glyph is cropped to its visible rect. Layout: yellow separator,
then char, then yellow separator, then char... ends with yellow.
No extra empty space above or below any glyph.
"""

from PIL import Image, ImageDraw, ImageFont
import os

FONT_PATH = "assets/fonts/shanghai.ttf"
OUT_DIR = "assets/generated"
OUT_FILE = "font.png"
FONT_SIZE = 32
GAP_COLOR = (255, 255, 0, 255)

CHARS = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@,.;/:-"


def main():
    font = ImageFont.truetype(FONT_PATH, FONT_SIZE)

    glyphs = []
    for ch in CHARS:
        glyph = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
        draw = ImageDraw.Draw(glyph)
        draw.text((0, 0), ch, font=font, fill=(255, 255, 255, 255))
        bbox = glyph.getbbox()
        if bbox:
            gw = max(8, bbox[2] - bbox[0])
            gh = bbox[3] - bbox[1]
            crop = glyph.crop((bbox[0], bbox[1], bbox[0] + gw, bbox[1] + gh))
        else:
            gw, gh, crop = 8, 8, Image.new("RGBA", (8, 8), (0, 0, 0, 0))
        glyphs.append(crop)

    max_h = max(g.height for g in glyphs)
    total_w = 1 + sum(g.width + 1 for g in glyphs)
    sheet = Image.new("RGBA", (total_w, max_h), (0, 0, 0, 0))

    for dy in range(max_h):
        sheet.putpixel((0, dy), GAP_COLOR)
    x = 1
    for i, g in enumerate(glyphs):
        y = (max_h - g.height) // 2
        sheet.paste(g, (x, y), g)
        x += g.width
        for dy in range(max_h):
            sheet.putpixel((x, dy), GAP_COLOR)
        x += 1

    os.makedirs(OUT_DIR, exist_ok=True)
    sheet.save(f"{OUT_DIR}/{OUT_FILE}")
    print(f"Saved {OUT_DIR}/{OUT_FILE} ({sheet.width}x{sheet.height}, {len(CHARS)} chars)")
