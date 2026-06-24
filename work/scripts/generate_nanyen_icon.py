from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "outputs"
SIZE = 1024


def font(size: int) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Black.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


def vertical_gradient(size: int, stops: list[tuple[float, tuple[int, int, int]]]) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        t = y / (size - 1)
        for i in range(len(stops) - 1):
            t0, c0 = stops[i]
            t1, c1 = stops[i + 1]
            if t0 <= t <= t1:
                local = (t - t0) / (t1 - t0)
                color = tuple(int(c0[j] + (c1[j] - c0[j]) * local) for j in range(3))
                for x in range(size):
                    px[x, y] = color
                break
    return img


def rounded_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def draw_star(draw: ImageDraw.ImageDraw, cx: int, cy: int, r1: int, r2: int, fill: tuple[int, int, int, int]) -> None:
    points = []
    for i in range(10):
        angle = -math.pi / 2 + i * math.pi / 5
        radius = r1 if i % 2 == 0 else r2
        points.append((cx + math.cos(angle) * radius, cy + math.sin(angle) * radius))
    draw.polygon(points, fill=fill)


def text_mask(text: str, fnt: ImageFont.FreeTypeFont, offset: tuple[int, int] = (0, 0)) -> Image.Image:
    mask = Image.new("L", (SIZE, SIZE), 0)
    draw = ImageDraw.Draw(mask)
    bbox = draw.textbbox((0, 0), text, font=fnt, stroke_width=0)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    x = (SIZE - w) // 2 + offset[0]
    y = (SIZE - h) // 2 - 46 + offset[1]
    draw.text((x, y), text, font=fnt, fill=255)
    return mask


def make_icon() -> Image.Image:
    base = vertical_gradient(
        SIZE,
        [
            (0.0, (255, 246, 210)),
            (0.32, (108, 239, 255)),
            (0.66, (255, 132, 211)),
            (1.0, (255, 238, 118)),
        ],
    ).convert("RGBA")

    overlay = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)

    # Soft 80s sun/grid echoes, kept subtle so the icon stays readable.
    for i in range(11):
        y = 650 + i * 38
        alpha = max(0, 78 - i * 5)
        od.line((110, y, 914, y), fill=(255, 255, 255, alpha), width=5)
    for i in range(-4, 5):
        x = 512 + i * 82
        od.line((x, 640, 512 + i * 26, 950), fill=(111, 32, 140, 42), width=5)

    # Yen coin behind the letter.
    od.ellipse((585, 580, 880, 875), fill=(255, 224, 70, 238), outline=(126, 64, 160, 230), width=18)
    od.ellipse((620, 615, 845, 840), outline=(255, 255, 255, 190), width=10)
    yen_font = font(190)
    yen_bbox = od.textbbox((0, 0), "¥", font=yen_font, stroke_width=5)
    yen_w = yen_bbox[2] - yen_bbox[0]
    yen_h = yen_bbox[3] - yen_bbox[1]
    od.text(
        (732 - yen_w // 2, 715 - yen_h // 2),
        "¥",
        font=yen_font,
        fill=(116, 43, 145, 235),
        stroke_width=5,
        stroke_fill=(255, 255, 255, 220),
    )

    # Comic sparkles.
    for cx, cy, r1, r2, color in [
        (180, 205, 62, 24, (255, 255, 255, 235)),
        (820, 210, 50, 18, (255, 255, 255, 220)),
        (220, 795, 44, 16, (255, 255, 255, 210)),
        (790, 505, 30, 11, (255, 255, 255, 200)),
    ]:
        draw_star(od, cx, cy, r1, r2, color)

    base = Image.alpha_composite(base, overlay)

    # Large metallic N.
    n_font = font(650)
    n_mask = text_mask("N", n_font, offset=(-12, -4))

    shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.bitmap((34, 52), n_mask, fill=(95, 36, 128, 150))
    shadow = shadow.filter(ImageFilter.GaussianBlur(9))
    base = Image.alpha_composite(base, shadow)

    stroke_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    st = ImageDraw.Draw(stroke_layer)
    bbox = ImageDraw.Draw(Image.new("L", (SIZE, SIZE))).textbbox((0, 0), "N", font=n_font, stroke_width=0)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = (SIZE - tw) // 2 - 12
    ty = (SIZE - th) // 2 - 50
    st.text((tx, ty), "N", font=n_font, fill=(0, 0, 0, 0), stroke_width=46, stroke_fill=(129, 40, 151, 245))
    st.text((tx, ty), "N", font=n_font, fill=(0, 0, 0, 0), stroke_width=29, stroke_fill=(255, 93, 179, 255))
    st.text((tx, ty), "N", font=n_font, fill=(0, 0, 0, 0), stroke_width=15, stroke_fill=(255, 255, 255, 250))
    base = Image.alpha_composite(base, stroke_layer)

    metal = vertical_gradient(
        SIZE,
        [
            (0.00, (255, 255, 255)),
            (0.18, (165, 220, 255)),
            (0.36, (255, 255, 255)),
            (0.52, (115, 136, 169)),
            (0.70, (235, 248, 255)),
            (1.00, (128, 88, 170)),
        ],
    ).convert("RGBA")
    metal.putalpha(n_mask)
    base = Image.alpha_composite(base, metal)

    highlights = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    hd = ImageDraw.Draw(highlights)
    hd.line((276, 295, 760, 255), fill=(255, 255, 255, 190), width=18)
    hd.line((310, 418, 735, 382), fill=(255, 255, 255, 115), width=10)
    highlights.putalpha(Image.composite(highlights.getchannel("A"), Image.new("L", (SIZE, SIZE), 0), n_mask))
    base = Image.alpha_composite(base, highlights)

    # Gloss over the full icon.
    gloss = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gd = ImageDraw.Draw(gloss)
    gd.pieslice((-120, -330, 1140, 720), 0, 180, fill=(255, 255, 255, 54))
    base = Image.alpha_composite(base, gloss)

    return base.convert("RGB")


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    icon = make_icon()
    icon.save(OUT / "nanyen-app-icon-1024.png")
    icon.resize((512, 512), Image.Resampling.LANCZOS).save(OUT / "nanyen-app-icon-512.png")
    icon.resize((180, 180), Image.Resampling.LANCZOS).save(OUT / "nanyen-app-icon-180.png")
