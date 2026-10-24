"""The Blighted Reach's atlas (Act III, Milestone 28a), same 8 columns as
overworld_tiles.png: 0 ash  1 dead trees (wall)  2 gate  3 cracked road
4 the portal (void arch)  5 chasm (blocked)  6 bones  7 bridge.

Usage: python build_reach_tiles.py
"""
import random

from PIL import Image

from build_desert_tiles import BAYER, gate, strip
from build_dungeon_tiles import S, jit, put, rect, tile


def ash(seed=1):
    rng = random.Random(seed)
    im = tile()
    for y in range(S):
        for x in range(S):
            put(im, x, y, (92, 88, 96) if BAYER[y % 4][x % 4] > 6 else (104, 100, 108))
    for _ in range(6):
        put(im, rng.randrange(S), rng.randrange(S), (70, 66, 76))
    return im


def dead_trees():
    im = tile((40, 36, 44))
    for cx in (4, 11):
        rect(im, cx, 4, cx, 15, (70, 60, 56))
        for k, (dx, y) in enumerate(((-2, 6), (2, 8), (-3, 10), (2, 4))):
            rect(im, min(cx, cx + dx), y, max(cx, cx + dx), y, (70, 60, 56))
    return im


def road():
    rng = random.Random(3)
    im = tile((74, 70, 80))
    for y in range(S):
        for x in range(S):
            if BAYER[y % 4][x % 4] > 9:
                put(im, x, y, (86, 82, 92))
    for _ in range(3):  # cracks
        x, y = rng.randrange(2, 12), rng.randrange(2, 12)
        for i in range(4):
            put(im, x + i, y + (i % 2), (40, 36, 46))
    return im


def portal():
    im = ash(7)
    rect(im, 2, 2, 13, 15, (30, 24, 40))
    rect(im, 3, 3, 12, 15, (54, 44, 70))
    rect(im, 5, 5, 10, 15, (8, 4, 14))
    for x, y in ((6, 7), (9, 9), (7, 12), (8, 6)):
        put(im, x, y, (170, 80, 220))  # void glints
    return im


def chasm():
    im = tile((10, 6, 16))
    for x0, y0 in ((2, 4), (9, 10), (5, 13)):
        rect(im, x0, y0, x0 + 3, y0, (60, 30, 90))
    return im


def bones():
    im = ash(11)
    for x, y in ((3, 5), (11, 4), (7, 11)):
        rect(im, x, y, x + 3, y, (200, 196, 186))
        put(im, x, y - 1, (200, 196, 186))
        put(im, x + 3, y + 1, (200, 196, 186))
    return im


def bridge():
    im = chasm()
    rect(im, 3, 0, 12, 15, (90, 74, 60))
    for y in range(0, S, 3):
        rect(im, 3, y, 12, y, (60, 48, 40))
    return im


if __name__ == '__main__':
    strip([ash(), dead_trees(), gate(), road(), portal(), chasm(), bones(), bridge()], 'reach_tiles.png')
