"""Act I map tiles (Milestone 20a): extends the overworld atlas and builds
Verdance's town atlas. Code-drawn placeholders in the same style as the
Cathedral tiles; the Act I art pass (Milestone 21) can replace any of them.

The overworld's first three tiles (grass, tree hedge, wooden gate) are the
Retro Diffusion art from Milestone 16, copied in unchanged, so existing
atlas coordinates keep working.

  overworld_tiles.png  0 grass  1 trees  2 gate  3 road  4 stone arch
                       5 water  6 flowers  7 bridge (Milestone 23c: planks
                       across a north-south river, rails on the water sides)
  town_tiles.png       0 grass  1 trees  2 gate  3 road  4 wall (timber)
                       5 roof   6 door   7 water 8 fence 9 flowers
                       10 awning (Frank's stall)  11 inn sign wall
                       12 cobbles  13 shrine  14 item-shop sign wall
                       15 armory sign wall   (12-15: Edenmere, 20d)

Usage: python build_act1_tiles.py
"""
import os
import random

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..')
OW = os.path.join(HERE, 'overworld')
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def load16(name):
    return Image.open(os.path.join(OW, name)).convert('RGBA').resize((16, 16), Image.NEAREST)


GRASS = load16('grass_floor.png')
TREES = load16('tree_hedge_wall.png')
GATE = load16('wooden_gate_door.png')


def tile(base=None):
    return base.copy() if base is not None else Image.new('RGBA', (16, 16))


