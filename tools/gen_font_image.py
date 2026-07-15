"""Generate a font image using ChineseBrush.ttf for use as bitmap font."""

from PIL import Image, ImageDraw, ImageFont
import os

FONT_PATH = "assets/fonts/shanghai.ttf"
OUT_DIR = "generated"
OUT_FILE = "font_chinese.png"
FONT_SIZE = 40
CHAR_H = 40
GAP = 1

CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@,.;/"


def main():
    font = ImageFont.truetype(FONT_PATH, FONT_SIZE)

    char_imgs = []
    for ch in CHARS:
        tmp = Image.new("RGBA", (256, CHAR_H), (0, 0, 0, 0))
        tmp_draw = ImageDraw.Draw(tmp)
        tmp_draw.text((0, 0), ch, font=font, fill=(255, 255, 255, 255))

        bbox = tmp.getbbox()
        if bbox:
            char_img = tmp.crop(bbox)
            cw = bbox[2] - bbox[0]
        else:
            char_img = Image.new("RGBA", (1, CHAR_H), (0, 0, 0, 0))
            cw = 1
        char_imgs.append((char_img, cw))

    total_w = sum(cw for _, cw in char_imgs) + (len(CHARS) - 1) * GAP
    sheet = Image.new("RGBA", (total_w, CHAR_H), (0, 0, 0, 0))

    x = 0
    for img, cw in char_imgs:
        sheet.paste(img, (x, 0), img)
        x += cw + GAP

    os.makedirs(OUT_DIR, exist_ok=True)
    sheet.save(f"{OUT_DIR}/{OUT_FILE}")
    print(f"Saved {OUT_DIR}/{OUT_FILE} ({sheet.width}x{sheet.height}, {len(CHARS)} chars)")


if __name__ == "__main__":
    main()
