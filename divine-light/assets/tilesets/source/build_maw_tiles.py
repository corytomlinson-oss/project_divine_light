"""The Blighted Maw's dungeon atlas (Act III, Milestone 28b): void stone,
living-dark walls, and one column for each kingdom's echo.

  maw_tiles.png  0 floor  1 wall  2 door  3/4 runes  5 ice  6 fire  7 water
  (Dungeon.DUNGEONS["blighted_maw"]["tile_columns"])

Usage: python build_maw_tiles.py
"""
import random

from build_citadel_tiles import ice
from build_coast_tiles import flood
from build_desert_tiles import fire_floor, strip
from build_dungeon_tiles import CRIMSON, S, VIOLET, jit, put, rect, rune, tile


def floor():
    rng = random.Random(81)
    im = tile((36, 30, 44))
    for by in (0, 8):
        for bx in (0, 8):
            rect(im, bx + 1, by + 1, bx + 6, by + 6, jit((52, 44, 62), 5, rng))
    for _ in range(4):
        put(im, rng.randrange(S), rng.randrange(S), (120, 60, 160))  # void veins
    return im


def wall():
    rng = random.Random(82)
    im = tile((18, 12, 24))
    for row, off in ((0, 0), (1, 4), (2, 0), (3, 4)):
        y0 = row * 4
        for bx in range(-off, S, 8):
            rect(im, bx + 1, y0 + 1, bx + 6, y0 + 2, jit((48, 34, 60), 6, rng))
    for _ in range(3):
        put(im, rng.randrange(S), rng.randrange(S), (170, 80, 220))
    return im


def door():
    im = wall()
    rect(im, 4, 3, 11, 15, (4, 2, 8))
    rect(im, 5, 2, 10, 2, (4, 2, 8))
    return im


if __name__ == "__main__":
    f = floor()
    strip([f, wall(), door(), rune(f, VIOLET), rune(f, CRIMSON), ice(), fire_floor(), flood()], "maw_tiles.png")
