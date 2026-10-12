"""Tilesets for the Monastery, Observatory and Underground Guild (Milestone 21).

Each is the same 5-tile strip the Cathedral uses, in the order Dungeon.gd's
TAG_TO_COORDS expects: floor / wall / door / captive rune / boss rune ->
assets/tilesets/<id>_tiles.png (80x16). Floors and walls tile seamlessly
(every pattern repeats within 16px). The two runes are the Cathedral's
(violet captive, crimson boss), drawn onto each dungeon's own floor so they
read the same everywhere. Code-drawn, deterministic (fixed seeds).

Replaces build_dungeon_recolors.py (the 20b-20d placeholder recolors).

Usage: python build_dungeon_tiles.py [preview.png]
"""
import math
import os
import random
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..')
S = 16

VIOLET = ((168, 108, 232), (104, 60, 150), (222, 190, 250))
CRIMSON = ((196, 60, 60), (128, 32, 34), (240, 150, 130))
VEIN = (120, 64, 170)


def tile(color=None):
    return Image.new('RGBA', (S, S), (color + (255,)) if color else (0, 0, 0, 0))


def put(im, x, y, c):
    if 0 <= x < S and 0 <= y < S:
        im.putpixel((x, y), c + (255,))


def rect(im, x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            put(im, x, y, c)


def jit(c, n, rng):
    return tuple(max(0, min(255, v + rng.randint(-n, n))) for v in c)


def rune(floor, colors):
    """The Cathedral's rune (ring, eight spokes, glowing core) on `floor`."""
    glow, dim, core = colors
    im = floor.copy()
    cx = cy = 7.5
    r = 5.5
    for y in range(S):
        for x in range(S):
            d = math.hypot(x - cx, y - cy)
            if abs(d - r) < 0.75:
                put(im, x, y, glow)
            elif abs(d - r) < 1.4:
                put(im, x, y, dim)
            elif d < 1.6:
                put(im, x, y, core)
    for a in range(0, 360, 45):
        for k in range(2, int(r) - 1):
            put(im, int(round(cx + math.cos(math.radians(a)) * k)),
                int(round(cy + math.sin(math.radians(a)) * k)), dim)
    return im


# ================================================================ Monastery

def monastery_floor():
    """Warm floorboards, 4px boards with staggered seams and nail heads."""
    rng = random.Random(21)
    im = tile()
    for b in range(4):
        tone = jit((150, 96, 58), 8, rng)
        seam = (b * 7 + 3) % S
        for y in range(b * 4, b * 4 + 4):
            for x in range(S):
                c = tone if y % 4 else (92, 56, 32)       # gap between boards
                if y % 4 == 2 and (x * 5 + b) % 7 == 0:
                    c = jit(tone, 10, rng)                # grain
                put(im, x, y, c)
            put(im, seam, y, (92, 56, 32))                # board end
        put(im, (seam + 2) % S, b * 4 + 2, (70, 44, 28))  # nail
    put(im, 11, 6, VEIN)                                  # a knot gone violet
    put(im, 12, 6, (90, 50, 110))
    return im


def monastery_wall():
    """Paper screens in a dark wooden lattice; two panes torn, violet behind."""
    im = tile((232, 218, 186))
    for y in range(S):
        for x in range(S):
            if (x * 3 + y * 5) % 11 == 0:
                put(im, x, y, (220, 204, 170))            # paper fibre
    for k in (0, 5, 10, 15):
        rect(im, k, 0, k, 15, (78, 46, 30))               # verticals
    for k in (0, 7, 15):
        rect(im, 0, k, 15, k, (78, 46, 30))               # rails
    rect(im, 0, 0, 15, 0, (110, 66, 40))
    put(im, 12, 11, (150, 120, 150))                      # one small tear,
    put(im, 13, 12, (110, 70, 130))                       # violet showing through
    put(im, 12, 12, (200, 184, 150))
    return im


def monastery_door():
    """A temple gate: red-lacquered posts and lintel around a dark doorway."""
    im = monastery_wall()
    rect(im, 2, 3, 13, 15, (14, 10, 16))                  # doorway
    rect(im, 1, 3, 2, 15, (170, 52, 40))                  # posts
    rect(im, 13, 3, 14, 15, (128, 36, 30))
    rect(im, 0, 1, 15, 2, (190, 62, 46))                  # lintel
    rect(im, 0, 1, 15, 1, (214, 90, 64))
    rect(im, 0, 0, 0, 0, (128, 36, 30))
    rect(im, 15, 0, 15, 0, (128, 36, 30))
    put(im, 7, 2, (226, 186, 84))                         # brass plaque
    put(im, 8, 2, (226, 186, 84))
    return im


# ============================================================== Observatory

def observatory_floor():
    """Navy flagstones inlaid with brass star-chart lines and points."""
    rng = random.Random(31)
    im = tile()
    for by in range(2):
        for bx in range(2):
            tone = jit((44, 52, 86), 5, rng)
            for y in range(8):
                for x in range(8):
                    c = (26, 30, 52) if x == 0 or y == 0 else jit(tone, 3, rng)
                    put(im, bx * 8 + x, by * 8 + y, c)
    brass, dull = (204, 164, 84), (140, 108, 52)
    for x, y in [(3, 3), (12, 5), (5, 12), (13, 13)]:     # stars
        put(im, x, y, brass)
    for k in range(1, 9):                                 # a constellation line
        put(im, 3 + k, 3 + k // 4, dull)
    for k in range(1, 7):
        put(im, 5 + k, 12 - k // 3, dull)
    put(im, 9, 9, (180, 200, 240))                        # a pale glint
    return im


def observatory_wall():
    """Blue-grey ashlar with a riveted brass band across the middle."""
    rng = random.Random(32)
    im = tile()
    for course in range(2):
        off = 4 * course
        for y in range(course * 8, course * 8 + 8):
            for x in range(S):
                bi = ((x - off) % S) // 8
                c = (36, 40, 62) if y % 8 == 0 or (x - off) % 8 == 0 else \
                    jit((76, 84, 112), 4, random.Random(course * 10 + bi))
                put(im, x, y, c)
    rect(im, 0, 6, 15, 8, (186, 146, 70))                 # brass band
    rect(im, 0, 8, 15, 8, (128, 96, 44))
    rect(im, 0, 6, 15, 6, (224, 190, 110))
    for x in (2, 7, 12):
        put(im, x, 7, (110, 80, 36))                      # rivets
    put(im, 10, 12, VEIN)                                 # a void crack
    put(im, 11, 13, VEIN)
    return im


def observatory_door():
    """A domed archway framed in brass, the night sky inside."""
    im = observatory_wall()
    for y in range(2, S):
        for x in range(3, 13):
            if y < 5 and math.hypot(x - 7.5, y - 5.5) > 4.6:
                continue
            put(im, x, y, (8, 8, 22))
    for y in range(2, S):                                 # brass frame
        for x in range(2, 14):
            inside = not (y < 5 and math.hypot(x - 7.5, y - 5.5) > 4.6) and 3 <= x <= 12
            edge = math.hypot(x - 7.5, y - 5.5)
            if not inside and ((y < 6 and 4.6 < edge < 5.8) or (y >= 5 and x in (2, 13))):
                put(im, x, y, (204, 164, 84))
    for x, y in [(5, 6), (9, 4), (11, 9), (6, 11), (8, 8), (4, 13)]:
        put(im, x, y, (220, 226, 255))                    # stars
    return im


# ==================================================================== Guild

def guild_floor():
    """Wet cobbles: rounded stones in staggered rows, dark grout, a puddle glint."""
    rng = random.Random(41)
    im = tile((28, 32, 28))
    for row in range(2):
        off = 4 * row
        for k in range(2):
            x0 = (k * 8 + off) % S
            tone = jit((90, 96, 86), 8, rng)
            for y in range(row * 8, row * 8 + 7):
                for dx in range(0, 7):
                    if (dx in (0, 6)) and (y in (row * 8, row * 8 + 6)):
                        continue                          # rounded corners
                    c = tone
                    if y == row * 8 or dx == 0:
                        c = tuple(min(255, v + 22) for v in tone)   # lit top/left
                    elif y == row * 8 + 6 or dx == 6:
                        c = tuple(max(0, v - 22) for v in tone)     # shaded bottom/right
                    put(im, (x0 + dx) % S, y, c)
    put(im, 3, 3, (170, 178, 168))                        # wet glints
    put(im, 11, 12, (170, 178, 168))
    put(im, 8, 7, (60, 110, 70))                          # moss in the grout
    put(im, 0, 15, (60, 110, 70))
    return im


def guild_wall():
    """Rough cellar brick, small and dark, with moss creeping in."""
    rng = random.Random(42)
    im = tile()
    for row in range(4):
        off = 3 if row % 2 else 0
        for y in range(row * 4, row * 4 + 4):
            for x in range(S):
                bi = ((x - off) % S) // 6
                if y % 4 == 0 or (x - off) % 6 == 0:
                    c = (30, 24, 22)
                else:
                    c = jit((104, 62, 50), 6, random.Random(row * 10 + bi))
                put(im, x, y, c)
    for x, y in [(1, 14), (2, 15), (3, 15), (9, 13), (14, 2), (13, 3)]:
        put(im, x, y, (64, 112, 70))                      # moss
    put(im, 7, 6, VEIN)
    return im


def guild_door():
    """Vertical planks, two iron bands, a ring handle, in a brick frame."""
    im = guild_wall()
    for y in range(2, S):
        for x in range(3, 13):
            c = (110, 74, 46) if x % 3 else (76, 50, 32)
            put(im, x, y, c)
    rect(im, 3, 1, 12, 1, (76, 50, 32))
    for y in (4, 12):
        rect(im, 3, y, 12, y, (70, 72, 80))               # iron bands
        put(im, 4, y, (140, 142, 150))
        put(im, 11, y, (140, 142, 150))
    put(im, 10, 8, (140, 142, 150))                       # ring
    put(im, 10, 9, (70, 72, 80))
    put(im, 11, 9, (140, 142, 150))
    return im


SETS = {
    'monastery': (monastery_floor, monastery_wall, monastery_door),
    'observatory': (observatory_floor, observatory_wall, observatory_door),
    'guild': (guild_floor, guild_wall, guild_door),
}


if __name__ == '__main__':
    strips = {}
    for name, (floor, wall, door) in SETS.items():
        f = floor()
        tiles = [f, wall(), door(), rune(f, VIOLET), rune(f, CRIMSON)]
        out = Image.new('RGBA', (S * 5, S))
        for i, t in enumerate(tiles):
            out.paste(t, (i * S, 0))
        out.save(os.path.join(OUT, name + '_tiles.png'))
        strips[name] = tiles
        print(name + '_tiles.png')
    if len(sys.argv) > 1:
        # each set: the 5 tiles, then a 4x4 swatch of floor and wall to check seams
        rows = []
        for tiles in strips.values():
            row = Image.new('RGBA', (S * 5 + 4 + S * 8 + 4, S * 4), (60, 52, 70, 255))
            for i, t in enumerate(tiles):
                row.paste(t, (i * S, 0))
            for yy in range(4):
                for xx in range(4):
                    row.paste(tiles[0], (S * 5 + 4 + xx * S, yy * S))
                    row.paste(tiles[1], (S * 9 + 8 + xx * S, yy * S))
            rows.append(row)
        prev = Image.new('RGBA', (rows[0].width, sum(r.height + 4 for r in rows)), (60, 52, 70, 255))
        y = 0
        for r in rows:
            prev.paste(r, (0, y))
            y += r.height + 4
        prev.resize((prev.width * 4, prev.height * 4), Image.NEAREST).save(sys.argv[1])
