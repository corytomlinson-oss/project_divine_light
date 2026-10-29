"""Nordveil's town atlas (Milestone 25b): the town atlas's 16 columns, so
Town.gd's letters work unchanged, wintered over - snow ground, snowy pines,
packed-snow road, a frozen pond and frost tufts from the tundra atlas, snow
on the roofs, frost on the cobbles. Everything else (walls, doors, signs,
fence, shrine) is the town atlas as-is.

  0 snow  1 pines  2 gate  3 road  4 wall  5 roof (snow-capped)  6 door
  7 frozen pond  8 fence  9 frost tufts  10 awning  11 inn sign wall
  12 cobbles (frosted)  13 shrine  14 item-shop sign wall  15 armory sign wall

Usage: python build_nordveil_tiles.py   (run build_tundra_tiles.py first)
"""
import os
import random

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..')
town = Image.open(os.path.join(OUT, 'town_tiles.png')).convert('RGBA')
tundra = Image.open(os.path.join(OUT, 'tundra_tiles.png')).convert('RGBA')


def col(im, i):
    return im.crop((16 * i, 0, 16 * i + 16, 16))


tiles = [col(town, i) for i in range(16)]
for town_col, tundra_col in ((0, 0), (1, 1), (2, 2), (3, 3), (7, 5), (9, 6)):
    tiles[town_col] = col(tundra, tundra_col)
def degrass(im, ground):
    """Grass showing behind a copied town tile (fence, stall) -> this town's ground."""
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a and g > r + 18 and g > b + 18:
                px[x, y] = ground
    return im


for i in range(4, 16):
    if i not in (7, 9):
        tiles[i] = degrass(tiles[i], (214, 224, 238, 255))
# snow on the roofs: a thick cap with a ragged lower edge
roof = tiles[5]
rng = random.Random(5)
for x in range(16):
    depth = 4 + rng.randrange(3)
    for y in range(depth):
        roof.putpixel((x, y), (236, 242, 250, 255) if y < depth - 1 else (196, 208, 228, 255))
# frost on the cobbles
cob = tiles[12]
for _ in range(22):
    x, y = rng.randrange(16), rng.randrange(16)
    cob.putpixel((x, y), (214, 226, 242, 255))
out = Image.new('RGBA', (256, 16))
for i, t in enumerate(tiles):
    out.paste(t, (16 * i, 0))
out.save(os.path.join(OUT, 'nordveil_tiles.png'))
print('wrote nordveil_tiles.png', out.size)
