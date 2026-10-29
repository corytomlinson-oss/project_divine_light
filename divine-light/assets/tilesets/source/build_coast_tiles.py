"""Selavon's atlases (Milestone 25d), code-drawn like the desert's:

  coast_tiles.png     the Selavon Coast (same 8 columns as overworld_tiles):
                      0 salt grass  1 cliff rock (wall)  2 gate  3 boardwalk
                      4 sea-stone arch  5 sea (blocked)  6 shells  7 pier
  selavon_tiles.png   the town atlas's 16 columns, by the sea
  fortress_tiles.png  the Drowned Fortress: 0 wet floor 1 mossy wall 2 door
                      3/4 runes  5 flood water (Dungeon.WATER_COORDS)

Usage: python build_coast_tiles.py
"""
import os
import random

from PIL import Image

from build_desert_tiles import BAYER, degrass, strip
from build_dungeon_tiles import CRIMSON, S, VIOLET, jit, put, rect, rune, tile

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..')
OW = os.path.join(HERE, 'overworld')
GRASS = ((96, 150, 120), (118, 170, 136))


def salt_grass(seed=1):
    rng = random.Random(seed)
    im = tile()
    for y in range(S):
        for x in range(S):
            put(im, x, y, GRASS[0] if BAYER[y % 4][x % 4] > 6 else GRASS[1])
    for _ in range(8):
        put(im, rng.randrange(S), rng.randrange(S), (176, 200, 150))
    return im


def cliff():
    rng = random.Random(2)
    im = tile((70, 78, 92))
    for by in range(0, S, 5):
        for bx in range(-(by % 10) // 2, S, 7):
            rect(im, bx + 1, by + 1, bx + 5, by + 3, jit((110, 120, 136), 8, rng))
            rect(im, bx + 1, by + 1, bx + 5, by + 1, (150, 160, 176))
    return im


def gate():
    return Image.open(os.path.join(OW, 'wooden_gate_door.png')).convert('RGBA').resize((S, S), Image.NEAREST)


def boardwalk():
    im = tile((120, 88, 58))
    for x in range(0, S, 4):
        rect(im, x, 0, x, 15, (86, 60, 38))
    for x in range(1, S, 4):
        rect(im, x, 0, x, 15, (150, 112, 74))
    return im


def arch():
    im = salt_grass(7)
    rect(im, 2, 3, 13, 15, (60, 90, 100))
    rect(im, 3, 4, 12, 15, (90, 128, 138))
    rect(im, 5, 6, 10, 15, (12, 22, 30))
    rect(im, 6, 5, 9, 5, (12, 22, 30))
    for x, y in ((4, 8), (11, 11), (7, 4)):
        put(im, x, y, (80, 140, 90))  # barnacles and weed
    return im


def sea():
    im = tile()
    for y in range(S):
        for x in range(S):
            put(im, x, y, (40, 92, 130) if BAYER[y % 4][x % 4] > 6 else (30, 76, 116))
    for x0, y0 in ((1, 3), (8, 9), (4, 13)):
        rect(im, x0, y0, x0 + 4, y0, (120, 180, 210))
    return im


def shells():
    im = salt_grass(11)
    for x, y in ((3, 4), (11, 6), (7, 12)):
        put(im, x, y, (236, 220, 200))
        put(im, x + 1, y, (220, 190, 170))
        put(im, x, y + 1, (200, 170, 150))
    return im


def pier():
    im = sea()
    rect(im, 3, 0, 12, 15, (130, 94, 60))
    for y in range(0, S, 3):
        rect(im, 3, y, 12, y, (96, 68, 42))
    rect(im, 2, 0, 2, 15, (70, 50, 32))
    rect(im, 13, 0, 13, 15, (70, 50, 32))
    return im


def wet_floor():
    rng = random.Random(71)
    im = tile((58, 72, 78))
    for by in (0, 8):
        for bx in (0, 8):
            rect(im, bx + 1, by + 1, bx + 6, by + 6, jit((84, 102, 108), 6, rng))
            put(im, bx + 2, by + 2, (130, 160, 168))  # wet sheen
    return im


def mossy_wall():
    rng = random.Random(72)
    im = tile((34, 44, 50))
    for row, off in ((0, 0), (1, 4), (2, 0), (3, 4)):
        y0 = row * 4
        for bx in range(-off, S, 8):
            rect(im, bx + 1, y0 + 1, bx + 6, y0 + 2, jit((80, 96, 104), 8, rng))
            if rng.random() < 0.5:
                rect(im, bx + 1, y0 + 2, bx + 3, y0 + 2, (70, 120, 80))  # moss
    return im


def fortress_door():
    im = mossy_wall()
    rect(im, 4, 3, 11, 15, (10, 16, 22))
    rect(im, 5, 2, 10, 2, (10, 16, 22))
    return im


def flood():
    rng = random.Random(73)
    im = tile()
    for y in range(S):
        for x in range(S):
            put(im, x, y, (44, 96, 120) if BAYER[y % 4][x % 4] > 5 else (34, 82, 108))
    for _ in range(4):  # ripples
        x, y = rng.randrange(2, 12), rng.randrange(2, 14)
        rect(im, x, y, x + 3, y, (110, 170, 196))
    return im


if __name__ == '__main__':
    coast = [salt_grass(), cliff(), gate(), boardwalk(), arch(), sea(), shells(), pier()]
    strip(coast, 'coast_tiles.png')
    town = Image.open(os.path.join(OUT, 'town_tiles.png')).convert('RGBA')
    tt = [town.crop((S * i, 0, S * i + S, S)) for i in range(16)]
    for town_col, c in ((0, 0), (1, 1), (2, 2), (3, 3), (7, 5), (9, 6)):
        tt[town_col] = coast[c]
    for i in range(4, 16):
        if i not in (7, 9):
            tt[i] = degrass(tt[i], GRASS[1] + (255,))
    strip(tt, 'selavon_tiles.png')
    f = wet_floor()
    strip([f, mossy_wall(), fortress_door(), rune(f, VIOLET), rune(f, CRIMSON), flood()], 'fortress_tiles.png')
