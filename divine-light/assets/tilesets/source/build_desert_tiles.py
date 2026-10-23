"""Duskara's atlases (Milestone 25c), code-drawn like the tundra's:

  desert_tiles.png   the Duskara Wastes (same 8 columns as overworld_tiles):
                     0 sand  1 dune-rock (wall)  2 gate  3 flagstone road
                     4 sandstone arch  5 oasis water (blocked)  6 scrub  7 bridge
  duskara_tiles.png  the town atlas's 16 columns, sun-baked (sand ground,
                     rock for trees, oasis water, scrub for flowers)
  sanctum_tiles.png  the Sunken Sanctum: 0 floor 1 wall 2 door 3/4 runes
                     5 burning floor (Dungeon.FIRE_COORDS)

Usage: python build_desert_tiles.py
"""
import os
import random

from PIL import Image

from build_dungeon_tiles import CRIMSON, S, VIOLET, jit, put, rect, rune, tile

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..')
OW = os.path.join(HERE, 'overworld')
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
SAND, SAND_HI, SAND_LO = (222, 188, 128), (238, 208, 150), (196, 160, 104)


def sand(seed=1):
    rng = random.Random(seed)
    im = tile()
    for y in range(S):
        for x in range(S):
            put(im, x, y, SAND if BAYER[y % 4][x % 4] > 5 else SAND_HI)
    for _ in range(7):  # wind ripples
        x, y = rng.randrange(13), rng.randrange(S)
        for i in range(3):
            put(im, x + i, y, SAND_LO)
    return im


def rock():
    rng = random.Random(2)
    im = tile((150, 92, 60))
    for by in range(0, S, 5):
        for bx in range(-(by % 10) // 2, S, 7):
            rect(im, bx + 1, by + 1, bx + 5, by + 3, jit((182, 116, 74), 8, rng))
            rect(im, bx + 1, by + 1, bx + 5, by + 1, (210, 150, 100))
    return im


def gate():
    im = Image.open(os.path.join(OW, 'wooden_gate_door.png')).convert('RGBA').resize((S, S), Image.NEAREST)
    for x in range(S):
        put(im, x, 0, (236, 210, 160))
    return im


def road(seed=3):
    rng = random.Random(seed)
    im = tile()
    for by in (0, 8):
        for bx in (0, 8):
            base = jit((196, 170, 126), 8, rng)
            rect(im, bx, by, bx + 7, by + 7, (150, 126, 88))
            rect(im, bx + 1, by + 1, bx + 6, by + 6, base)
    return im


def arch():
    im = sand(7)
    rect(im, 2, 3, 13, 15, (170, 120, 70))
    rect(im, 3, 4, 12, 15, (204, 158, 98))
    rect(im, 5, 6, 10, 15, (30, 20, 16))
    rect(im, 6, 5, 9, 5, (30, 20, 16))
    for x in (3, 6, 9, 12):
        put(im, x, 3, (236, 196, 130))
    return im


def water():
    im = tile()
    for y in range(S):
        for x in range(S):
            put(im, x, y, (60, 150, 170) if BAYER[y % 4][x % 4] > 6 else (44, 128, 156))
    for x0, y0 in ((2, 4), (9, 10), (5, 13)):
        rect(im, x0, y0, x0 + 3, y0, (150, 220, 230))
    return im


def scrub():
    im = sand(11)
    for x, y in ((3, 5), (11, 4), (7, 11), (13, 12)):
        put(im, x, y, (96, 120, 56))
        put(im, x - 1, y + 1, (96, 120, 56))
        put(im, x + 1, y + 1, (120, 146, 70))
        put(im, x, y + 1, (74, 96, 44))
    return im


def bridge():
    im = water()
    rect(im, 3, 0, 12, 15, (150, 104, 62))
    for y in range(0, S, 3):
        rect(im, 3, y, 12, y, (112, 76, 44))
    rect(im, 2, 0, 2, 15, (90, 60, 36))
    rect(im, 13, 0, 13, 15, (90, 60, 36))
    return im


def sanctum_floor():
    rng = random.Random(61)
    im = tile((160, 120, 74))
    for by in (0, 8):
        for bx in (0, 8):
            rect(im, bx + 1, by + 1, bx + 6, by + 6, jit((196, 156, 100), 6, rng))
            put(im, bx + 1, by + 1, (220, 184, 128))
    for _ in range(5):
        put(im, rng.randrange(S), rng.randrange(S), (226, 196, 140))  # drifted sand
    return im


def sanctum_wall():
    rng = random.Random(62)
    im = tile((98, 64, 40))
    for row, off in ((0, 0), (1, 4), (2, 0), (3, 4)):
        y0 = row * 4
        for bx in range(-off, S, 8):
            rect(im, bx + 1, y0 + 1, bx + 6, y0 + 2, jit((176, 128, 78), 8, rng))
            rect(im, bx + 1, y0 + 1, bx + 6, y0 + 1, (206, 164, 108))
    for x, y in ((3, 6), (11, 10)):  # carved glyphs
        rect(im, x, y, x + 1, y + 1, (120, 84, 50))
    return im


def sanctum_door():
    im = sanctum_wall()
    rect(im, 4, 3, 11, 15, (26, 16, 12))
    rect(im, 5, 2, 10, 2, (26, 16, 12))
    rect(im, 3, 2, 3, 15, (226, 186, 120))
    rect(im, 12, 2, 12, 15, (226, 186, 120))
    return im


def fire_floor():
    rng = random.Random(63)
    im = sanctum_floor()
    for y in range(S):
        for x in range(S):
            if (x * 7 + y * 3) % 5 == 0:
                put(im, x, y, (120, 40, 20))  # scorched cracks
    for _ in range(9):  # flames licking up
        x, y = rng.randrange(2, 14), rng.randrange(5, 15)
        put(im, x, y, (255, 110, 30))
        put(im, x, y - 1, (255, 170, 60))
        put(im, x, y - 2, (255, 230, 140))
    return im


def degrass(im, ground):
    """Grass showing behind a copied town tile (fence, stall) -> this town's ground."""
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a and g > r + 18 and g > b + 18:
                px[x, y] = ground
    return im


def strip(tiles, name):
    out = Image.new('RGBA', (S * len(tiles), S))
    for i, t in enumerate(tiles):
        out.paste(t, (S * i, 0))
    out.save(os.path.join(OUT, name))
    print('wrote', name, out.size)


if __name__ == '__main__':
    desert = [sand(), rock(), gate(), road(), arch(), water(), scrub(), bridge()]
    strip(desert, 'desert_tiles.png')
    town = Image.open(os.path.join(OUT, 'town_tiles.png')).convert('RGBA')
    tt = [town.crop((S * i, 0, S * i + S, S)) for i in range(16)]
    for town_col, d in ((0, 0), (1, 1), (2, 2), (3, 3), (7, 5), (9, 6)):
        tt[town_col] = desert[d]
    for i in range(4, 16):
        if i not in (7, 9):
            tt[i] = degrass(tt[i], SAND + (255,))
    strip(tt, 'duskara_tiles.png')
    f = sanctum_floor()
    strip([f, sanctum_wall(), sanctum_door(), rune(f, VIOLET), rune(f, CRIMSON), fire_floor()], 'sanctum_tiles.png')
