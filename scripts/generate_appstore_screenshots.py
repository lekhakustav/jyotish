#!/usr/bin/env python3
"""
Generate styled App Store screenshots for Jyotish baje.
Creates phone-mockup cards at 1320×2868 for iPhone 6.9" display.

Style: Colored gradient background + feature headline + phone mockup
       (popular App Store screenshot format per Figma reference).
"""

import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# ── Paths ──────────────────────────────────────────────────────────────
SRC = "/Users/sirishjoshi/Documents/jyotish/screenshots/appstore-nepali-native-2026-07-07"
DST = "/Users/sirishjoshi/Documents/jyotish/screenshots/appstore-styled"
os.makedirs(DST, exist_ok=True)

# ── Canvas (iPhone 6.9") ──────────────────────────────────────────────
W, H = 1320, 2868

# ── Phone mockup geometry ─────────────────────────────────────────────
PHONE_W   = 840
BEZEL     = 14
CORNER    = 48
SCREEN_W  = PHONE_W - 2 * BEZEL                    # 812
SCREEN_H  = int(SCREEN_W * (H / W))                 # ~1764
PHONE_H   = SCREEN_H + 2 * BEZEL                    # ~1792
PHONE_X   = (W - PHONE_W) // 2                      # 240
OVERHANG  = 60
PHONE_Y   = H - PHONE_H + OVERHANG                  # phone bottom extends past canvas

# ── Fonts ─────────────────────────────────────────────────────────────
FONT_HN   = "/System/Library/Fonts/HelveticaNeue.ttc"
FONT_SF   = "/System/Library/Fonts/SFNS.ttf"

tag_font  = ImageFont.truetype(FONT_SF,  42)
h1_font   = ImageFont.truetype(FONT_HN, 88, index=1)   # Helvetica Neue Bold
h2_font   = ImageFont.truetype(FONT_HN, 84, index=7)   # Helvetica Neue Light

# ── Color palettes  (gradient_top → gradient_bottom) ──────────────────
PALETTES = [
    # 0 — Deep Saffron → Amber (dawn, warmth)
    ((102, 32, 4),  (194, 88, 8)),
    # 1 — Deep Indigo → Violet (night sky, mystical)
    ((28, 10, 62),  (88, 32, 128)),
    # 2 — Deep Teal → Jade (nature, calm)
    ((6, 44, 44),   (14, 116, 98)),
    # 3 — Deep Wine → Rose (sacred, regal)
    ((78, 10, 28),  (158, 32, 52)),
]

# ── Slide definitions ─────────────────────────────────────────────────
SLIDES = [
    {"f": "01-home-native.png",               "tag": "JYOTISH BAJE",  "h1": "Sacred Dawn",       "h2": "in Your Pocket",    "p": 1},
    {"f": "02-rashifal-daily-native.png",      "tag": "RASHIFAL",      "h1": "Know What",         "h2": "Today Brings",      "p": 0},
    {"f": "03-rashifal-weekly-native.png",     "tag": "RASHIFAL",      "h1": "Plan Your Week",    "h2": "with the Stars",    "p": 1},
    {"f": "04-rashifal-singha-native.png",     "tag": "RASHI",         "h1": "Deep Rashi",        "h2": "Insights",          "p": 2},
    {"f": "05-family-native.png",             "tag": "PARIVAR",       "h1": "Astrology for",     "h2": "the Whole Family",  "p": 0},
    {"f": "06-family-kundali-native.png",     "tag": "KUNDALI",       "h1": "Authentic Vedic",   "h2": "Birth Charts",      "p": 3},
    {"f": "07-family-dasha-native.png",       "tag": "DASHA",         "h1": "Vimshottari",       "h2": "Dasha Cycles",      "p": 1},
    {"f": "08-patro-month-native.png",        "tag": "PATRO",         "h1": "Bikram Sambat",     "h2": "Calendar",          "p": 2},
    {"f": "09-patro-day-native.png",          "tag": "PANCHANGA",     "h1": "Daily Panchanga",   "h2": "at a Glance",       "p": 0},
    {"f": "10-pandit-chat-empty-native.png",  "tag": "JYOTISH BAJE",   "h1": "Ask Jyotish Baje",  "h2": "Anything",          "p": 3},
    {"f": "11-pandit-chat-answer-native.png", "tag": "AI GUIDANCE",   "h1": "AI-Powered",        "h2": "Vedic Wisdom",      "p": 1},
    {"f": "12-settings-native.png",           "tag": "SETTINGS",      "h1": "English & Nepali",  "h2": "Your Choice",       "p": 2},
]