def rect(im, x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if 0 <= x < 16 and 0 <= y < 16:
                im.putpixel((x, y), c + (255,) if len(c) == 3 else c)


def road(seed=3):
    rng = random.Random(seed)
    im = tile()
    for y in range(16):
        for x in range(16):
            c = (148, 112, 72) if BAYER[y % 4][x % 4] > 3 else (136, 102, 64)
            im.putpixel((x, y), c + (255,))
    for _ in range(9):  # pebbles
        x, y = rng.randrange(16), rng.randrange(16)
        im.putpixel((x, y), (176, 142, 100, 255))
        if x + 1 < 16:
            im.putpixel((x + 1, y), (110, 82, 52, 255))
    return im


def arch():
    im = tile(GRASS)
    rect(im, 2, 3, 13, 15, (112, 108, 118))       # stone
    rect(im, 3, 4, 12, 15, (138, 134, 146))
    rect(im, 5, 6, 10, 15, (22, 18, 30))          # dark opening
    rect(im, 6, 5, 9, 5, (22, 18, 30))
    for x, y in ((3, 7), (12, 9), (3, 12), (12, 13), (7, 3), (9, 3)):
        im.putpixel((x, y), (92, 88, 100, 255))    # mortar
    rect(im, 2, 2, 13, 2, (92, 88, 100))
    return im


def water():
    im = tile()
    for y in range(16):
        for x in range(16):
            c = (58, 96, 160) if BAYER[y % 4][x % 4] > 5 else (70, 112, 176)
            im.putpixel((x, y), c + (255,))
    for x0, y in ((2, 4), (9, 9), (4, 13)):
        rect(im, x0, y, x0 + 3, y, (150, 190, 230))
    return im


def flowers():
    im = tile(GRASS)
    for x, y, c in ((3, 3, (240, 220, 120)), (11, 5, (230, 120, 150)), (6, 10, (240, 240, 250)),
                    (13, 12, (240, 220, 120)), (2, 13, (230, 120, 150))):
        im.putpixel((x, y), c + (255,))
        im.putpixel((x, y + 1), (60, 120, 60, 255))
    return im


def bridge():
    im = water()
    for y in range(2, 14):                          # deck: boards across the river
        for x in range(16):
            c = (96, 64, 40) if x % 4 == 3 else (156, 110, 64) if (x // 4) % 2 else (140, 98, 56)
            im.putpixel((x, y), c + (255,))
    for y0 in (1, 12):                              # rails, light top edge
        rect(im, 0, y0, 15, y0 + 1, (96, 64, 40))
        rect(im, 0, y0, 15, y0, (176, 128, 76))
    for x in (1, 8, 15):                            # posts
        rect(im, x, 0, x, 2, (78, 50, 30))
        rect(im, x, 12, x, 15, (78, 50, 30))
    return im


def wall():
    im = tile()
    rect(im, 0, 0, 15, 15, (214, 196, 160))        # plaster
    rect(im, 0, 0, 15, 1, (96, 64, 40))            # beams
    rect(im, 0, 14, 15, 15, (96, 64, 40))
    rect(im, 0, 0, 1, 15, (96, 64, 40))
    rect(im, 14, 0, 15, 15, (96, 64, 40))
    for k in range(2, 14):                          # diagonal brace
        im.putpixel((k, k), (110, 74, 46, 255))
    rect(im, 5, 5, 9, 8, (60, 70, 100))            # window
    rect(im, 7, 5, 7, 8, (96, 64, 40))
    rect(im, 5, 6, 9, 6, (96, 64, 40))
    return im


def roof():
    im = tile()
    for y in range(16):
        for x in range(16):
            row = y // 4
            shade = (168, 70, 52) if (x + row * 2) % 6 else (132, 50, 40)
            if y % 4 == 3:
                shade = (112, 40, 34)
            im.putpixel((x, y), shade + (255,))
    return im


def door():
    im = wall()
    rect(im, 4, 4, 11, 15, (96, 64, 40))
    rect(im, 5, 5, 10, 15, (140, 96, 58))
    for x in (7, 8):
        rect(im, x, 5, x, 15, (118, 80, 48))
    im.putpixel((9, 10), (230, 200, 120, 255))
    return im


def fence():
    im = tile(GRASS)
    for x in (1, 7, 13):
        rect(im, x, 4, x + 1, 13, (130, 92, 58))
        im.putpixel((x, 4), (170, 128, 84, 255))
    rect(im, 0, 6, 15, 6, (150, 108, 68))
    rect(im, 0, 10, 15, 10, (150, 108, 68))
    return im


def awning():
    im = tile(GRASS)  # the stall sits on grass: canopy on top, two posts below
    for y in range(16):
        for x in range(16):
            if y < 9:
                stripe = (220, 70, 70) if (x // 4) % 2 == 0 else (240, 230, 210)
                im.putpixel((x, y), stripe + (255,))
            elif x in (1, 14):
                im.putpixel((x, y), (96, 64, 40, 255))
    for x in range(0, 16, 4):  # scalloped edge
        rect(im, x, 8, x + 1, 8, (180, 50, 50))
    return im


def inn_sign():
    im = wall()
    rect(im, 3, 3, 12, 10, (96, 64, 40))
    rect(im, 4, 4, 11, 9, (200, 160, 90))
    rect(im, 6, 5, 8, 8, (240, 240, 230))          # a mug
    rect(im, 9, 6, 9, 7, (240, 240, 230))
    return im


def cobbles():
    im = tile()
    for y in range(16):
        for x in range(16):
            im.putpixel((x, y), (150, 146, 138, 255))
    for y0 in range(0, 16, 4):  # staggered stones with dark joints
        off = 0 if (y0 // 4) % 2 == 0 else 2
        rect(im, 0, y0 + 3, 15, y0 + 3, (104, 100, 96))
        for x in range(off, 16, 4):
            rect(im, x, y0, x, y0 + 2, (104, 100, 96))
            im.putpixel(((x + 1) % 16, y0), (178, 174, 166, 255))
    return im


def shrine():
    im = cobbles()  # a small stone altar with a steady light above it
    rect(im, 3, 9, 12, 14, (120, 118, 128))
    rect(im, 3, 9, 12, 9, (170, 168, 180))
    rect(im, 5, 11, 10, 12, (96, 94, 104))
    rect(im, 7, 2, 8, 7, (255, 240, 170))
    rect(im, 6, 4, 9, 5, (255, 240, 170))
    im.putpixel((7, 1), (255, 255, 220, 255))
    im.putpixel((8, 8), (255, 250, 200, 255))
    return im


def shop_sign():
    im = wall()
    rect(im, 3, 3, 12, 10, (96, 64, 40))
    rect(im, 4, 4, 11, 9, (200, 160, 90))
    rect(im, 7, 4, 8, 5, (240, 240, 230))          # a potion flask
    rect(im, 6, 6, 9, 9, (220, 60, 70))
    rect(im, 6, 6, 9, 6, (240, 240, 230))
    return im


def armory_sign():
    im = wall()
    rect(im, 3, 3, 12, 10, (96, 64, 40))
    rect(im, 4, 4, 11, 9, (200, 160, 90))
    for k in range(5, 10):                          # a sword, point up-right
        im.putpixel((k + 1, 13 - k), (220, 224, 235, 255))
    rect(im, 5, 7, 7, 7, (96, 64, 40))              # crossguard
    im.putpixel((5, 9), (96, 64, 40, 255))
    return im


def strip(tiles, name):
    out = Image.new('RGBA', (16 * len(tiles), 16))
    for i, t in enumerate(tiles):
        out.paste(t, (16 * i, 0))
    out.save(os.path.join(OUT, name))
    print(name, len(tiles), 'tiles')


if __name__ == '__main__':
    strip([GRASS, TREES, GATE, road(), arch(), water(), flowers(), bridge()], 'overworld_tiles.png')
    strip([GRASS, TREES, GATE, road(), wall(), roof(), door(), water(), fence(), flowers(), awning(), inn_sign(),
           cobbles(), shrine(), shop_sign(), armory_sign()], 'town_tiles.png')
