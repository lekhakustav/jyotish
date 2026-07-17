#!/usr/bin/env python3
"""
Generate store screenshots for Jyotish Baje (iOS App Store + Google Play).

Design: 3-stop gradient background, brand Fraunces/Inter type, feature tag pill,
radial glow and QR-dot motif, and a realistic device mockup — iPhone geometry
(continuous large corner radius + proportional Dynamic Island) for iOS,
punch-hole Android frame for Play.

  python3 scripts/generate_appstore_screenshots.py            # iOS 1320x2868
  python3 scripts/generate_appstore_screenshots.py --platform android  # 1080x2160
"""

import argparse
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SRC = ROOT / "marketing/media/appstore-private-kundli-source"

FONT_DIR = ROOT / "Jyotish/Fonts"
FRAUNCES_SEMIBOLD = str(FONT_DIR / "Fraunces-SemiBold.ttf")
INTER_REGULAR = str(FONT_DIR / "Inter-Regular.ttf")
INTER_SEMIBOLD = str(FONT_DIR / "Inter-SemiBold.ttf")

# ── Platform geometry ─────────────────────────────────────────────────
# iPhone: outer corner radius ~14% of device width, proportional island.
# Android: ~11% radius, centered punch-hole camera.
PLATFORMS = {
    "ios": {
        "canvas": (1320, 2868),
        "out_dir": ROOT / "marketing/media/appstore-private-kundli-2026-07-16",
        "phone_w": 1040,
        "bezel": 16,
        "corner_pct": 0.145,
        "overhang": 90,
        "tag_size": 44, "h1_size": 100, "h2_size": 62,
        "tag_y": 200,
        "notch": "island",
    },
    "android": {
        "canvas": (1080, 2160),
        "out_dir": ROOT / "marketing/media/playstore-private-kundli-2026-07-17",
        "phone_w": 800,
        "bezel": 12,
        "corner_pct": 0.11,
        "overhang": 70,
        "tag_size": 34, "h1_size": 74, "h2_size": 47,
        "tag_y": 130,
        "notch": "punch",
    },
}

# ── Palettes: (top, mid, bottom, accent) ──────────────────────────────
PALETTES = [
    ((74, 20, 2),  (146, 64, 8),  (222, 122, 28), (255, 196, 110)),   # 0 saffron dawn
    ((16, 8, 52),  (58, 24, 110), (124, 58, 168), (196, 160, 255)),   # 1 indigo night
    ((3, 34, 34),  (10, 84, 74),  (24, 142, 116), (134, 230, 196)),   # 2 teal jade
    ((56, 6, 22),  (122, 20, 44), (186, 52, 74),  (255, 168, 178)),   # 3 sindoor wine
]

SLIDES = [
    {"f": "05-family-native.png",             "tag": "MADE FOR NEPAL",   "h1": "Private Kundli Sharing", "h2": "for Nepali Families",     "p": 2},
    {"f": "00-family-qr-native.png",          "tag": "TRUSTED SHARING",  "h1": "Share Your Kundli",      "h2": "Only When You Choose",    "p": 0},
    {"f": "06-family-kundali-native.png",     "tag": "ONE SCAN",         "h1": "Saved Without",          "h2": "Retyping a Thing",        "p": 3},
    {"f": "01-home-native.png",               "tag": "RELIGIOUS",        "h1": "Nepali Religious Life",  "h2": "in One Daily View",       "p": 1},
    {"f": "08-patro-month-native.png",        "tag": "BIKRAM SAMBAT",    "h1": "Plan Family Rituals",    "h2": "on Nepali Dates",         "p": 2},
    {"f": "09-patro-day-native.png",          "tag": "PANCHANGA",        "h1": "Follow Tithi",           "h2": "Festivals & Muhurat",     "p": 0},
    {"f": "02-rashifal-daily-native.png",     "tag": "RASHIFAL",         "h1": "Daily Guidance",         "h2": "for the People You Save", "p": 1},
    {"f": "10-pandit-chat-empty-native.png",  "tag": "JYOTISH BAJE",     "h1": "Ask About",              "h2": "the People You Trust",    "p": 3},
    {"f": "11-pandit-chat-answer-native.png", "tag": "PRIVATE GUIDANCE", "h1": "Answers Grounded",       "h2": "in Your Household",       "p": 1},
    {"f": "12-settings-native.png",           "tag": "BILINGUAL",        "h1": "English & Nepali",       "h2": "for Every Generation",    "p": 2},
]


