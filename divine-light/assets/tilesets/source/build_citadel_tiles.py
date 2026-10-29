"""The Frozen Citadel's dungeon atlas (Milestone 25b), in the style of
build_dungeon_tiles.py (whose helpers it uses). Six columns: the five every
dungeon has, plus sliding ice.

  citadel_tiles.png  0 floor (frosted flagstones)  1 wall (ice brick)
                     2 door (dark icy arch)  3 captive rune  4 boss rune
                     5 sliding ice (Dungeon.ICE_COORDS)

Usage: python build_citadel_tiles.py
"""
import os
import random

from PIL import Image

from build_dungeon_tiles import CRIMSON, S, VIOLET, jit, put, rect, rune, tile

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')


def floor():
    """2x2 flagstones of blue-grey stone, frost in the seams."""
    rng = random.Random(51)
    im = tile((84, 100, 128))
    for by in (0, 8):
        for bx in (0, 8):
            base = jit((96, 114, 142), 6, rng)
            rect(im, bx + 1, by + 1, bx + 6, by + 6, base)
            put(im, bx + 1, by + 1, (124, 142, 170))
            for _ in range(3):
                put(im, bx + rng.randrange(1, 7), by + rng.randrange(1, 7), jit((78, 94, 120), 4, rng))
    for x in range(S):  # frost along the seams
        if x % 3 == 0:
            put(im, x, 7, (180, 204, 230))
            put(im, 7, x, (180, 204, 230))
    return im


def wall():
    """Running-bond blocks of blue ice with bright edges."""
    rng = random.Random(52)
    im = tile((40, 66, 104))
    for row, off in ((0, 0), (1, 4), (2, 0), (3, 4)):
        y0 = row * 4
        for bx in range(-off, S, 8):
            base = jit((90, 140, 190), 8, rng)
            rect(im, bx + 1, y0 + 1, bx + 6, y0 + 2, base)
            rect(im, bx + 1, y0 + 1, bx + 6, y0 + 1, (170, 214, 244))
            put(im, bx + 2 + rng.randrange(3), y0 + 2, (220, 240, 255))
    return im


def door():
    im = wall()
    rect(im, 4, 3, 11, 15, (14, 22, 40))
    rect(im, 5, 2, 10, 2, (14, 22, 40))
    for x, ln in ((4, 3), (6, 2), (9, 4), (11, 2)):  # icicles over the arch
        rect(im, x, 3, x, 2 + ln, (200, 232, 252))
    return im


def ice():
    """Slick sheet ice: pale and bright, with long streaks that read as 'glide'."""
    rng = random.Random(53)
    im = tile((170, 214, 240))
    for y in range(S):
        for x in range(S):
            if (x + y) % 5 == 0:
                put(im, x, y, (190, 228, 250))
    for _ in range(3):
        y = rng.randrange(2, 14)
        x = rng.randrange(0, 6)
        rect(im, x, y, x + 7, y, (236, 248, 255))
    put(im, 12, 3, (255, 255, 255))
    put(im, 3, 11, (255, 255, 255))
    return im


if __name__ == '__main__':
    f = floor()
    tiles = [f, wall(), door(), rune(f, VIOLET), rune(f, CRIMSON), ice()]
    out = Image.new('RGBA', (S * len(tiles), S))
    for i, t in enumerate(tiles):
        out.paste(t, (i * S, 0))
    out.save(os.path.join(OUT, 'citadel_tiles.png'))
    print('citadel_tiles.png', out.size)
