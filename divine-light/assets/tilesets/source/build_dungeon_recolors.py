"""Act I dungeon tilesets as recolors of the Cathedral's (Milestones 20b-20d).

Each pixel of the Cathedral's floor / wall / door tiles is mapped by its
brightness onto a dungeon's own palette ramp (dark -> light), so the shapes and
detail stay while the mood changes. The captive and boss runes (tiles 3 and 4)
are copied unchanged, so they read the same in every dungeon. Placeholders for
the Act I art pass (Milestone 21).

Usage: python build_dungeon_recolors.py
"""
import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..')

# dark -> light
RAMPS = {
    'monastery': [(22, 12, 10), (70, 30, 24), (128, 52, 38), (170, 110, 70), (214, 176, 128), (240, 222, 190)],
}


def lerp(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def ramp_color(ramp, lum):
    f = lum * (len(ramp) - 1)
    i = min(int(f), len(ramp) - 2)
    return lerp(ramp[i], ramp[i + 1], f - i)


def build(name, ramp):
    src = Image.open(os.path.join(OUT, 'cathedral_tiles.png')).convert('RGBA')
    out = src.copy()
    px = out.load()
    for y in range(16):
        for x in range(48):  # floor, wall, door
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            lum = (0.3 * r + 0.59 * g + 0.11 * b) / 255.0
            lum = min(1.0, lum * 1.35)  # the stone is dark; spread it over the ramp
            px[x, y] = ramp_color(ramp, lum) + (a,)
    out.save(os.path.join(OUT, name + '_tiles.png'))
    print(name + '_tiles.png')


if __name__ == '__main__':
    for name, ramp in RAMPS.items():
        build(name, ramp)
