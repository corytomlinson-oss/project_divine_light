"""Hand-placed battle sprite for Vorath, the Architect (Milestone 30),
replacing the Shadow Lord recolor stand-in from 28c. Same machinery and
format as build_act1_bosses.py (Canvas, outline, glow pulse), but 64x64 -
the final boss stands a head taller than every other enemy. 2-frame idle
sheet facing right, assets/sprites/enemies/vorath.png. He floats: frame 2
lifts the whole sprite 1px, his eyes and threads pulse, and the stars inside
his robe twinkle.

Usage: python build_act3_bosses.py <out_dir> [preview.png]
"""
import math

from build_act1_bosses import WISPS, boss as _boss, build

ACT3 = {}
WISPS.update({'T', 't'})  # the threads of the Unraveling float free


def boss(slug, breathe_row, glow, pal, size):
    return _boss(slug, breathe_row, glow, pal, size=size, registry=ACT3)


# ------------------------------------------------------------- Vorath
# Once one of the four pure souls of an older age (README "The Antagonist").
# A hooded titan whose robe is a hole in the world full of stars; a halo of
# gold, broken; a crown of shattered light. One hand raised with a void orb,
# the other reaching for the party, trailing the threads of the Unraveling.
@boss('vorath', None, {'E': 'e', 'T': 't', 't': 'T', 'S': 's', 's': 'S', 'V': 'X', 'H': 'G'}, {
    'R': (34, 18, 52),      # robe
    'r': (18, 10, 30),      # robe deep
    'M': (66, 36, 96),      # robe light / hood rim
    'S': (255, 255, 255),   # star
    's': (150, 130, 210),   # dim star
    'H': (232, 196, 108),   # halo gold
    'G': (255, 236, 170),   # halo gold bright (pulse)
    'h': (140, 104, 50),    # halo dark
    'F': (206, 196, 228),   # pale hands
    'f': (140, 128, 170),   # hand shade
    'E': (255, 70, 190),    # eyes
    'e': (255, 150, 225),   # eyes bright (pulse)
    'T': (180, 80, 250),    # thread
    't': (240, 190, 255),   # thread bright
    'n': (6, 2, 12),        # the void under the hood
}, size=(64, 64))
def vorath(c):
    cx = 27
    # the broken halo behind the head: a ring with three bites missing
    for a in range(0, 360, 4):
        if 40 <= a <= 64 or 150 <= a <= 170 or 280 <= a <= 296:
            continue
        rad = math.radians(a)
        x, y = cx + 13 * math.cos(rad), 15 + 11 * math.sin(rad)
        c.put(int(round(x)), int(round(y)), 'H' if a % 12 else 'h')
    # robe: a bell from the shoulders, the hem dissolving into wisps
    for y in range(22, 58):
        half = 9 + (y - 22) * 13 // 35
        c.span(y, cx - half, cx + half, 'R')
        for fold in (-2, 2):  # folds fanning out from the chest
            c.put(cx + fold * (y - 14) // 5, y, 'r')
    for x in range(cx - 21, cx + 22):
        drop = (x * 7) % 5
        for y in range(58, 58 + drop):
            c.put(x, y, 'r')
        if x % 3 == 0:
            c.put(x, 59 + drop, 'w')
            if x % 6 == 0:
                c.put(x + 1, 61 + drop // 2, 'x')
    # the robe's edges catch a little light
    for y in range(24, 58, 2):
        half = 9 + (y - 22) * 13 // 35
        c.put(cx - half, y, 'M')
        c.put(cx + half, y, 'M')
    # stars inside the robe (a fixed scatter)
    for i in range(46):
        x = cx - 16 + (i * 37) % 33
        y = 27 + (i * 23) % 30
        half = 9 + (y - 22) * 13 // 35
        if abs(x - cx) < half - 1:
            c.put(x, y, 'S' if i % 3 == 0 else 's')
    # a sigil of the Unraveling on the chest
    c.put(cx - 2, 27, 'V   V')
    c.put(cx - 1, 28, 'V V')
    c.put(cx, 29, 'V')
    c.put(cx - 1, 30, 'V V')
    # mantle across wide shoulders
    for i, (x0, x1) in enumerate([(cx - 11, cx + 11), (cx - 14, cx + 14), (cx - 15, cx + 15), (cx - 14, cx + 14)]):
        c.span(20 + i, x0, x1, 'M' if i < 2 else 'R')
    # the hood, a void inside it, two eyes
    for i, (x0, x1) in enumerate([(cx - 3, cx + 3), (cx - 5, cx + 5), (cx - 6, cx + 6), (cx - 6, cx + 6),
                                  (cx - 7, cx + 7), (cx - 7, cx + 7), (cx - 7, cx + 7), (cx - 6, cx + 6),
                                  (cx - 6, cx + 6), (cx - 5, cx + 5), (cx - 5, cx + 5), (cx - 4, cx + 4)]):
        c.span(9 + i, x0, x1, 'M' if i < 2 else 'R')
    for i, (x0, x1) in enumerate([(cx - 3, cx + 3), (cx - 4, cx + 4), (cx - 4, cx + 4), (cx - 4, cx + 4),
                                  (cx - 3, cx + 3), (cx - 3, cx + 3), (cx - 2, cx + 2)]):
        c.span(12 + i, x0, x1, 'n')
    c.put(cx - 2, 15, 'E')
    c.put(cx + 2, 15, 'E')
    # a crown of shattered light above the hood
    for x, hgt in ((cx - 6, 2), (cx - 3, 4), (cx, 6), (cx + 3, 4), (cx + 6, 2)):
        for k in range(hgt):
            c.put(x, 8 - k, 'H' if k < hgt - 1 else 'G')
    # far arm raised high, a void orb over the open hand
    for i in range(10):
        c.span(22 - i, cx - 16 - i // 2, cx - 13 - i // 2, 'R' if i % 3 else 'M')
    c.span(12, cx - 22, cx - 19, 'F')
    c.span(11, cx - 22, cx - 20, 'F')
    c.put(cx - 22, 10, 'f f')
    for y, (x0, x1) in zip(range(3, 9), [(cx - 22, cx - 20), (cx - 23, cx - 19), (cx - 24, cx - 18),
                                         (cx - 24, cx - 18), (cx - 23, cx - 19), (cx - 22, cx - 20)]):
        c.span(y, x0, x1, 'r')
    c.put(cx - 22, 5, 'VXV')
    c.put(cx - 21, 4, 'V')
    c.put(cx - 21, 6, 'V')
    # near arm reaching toward the party
    for i in range(12):
        c.span(24 + i // 3, cx + 13 + i, cx + 14 + i, 'R' if i % 4 else 'M')
        c.put(cx + 13 + i, 28 + i // 3, 'r')
    c.span(27, cx + 26, cx + 28, 'F')
    c.span(28, cx + 26, cx + 29, 'F')
    c.span(29, cx + 26, cx + 28, 'f')
    # the threads of the Unraveling, streaming from his fingers
    # (three strands fanning out forward and down toward the party)
    for k, slope in enumerate((-0.3, 0.3, 0.9)):
        prev = 28
        for x in range(cx + 29, 64):
            d = x - (cx + 29)
            y = 28 + int(round(slope * d + 1.2 * math.sin((d + k * 4) / 2.5)))
            for yy in range(min(prev, y), max(prev, y) + 1):  # keep the strand unbroken
                c.put(x, yy, 'T' if (d + k) % 4 else 't')
            prev = y
    # loose threads drifting around him
    for x, y in ((8, 30), (6, 40), (10, 48), (56, 44), (58, 52), (12, 20), (52, 14)):
        c.put(x, y, 'T')


if __name__ == '__main__':
    build(ACT3)
