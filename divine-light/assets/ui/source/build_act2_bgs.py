"""Act II battle backgrounds (Milestone 25b), code-drawn like the forest one
(build_battle_bg.py): the scene fills the top band, and below it fades to
near-black because the battle windows draw over it.

    python build_act2_bgs.py      (from this folder)

Writes ../battle_bg_tundra.png and ../battle_bg_citadel.png (320x180).
"""
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parent.parent
W, H = 320, 180
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def dither_gradient(im, y0, y1, top, bottom):
    for y in range(y0, y1):
        for x in range(W):
            t = (y - y0) / max(1, (y1 - y0))
            t += (BAYER[y % 4][x % 4] / 16.0 - 0.5) * 0.12
            im.putpixel((x, y), lerp(top, bottom, min(1, max(0, t))) + (255,))


def fade_bottom(im, y0, color=(10, 10, 18)):
    for y in range(y0, H):  # anything not drawn yet starts dark
        for x in range(W):
            if im.getpixel((x, y))[3] == 0:
                im.putpixel((x, y), color + (255,))
    for y in range(y0, H):
        t = min(1.0, (y - y0) / 14.0)
        for x in range(W):
            if t >= 1 or BAYER[y % 4][x % 4] / 16.0 < t:
                im.putpixel((x, y), color + (255,))


def tundra():
    rng = random.Random(25)
    im = Image.new("RGBA", (W, H))
    dither_gradient(im, 0, 80, (14, 20, 46), (70, 96, 140))
    d = ImageDraw.Draw(im)
    # aurora: a soft green-teal ribbon
    for x in range(W):
        y = 22 + 8 * math.sin(x / 37.0) + 4 * math.sin(x / 11.0)
        for k in range(10):
            if BAYER[int(y + k) % 4][x % 4] > k + 3:
                im.putpixel((x, int(y + k)), (90, 200, 170, 255) if k < 5 else (60, 140, 140, 255))
    for _ in range(60):  # stars
        x, y = rng.randrange(W), rng.randrange(60)
        im.putpixel((x, y), (220, 230, 255, 255))
    # far mountains, snow-capped
    far = [(0, 78)] + [(x, 52 + 14 * abs(math.sin(x / 23.0)) + 6 * math.sin(x / 7.0)) for x in range(0, W + 8, 8)] + [(W, 78)]
    d.polygon(far, fill=(96, 112, 150))
    for x, y in far[1:-1]:
        d.polygon([(x - 6, y + 6), (x, y), (x + 6, y + 6)], fill=(214, 226, 242))
    # near ridge of pines
    for x in range(-4, W + 4, 7):
        h = 12 + rng.randrange(8)
        d.polygon([(x - 4, 82), (x, 82 - h), (x + 4, 82)], fill=(30, 52, 60))
        d.point((x, 82 - h), fill=(214, 226, 242))
    # the snowfield, with drifts and faint violet veins of the Unraveling
    dither_gradient(im, 82, 112, (200, 212, 232), (160, 176, 206))
    for _ in range(14):
        x, y = rng.randrange(W), 86 + rng.randrange(24)
        d.line([(x, y), (x + rng.randrange(8, 20), y)], fill=(226, 236, 250))
    for _ in range(6):
        x, y = rng.randrange(W), 92 + rng.randrange(18)
        pts = [(x + i * 3, y + (1 if i % 2 else -1)) for i in range(6)]
        d.line(pts, fill=(150, 100, 190))
    fade_bottom(im, 108)
    im.save(OUT / "battle_bg_tundra.png")
    print("wrote battle_bg_tundra.png")


def citadel():
    rng = random.Random(26)
    im = Image.new("RGBA", (W, H))
    dither_gradient(im, 0, 70, (12, 18, 40), (34, 56, 96))
    d = ImageDraw.Draw(im)
    # ice pillars along the back wall
    for x in range(14, W, 52):
        d.rectangle([x, 4, x + 14, 70], fill=(120, 170, 214))
        d.rectangle([x + 2, 4, x + 5, 70], fill=(200, 232, 252))
        d.rectangle([x + 11, 4, x + 14, 70], fill=(84, 126, 176))
        for k in range(3):  # icicles off the capital
            ix = x + 2 + k * 5
            d.polygon([(ix, 10), (ix + 2, 10), (ix + 1, 16 + rng.randrange(6))], fill=(220, 240, 255))
    # frost on the wall between, and a violet glint of the Unraveling
    for _ in range(80):
        x, y = rng.randrange(W), rng.randrange(70)
        if im.getpixel((x, y))[2] < 120:
            im.putpixel((x, y), (90, 130, 180, 255))
    for x in (66, 222):
        d.ellipse([x - 3, 30, x + 3, 36], fill=(170, 80, 220))
    # the ice floor in perspective
    dither_gradient(im, 70, 112, (110, 150, 196), (64, 96, 146))
    for k in range(-8, 9):
        d.line([(160 + k * 10, 70), (160 + k * 40, 112)], fill=(150, 192, 230))
    for y in (78, 88, 100):
        d.line([(0, y), (W, y)], fill=(150, 192, 230))
    fade_bottom(im, 108)
    im.save(OUT / "battle_bg_citadel.png")
    print("wrote battle_bg_citadel.png")


tundra()
citadel()