def make_gradient(w, h, c1, c2, c3):
    """Vertical 3-stop gradient (top → 52% → bottom), rendered as a 1-px column."""
    col = Image.new("RGB", (1, h))
    px = col.load()
    mid = int(h * 0.52)
    for y in range(h):
        if y < mid:
            t = y / max(mid - 1, 1)
            a, b = c1, c2
        else:
            t = (y - mid) / max(h - mid - 1, 1)
            a, b = c2, c3
        px[0, y] = tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))
    return col.resize((w, h), Image.NEAREST)


def qr_motif(draw, ox, oy, cell, cols, rows, color, seed):
    """Sparse grid of rounded squares suggesting a QR code."""
    for r in range(rows):
        for c in range(cols):
            if (r * 7 + c * 5 + seed) % 3 == 0:
                x, y = ox + c * cell, oy + r * cell
                draw.rounded_rectangle(
                    [x, y, x + cell - 8, y + cell - 8],
                    radius=6, fill=color,
                )


def make_slide(s, idx, source_dir, cfg):
    W, H = cfg["canvas"]
    c1, c2, c3, accent = PALETTES[s["p"]]

    source_path = source_dir / s["f"]
    if not source_path.exists():
        raise FileNotFoundError(f"Missing screenshot source: {source_path}")
    src = Image.open(source_path).convert("RGBA")

    phone_w = cfg["phone_w"]
    bezel = cfg["bezel"]
    corner = int(phone_w * cfg["corner_pct"])
    screen_w = phone_w - 2 * bezel
    screen_h = int(screen_w * (src.height / src.width))   # capture aspect
    phone_h = screen_h + 2 * bezel
    phone_x = (W - phone_w) // 2
    phone_y = H - phone_h + cfg["overhang"]

    tag_font = ImageFont.truetype(INTER_SEMIBOLD, cfg["tag_size"])
    h1_font = ImageFont.truetype(FRAUNCES_SEMIBOLD, cfg["h1_size"])
    h2_font = ImageFont.truetype(INTER_REGULAR, cfg["h2_size"])

    canvas = make_gradient(W, H, c1, c2, c3).convert("RGBA")

    # ── Decorative layer: glow + circles + QR motif ───────────────────
    deco = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    dd = ImageDraw.Draw(deco)
    # Radial glow rising from behind the phone's top edge
    glow_r = int(phone_w * 0.85)
    dd.ellipse(
        [W // 2 - glow_r, phone_y - glow_r // 2,
         W // 2 + glow_r, phone_y + glow_r // 2],
        fill=accent + (66,),
    )
    # Soft corner orbs
    orb = int(W * 0.36)
    dd.ellipse([-orb // 2, -orb // 2, orb // 2, orb // 2], fill=accent + (34,))
    dd.ellipse([W - orb // 3, int(H * 0.32), W + orb, int(H * 0.32) + orb],
               fill=accent + (26,))
    deco = deco.filter(ImageFilter.GaussianBlur(radius=int(W * 0.09)))
    canvas = Image.alpha_composite(canvas, deco)

    # QR-dot motif, crisp (not blurred), tucked into the headline zone edges
    motif = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    md = ImageDraw.Draw(motif)
    cell = max(18, W // 60)
    qr_motif(md, int(W * 0.045), cfg["tag_y"] - cell, cell, 5, 7, accent + (38,), seed=idx)
    qr_motif(md, W - int(W * 0.045) - 5 * cell, cfg["tag_y"] + 2 * cell, cell, 5, 6,
             accent + (30,), seed=idx + 1)
    canvas = Image.alpha_composite(canvas, motif)
    draw = ImageDraw.Draw(canvas)

    # ── Tag pill ──────────────────────────────────────────────────────
    tag = s["tag"]
    tb = tag_font.getbbox(tag)
    tw, th = tb[2] - tb[0], tb[3] - tb[1]
    pw, ph = tw + int(th * 2.4), th + int(th * 1.1)
    px_tag = (W - pw) // 2
    py_tag = cfg["tag_y"]
    draw.rounded_rectangle(
        [px_tag, py_tag, px_tag + pw, py_tag + ph],
        radius=ph // 2, outline=accent + (200,), width=3,
        fill=(255, 255, 255, 24),
    )
    draw.text((W // 2, py_tag + ph // 2 - int(th * 0.08)), tag,
              font=tag_font, fill=accent + (255,), anchor="mm")

    # ── Headlines (Fraunces display + Inter support) ──────────────────
    y1 = py_tag + ph + int(cfg["h1_size"] * 0.55)
    draw.text((W // 2, y1), s["h1"], font=h1_font, fill="white", anchor="mt")
    bb1 = draw.textbbox((W // 2, y1), s["h1"], font=h1_font, anchor="mt")
    y2 = bb1[3] + int(cfg["h2_size"] * 0.42)
    draw.text((W // 2, y2), s["h2"], font=h2_font,
              fill=(255, 255, 255, 210), anchor="mt")

    # ── Phone drop shadow ─────────────────────────────────────────────
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle(
        [phone_x + 10, phone_y + 34, phone_x + phone_w - 10, phone_y + phone_h + 34],
        radius=corner, fill=(0, 0, 0, 96),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=44))
    canvas = Image.alpha_composite(canvas, shadow)
    draw = ImageDraw.Draw(canvas)

    # ── Phone body ────────────────────────────────────────────────────
    draw.rounded_rectangle(
        [phone_x, phone_y, phone_x + phone_w, phone_y + phone_h],
        radius=corner, fill=(14, 14, 16),
    )
    # Metallic rim: two hairline strokes
    draw.rounded_rectangle(
        [phone_x, phone_y, phone_x + phone_w, phone_y + phone_h],
        radius=corner, outline=(92, 92, 98), width=3,
    )
    draw.rounded_rectangle(
        [phone_x + 3, phone_y + 3, phone_x + phone_w - 3, phone_y + phone_h - 3],
        radius=corner - 3, outline=(30, 30, 34), width=2,
    )

    # ── Screenshot inside, with matching large screen radius ──────────
    ss = src.resize((screen_w, screen_h), Image.LANCZOS)
    mask = Image.new("L", (screen_w, screen_h), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, screen_w - 1, screen_h - 1],
        radius=corner - bezel, fill=255,
    )
    canvas.paste(ss, (phone_x + bezel, phone_y + bezel), mask)
    draw = ImageDraw.Draw(canvas)

    # ── Notch hardware ────────────────────────────────────────────────
    if cfg["notch"] == "island":
        di_w = int(screen_w * 0.275)
        di_h = int(di_w * 0.295)
        di_x = phone_x + (phone_w - di_w) // 2
        di_y = phone_y + bezel + int(di_h * 0.55)
        draw.rounded_rectangle(
            [di_x, di_y, di_x + di_w, di_y + di_h],
            radius=di_h // 2, fill=(0, 0, 0, 255),
        )
    else:
        r = max(14, int(screen_w * 0.022))
        cx = phone_x + phone_w // 2
        cy = phone_y + bezel + int(r * 2.4)
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(0, 0, 0, 255))

    out_name = f"{idx + 1:02d}-{'appstore' if cfg['notch'] == 'island' else 'playstore'}.png"
    canvas.convert("RGB").save(cfg["out_dir"] / out_name, "PNG", optimize=True)
    print(f"  ✓ {out_name}  ← {s['tag']}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--platform", choices=["ios", "android"], default="ios")
    parser.add_argument("--source", type=Path, default=DEFAULT_SRC,
                        help="Directory containing synthetic native app captures")
    parser.add_argument("--output", type=Path, default=None,
                        help="Override output directory (kept out of Git)")
    args = parser.parse_args()

    cfg = dict(PLATFORMS[args.platform])
    if args.output:
        cfg["out_dir"] = args.output.expanduser().resolve()
    cfg["out_dir"].mkdir(parents=True, exist_ok=True)
    if args.platform == "android" and args.source == DEFAULT_SRC:
        # Play set uses real Android captures; only slides with a capture render.
        args.source = ROOT / "marketing/media/playstore-android-source"
    source_dir = args.source.expanduser().resolve()

    slides = [s for s in SLIDES if (source_dir / s["f"]).exists()]
    skipped = [s["f"] for s in SLIDES if s not in slides]
    W, H = cfg["canvas"]
    print(f"Generating {len(slides)} {args.platform} store screenshots …")
    print(f"  Source:  {source_dir}")
    print(f"  Output:  {cfg['out_dir']}")
    print(f"  Size:    {W}×{H}")
    if skipped:
        print(f"  Skipped (no capture): {', '.join(skipped)}")
    print()
    for i, s in enumerate(slides):
        make_slide(s, i, source_dir, cfg)
    print(f"\n✅ Done! {len(slides)} screenshots saved to:\n   {cfg['out_dir']}")
