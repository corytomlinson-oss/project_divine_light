"""The Northern Tundra's overworld atlas (Milestone 25b), code-drawn in the
same dithered style as the Act I tiles. Same eight columns as
overworld_tiles.png, so Region.gd's tile letters work unchanged:

  tundra_tiles.png  0 snow  1 snowy pines (wall)  2 gate  3 packed-snow road
                    4 icy stone arch  5 frozen lake (blocked)
                    6 frost tufts (walkable decor)  7 bridge over ice

Usage: python build_tundra_tiles.py
"""
import os
import random

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..')
OW = os.path.join(HERE, 'overworld')
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]

SNOW_HI = (236, 242, 250)
SNOW = (214, 224, 238)
SNOW_LO = (182, 196, 218)
SHADOW = (150, 166, 196)


def px(im, x, y, c):
    if 0 <= x < 16 and 0 <= y < 16:
        im.putpixel((x, y), c + (255,) if len(c) == 3 else c)


def rect(im, x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            px(im, x, y, c)


def snow(seed=1):
    rng = random.Random(seed)
    im = Image.new('RGBA', (16, 16))
    for y in range(16):
        for x in range(16):
            b = BAYER[y % 4][x % 4]
            px(im, x, y, SNOW if b > 4 else SNOW_HI)
    for _ in range(6):  # wind ripples
        x, y = rng.randrange(14), rng.randrange(16)
        px(im, x, y, SNOW_LO)
        px(im, x + 1, y, SNOW_LO)
    return im


def pines():
    im = Image.new('RGBA', (16, 16))
    for y in range(16):
        for x in range(16):
            px(im, x, y, (40, 58, 64) if BAYER[y % 4][x % 4] > 7 else (32, 48, 56))
    # two snow-laden pines filling the tile (tiles touch, so it reads as forest)
    for cx, top in ((4, 1), (12, 3)):
        for row in range(12):
            half = 1 + row // 2
            y = top + row
            for x in range(cx - half, cx + half + 1):
                px(im, x, y, (28, 70, 62) if (x + y) % 3 else (22, 56, 52))
            # snow on the upper edge of each tier
            if row % 3 == 0:
                for x in range(cx - half, cx + half + 1):
                    px(im, x, y, SNOW_HI if (x + row) % 2 else SNOW)
        rect(im, cx, top + 12, cx, top + 13, (74, 52, 38))
    return im


def gate():
    im = Image.open(os.path.join(OW, 'wooden_gate_door.png')).convert('RGBA').resize((16, 16), Image.NEAREST)
    for x in range(16):  # snow on the lintel
        px(im, x, 0, SNOW_HI)
        if x % 3:
            px(im, x, 1, SNOW)
    return im


def road(seed=3):
    rng = random.Random(seed)
    im = Image.new('RGBA', (16, 16))
    for y in range(16):
        for x in range(16):
            px(im, x, y, (176, 184, 200) if BAYER[y % 4][x % 4] > 5 else (162, 170, 188))
    for _ in range(8):  # stones and old cart ruts
        x, y = rng.randrange(16), rng.randrange(16)
        px(im, x, y, (128, 132, 148))
    for y in range(16):
        px(im, 4, y, (150, 158, 178))
        px(im, 11, y, (150, 158, 178))
    return im


def arch():
    im = snow(7)
    rect(im, 2, 3, 13, 15, (96, 112, 136))       # stone
    rect(im, 3, 4, 12, 15, (126, 144, 170))
    rect(im, 5, 6, 10, 15, (18, 22, 36))         # dark opening
    rect(im, 6, 5, 9, 5, (18, 22, 36))
    for x in range(2, 14):                       # snow cap and icicles
        px(im, x, 2, SNOW_HI)
    for x, ln in ((4, 2), (7, 1), (9, 3), (11, 1)):
        rect(im, x, 6, x, 5 + ln, (190, 226, 250))
    return im


def frozen_lake():
    im = Image.new('RGBA', (16, 16))
    for y in range(16):
        for x in range(16):
            px(im, x, y, (150, 196, 226) if BAYER[y % 4][x % 4] > 6 else (132, 182, 216))
    for x0, y0, ln in ((2, 3, 5), (8, 9, 6), (5, 13, 3)):  # cracks and glints
        for i in range(ln):
            px(im, x0 + i, y0 + (i % 2), (106, 150, 190))
    for x, y in ((11, 2), (3, 8), (13, 12)):
        px(im, x, y, (240, 250, 255))
    return im


def tufts():
    im = snow(11)
    for x, y in ((3, 4), (11, 3), (6, 10), (13, 12), (2, 13)):
        px(im, x, y, (96, 120, 112))
        px(im, x - 1, y + 1, (96, 120, 112))
        px(im, x + 1, y + 1, (120, 146, 134))
        px(im, x, y - 1, (230, 240, 255))       # frost tip
    return im


def bridge():
    im = frozen_lake()
    rect(im, 3, 0, 12, 15, (120, 88, 58))       # planks, north-south
    for y in range(0, 16, 3):
        rect(im, 3, y, 12, y, (92, 66, 44))
    rect(im, 2, 0, 2, 15, (74, 52, 36))         # rails on the ice sides
    rect(im, 13, 0, 13, 15, (74, 52, 36))
    for y in range(1, 16, 4):                   # frost on the planks
        px(im, 5 + y % 5, y, SNOW)
    return im


def strip(tiles, name):
    out = Image.new('RGBA', (16 * len(tiles), 16))
    for i, t in enumerate(tiles):
        out.paste(t, (16 * i, 0))
    out.save(os.path.join(OUT, name))
    print('wrote', name, out.size)


if __name__ == '__main__':
    strip([snow(), pines(), gate(), road(), arch(), frozen_lake(), tufts(), bridge()], 'tundra_tiles.png')
