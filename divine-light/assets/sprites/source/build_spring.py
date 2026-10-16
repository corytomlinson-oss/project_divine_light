"""Healing spring (Milestone 23b): a round stone basin of glowing water.

Geometric, so it's built from distances rather than hand-placed rows. Three
16x16 frames, left to right: shimmer A, shimmer B (the sparkles swap - the
map flips between them), spent (the glow gone, dark still water).

Usage: python build_spring.py <out.png> [preview.png]
"""
import math
import sys

from PIL import Image

OUTLINE = (26, 20, 32, 255)
STONE_LIGHT = (176, 176, 188, 255)
STONE = (128, 128, 142, 255)
STONE_DARK = (84, 84, 100, 255)
WATER = (70, 160, 222, 255)
WATER_LIGHT = (140, 214, 250, 255)
SPARKLE = (244, 252, 255, 255)
SPENT = (36, 52, 72, 255)
SPENT_LIGHT = (56, 76, 98, 255)
SHADOW = (0, 0, 0, 70)

CX, CY = 7.5, 7.5
SPARKLES = [[(5, 5), (9, 8), (6, 10)], [(8, 5), (5, 8), (10, 10)]]


def frame(kind):
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    for y in range(16):
        for x in range(16):
            dx, dy = x - CX, (y - CY) * 1.15  # a touch squashed: seen from above at an angle
            r = math.hypot(dx, dy)
            if r <= 4.6:
                spent = kind == 'spent'
                light = dx + dy < -2.5
                im.putpixel((x, y), (SPENT_LIGHT if light else SPENT) if spent else (WATER_LIGHT if light else WATER))
            elif r <= 6.4:
                shade = dx + dy
                im.putpixel((x, y), STONE_LIGHT if shade < -3 else STONE_DARK if shade > 3 else STONE)
            elif r <= 7.3:
                im.putpixel((x, y), OUTLINE)
            elif y >= 13 and r <= 8.2:
                im.putpixel((x, y), SHADOW)
    if kind != 'spent':
        for x, y in SPARKLES[kind]:
            im.putpixel((x, y), SPARKLE)
    return im


def main():
    out = Image.new('RGBA', (48, 16), (0, 0, 0, 0))
    for i, kind in enumerate([0, 1, 'spent']):
        out.paste(frame(kind), (i * 16, 0))
    out.save(sys.argv[1])
    if len(sys.argv) > 2:
        out.resize((out.width * 8, out.height * 8), Image.NEAREST).save(sys.argv[2])


if __name__ == '__main__':
    main()
