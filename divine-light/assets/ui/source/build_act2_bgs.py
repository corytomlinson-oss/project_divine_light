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


def desert():
    rng = random.Random(27)
    im = Image.new("RGBA", (W, H))
    dither_gradient(im, 0, 80, (60, 90, 150), (250, 196, 120))
    d = ImageDraw.Draw(im)
    d.ellipse([214, 18, 254, 58], fill=(255, 236, 170))       # the sun
    d.ellipse([220, 24, 248, 52], fill=(255, 250, 220))
    far = [(0, 82)] + [(x, 64 + 8 * math.sin(x / 31.0) + 4 * math.sin(x / 9.0)) for x in range(0, W + 8, 8)] + [(W, 82)]
    d.polygon(far, fill=(214, 150, 96))
    # a half-buried temple on the horizon
    d.polygon([(118, 74), (130, 58), (150, 58), (162, 74)], fill=(176, 116, 70))
    dither_gradient(im, 80, 112, (236, 196, 134), (204, 160, 100))
    for _ in range(16):
        x, y = rng.randrange(W), 84 + rng.randrange(26)
        d.line([(x, y), (x + rng.randrange(6, 16), y)], fill=(246, 214, 160))
    for _ in range(6):  # violet veins of the Unraveling
        x, y = rng.randrange(W), 90 + rng.randrange(20)
        d.line([(x + i * 3, y + (1 if i % 2 else -1)) for i in range(6)], fill=(150, 100, 190))
    fade_bottom(im, 108)
    im.save(OUT / "battle_bg_desert.png")
    print("wrote battle_bg_desert.png")


def sanctum():
    rng = random.Random(28)
    im = Image.new("RGBA", (W, H))
    dither_gradient(im, 0, 72, (40, 22, 16), (110, 66, 40))
    d = ImageDraw.Draw(im)
    for x in range(10, W, 50):  # sandstone pillars with carved bands
        d.rectangle([x, 0, x + 18, 72], fill=(170, 120, 74))
        d.rectangle([x + 2, 0, x + 5, 72], fill=(206, 160, 104))
        for y in (16, 40):
            d.rectangle([x, y, x + 18, y + 3], fill=(130, 88, 52))
    for x in (60, 160, 260):  # braziers
        d.rectangle([x - 6, 52, x + 6, 60], fill=(90, 60, 36))
        d.polygon([(x - 6, 52), (x, 34), (x + 6, 52)], fill=(255, 140, 40))
        d.polygon([(x - 3, 52), (x, 42), (x + 3, 52)], fill=(255, 230, 140))
    dither_gradient(im, 72, 112, (150, 104, 62), (100, 64, 38))
    for _ in range(10):  # cracks glowing with heat
        x, y = rng.randrange(W), 78 + rng.randrange(30)
        d.line([(x, y), (x + rng.randrange(4, 12), y + rng.randrange(-2, 3))], fill=(230, 100, 40))
    fade_bottom(im, 108)
    im.save(OUT / "battle_bg_sanctum.png")
    print("wrote battle_bg_sanctum.png")


def coast():
    rng = random.Random(29)
    im = Image.new("RGBA", (W, H))
    dither_gradient(im, 0, 70, (30, 36, 52), (90, 104, 120))
    d = ImageDraw.Draw(im)
    for _ in range(5):  # storm clouds
        x, y = rng.randrange(-20, W), rng.randrange(4, 30)
        d.ellipse([x, y, x + 70, y + 18], fill=(46, 52, 70))
    d.line([(244, 8), (236, 30), (246, 30), (232, 58)], fill=(255, 250, 190), width=2)  # lightning
    dither_gradient(im, 62, 88, (40, 80, 110), (30, 64, 96))   # the sea
    for _ in range(18):
        x, y = rng.randrange(W), 64 + rng.randrange(22)
        d.line([(x, y), (x + rng.randrange(5, 12), y)], fill=(150, 196, 214))
    d.polygon([(60, 74), (96, 66), (104, 76)], fill=(70, 50, 36))      # a sunken hull
    d.line([(84, 70), (78, 46)], fill=(70, 50, 36), width=2)           # its broken mast
    dither_gradient(im, 88, 112, (196, 184, 150), (160, 150, 120))  # the beach
    for _ in range(6):
        x, y = rng.randrange(W), 92 + rng.randrange(18)
        d.line([(x + i * 3, y + (1 if i % 2 else -1)) for i in range(6)], fill=(150, 100, 190))
    fade_bottom(im, 108)
    im.save(OUT / "battle_bg_coast.png")
    print("wrote battle_bg_coast.png")


def fortress():
    rng = random.Random(30)
    im = Image.new("RGBA", (W, H))
    dither_gradient(im, 0, 70, (16, 24, 30), (44, 58, 66))
    d = ImageDraw.Draw(im)
    for x in range(0, W, 64):  # arches of wet stone, weed hanging
        d.rectangle([x, 0, x + 12, 70], fill=(70, 86, 92))
        d.rectangle([x + 2, 0, x + 4, 70], fill=(110, 130, 136))
        for k in range(3):
            d.line([(x + 3 + k * 3, 0), (x + 3 + k * 3, 10 + rng.randrange(14))], fill=(60, 110, 70))
    dither_gradient(im, 70, 112, (40, 92, 116), (28, 70, 96))  # the flooded floor
    for _ in range(20):
        x, y = rng.randrange(W), 74 + rng.randrange(34)
        d.line([(x, y), (x + rng.randrange(4, 10), y)], fill=(110, 170, 196))
    fade_bottom(im, 108)
    im.save(OUT / "battle_bg_fortress.png")
    print("wrote battle_bg_fortress.png")


def reach():
    rng = random.Random(31)
    im = Image.new("RGBA", (W, H))
    dither_gradient(im, 0, 76, (16, 10, 24), (70, 50, 80))
    d = ImageDraw.Draw(im)
    d.ellipse([130, 52, 190, 92], fill=(120, 50, 170))   # the Maw's glow on the horizon
    d.ellipse([144, 60, 176, 84], fill=(200, 120, 255))
    far = [(0, 80)] + [(x, 70 + 6 * math.sin(x / 19.0)) for x in range(0, W + 8, 8)] + [(W, 80)]
    d.polygon(far, fill=(40, 32, 48))
    for x in range(8, W, 37):  # dead trees
        d.line([(x, 80), (x, 60)], fill=(30, 24, 34), width=2)
        d.line([(x, 66), (x - 6, 60)], fill=(30, 24, 34))
        d.line([(x, 70), (x + 5, 64)], fill=(30, 24, 34))
    dither_gradient(im, 80, 112, (100, 96, 104), (70, 66, 76))
    for _ in range(10):
        x, y = rng.randrange(W), 84 + rng.randrange(24)
        d.line([(x + i * 3, y + (1 if i % 2 else -1)) for i in range(6)], fill=(150, 80, 200))
    fade_bottom(im, 108)
    im.save(OUT / "battle_bg_reach.png")
    print("wrote battle_bg_reach.png")


tundra()
citadel()
reach()
desert()
sanctum()
coast()
fortress()
