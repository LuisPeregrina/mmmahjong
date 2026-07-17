"""Generate a font image using ChineseBrush.ttf for use as bitmap font."""

from PIL import Image, ImageDraw, ImageFont
import os

FONT_PATH = "assets/fonts/shanghai.ttf"
OUT_DIR = "assets/generated"
OUT_FILE = "font.png"
FONT_SIZE = 32
GLYPH_H = 32
GAP = 1

CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@,.;/:-"


def main():
    font = ImageFont.truetype(FONT_PATH, FONT_SIZE)

    glyphs = []
    for ch in CHARS:
        # A transparent column separates glyphs for love.graphics.newImageFont.
        glyph = Image.new("RGBA", (256, GLYPH_H), (0, 0, 0, 0))
        draw = ImageDraw.Draw(glyph)
        draw.text((0, 0), ch, font=font, fill=(255, 255, 255, 255))
        bbox = glyph.getbbox()
        width = max(8, bbox[2]) if bbox else 8
        glyphs.append(glyph.crop((0, 0, width, GLYPH_H)))

    sheet_w = sum(glyph.width for glyph in glyphs) + (len(glyphs) - 1) * GAP
    sheet = Image.new("RGBA", (sheet_w, GLYPH_H), (0, 0, 0, 0))
    x = 0
    for glyph in glyphs:
        sheet.paste(glyph, (x, 0), glyph)
        x += glyph.width + GAP

    os.makedirs(OUT_DIR, exist_ok=True)
    sheet.save(f"{OUT_DIR}/{OUT_FILE}")
    print(f"Saved {OUT_DIR}/{OUT_FILE} ({sheet.width}x{sheet.height}, {len(CHARS)} chars)")


if __name__ == "__main__":
    main()