# ── Helpers ────────────────────────────────────────────────────────────

def make_gradient(w, h, c1, c2):
    """Fast vertical gradient (render 1-px column, stretch)."""
    col = Image.new("RGB", (1, h))
    px = col.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        px[0, y] = tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))
    return col.resize((w, h), Image.NEAREST)


def lighten(c, amount=0.22):
    return tuple(min(255, int(v + (255 - v) * amount)) for v in c)


def make_slide(s, idx):
    c1, c2 = PALETTES[s["p"]]

    # ── 1. Gradient background ────────────────────────────────────────
    canvas = make_gradient(W, H, c1, c2).convert("RGBA")
    draw   = ImageDraw.Draw(canvas)

    # ── 2. Feature tag pill ───────────────────────────────────────────
    tag    = s["tag"]
    tb     = tag_font.getbbox(tag)
    tw, th = tb[2] - tb[0], tb[3] - tb[1]
    pw, ph = tw + 56, th + 32
    px_tag = (W - pw) // 2
    py_tag = 290
    draw.rounded_rectangle(
        [px_tag, py_tag, px_tag + pw, py_tag + ph],
        radius=ph // 2,
        fill=lighten(c2, 0.18),
    )
    draw.text(
        (W // 2, py_tag + ph // 2),
        tag, font=tag_font, fill="white", anchor="mm",
    )

    # ── 3. Headlines ─────────────────────────────────────────────────
    y1 = py_tag + ph + 60
    draw.text((W // 2, y1), s["h1"], font=h1_font, fill="white", anchor="mt")
    bb1 = h1_font.getbbox(s["h1"])
    y2 = y1 + (bb1[3] - bb1[1]) + 18
    # Second line slightly transparent for visual hierarchy
    draw.text(
        (W // 2, y2), s["h2"], font=h2_font,
        fill=(255, 255, 255, 190), anchor="mt",
    )

    # ── 4. Phone drop shadow ─────────────────────────────────────────
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd     = ImageDraw.Draw(shadow)
    sd.rounded_rectangle(
        [PHONE_X + 12, PHONE_Y + 30,
         PHONE_X + PHONE_W - 12, PHONE_Y + PHONE_H + 30],
        radius=CORNER,
        fill=(0, 0, 0, 70),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=38))
    canvas = Image.alpha_composite(canvas, shadow)
    draw   = ImageDraw.Draw(canvas)

    # ── 5. Phone body (space-black frame) ─────────────────────────────
    draw.rounded_rectangle(
        [PHONE_X, PHONE_Y,
         PHONE_X + PHONE_W, PHONE_Y + PHONE_H],
        radius=CORNER,
        fill=(16, 16, 16),
        outline=(58, 58, 58),
        width=2,
    )

    # ── 6. Screenshot inside phone ────────────────────────────────────
    ss = Image.open(os.path.join(SRC, s["f"])).convert("RGBA")
    ss = ss.resize((SCREEN_W, SCREEN_H), Image.LANCZOS)

    sx = PHONE_X + BEZEL
    sy = PHONE_Y + BEZEL

    # Rounded-corner mask for the screen area
    mask = Image.new("L", (SCREEN_W, SCREEN_H), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, SCREEN_W - 1, SCREEN_H - 1],
        radius=CORNER - BEZEL,
        fill=255,
    )
    canvas.paste(ss, (sx, sy), mask)

    # ── 7. Dynamic Island ─────────────────────────────────────────────
    draw   = ImageDraw.Draw(canvas)
    di_w, di_h = 108, 30
    di_x = PHONE_X + (PHONE_W - di_w) // 2
    di_y = PHONE_Y + BEZEL + 14
    draw.rounded_rectangle(
        [di_x, di_y, di_x + di_w, di_y + di_h],
        radius=di_h // 2,
        fill=(0, 0, 0, 255),
    )

    # ── 8. Save ───────────────────────────────────────────────────────
    out_name = f"{idx + 1:02d}-appstore.png"
    canvas.convert("RGB").save(
        os.path.join(DST, out_name), "PNG", optimize=True,
    )
    print(f"  ✓ {out_name}  ← {s['tag']}")


# ── Main ──────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print(f"Generating {len(SLIDES)} App Store screenshots …")
    print(f"  Source:  {SRC}")
    print(f"  Output:  {DST}")
    print(f"  Size:    {W}×{H} (iPhone 6.9\")")
    print()
    for i, s in enumerate(SLIDES):
        make_slide(s, i)
    print(f"\n✅ Done! {len(SLIDES)} screenshots saved to:\n   {DST}")
