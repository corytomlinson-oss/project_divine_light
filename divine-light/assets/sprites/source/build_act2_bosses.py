"""Hand-placed battle sprites for Act II's three kingdom bosses (Milestone 27),
replacing their recolor stand-ins. Same machinery and format as
build_act1_bosses.py (its Canvas, outline, breathing frame 2, glow pulse):
48x48, 2-frame idle sheets facing right, assets/sprites/enemies/<slug>.png.

Usage: python build_act2_bosses.py <out_dir> [preview.png]
"""
from build_act1_bosses import WISPS, boss as _boss, build

ACT2 = {}
WISPS.update({'f', 'F', 'd', 'D'})  # embers and water drops float free


def boss(slug, breathe_row, glow, pal):
    return _boss(slug, breathe_row, glow, pal, registry=ACT2)


def blob(c, y0, rows, ch):
    """rows: [(x0, x1), ...] spans from y0 down."""
    for i, (x0, x1) in enumerate(rows):
        c.span(y0 + i, x0, x1, ch)


# ------------------------------------------------------------- Frozen Sovereign
# Nordveil's warlord: frost-plate armor, a horned ice crown, a ragged frost
# cape, and a great ice blade raised in his forward hand.
@boss('frozen_sovereign', 24, {'I': 'J', 'V': 'X'}, {
    'P': (196, 220, 244),   # plate light
    'p': (124, 156, 196),   # plate mid
    'o': (70, 96, 140),     # plate dark
    'I': (150, 220, 255),   # ice glow
    'J': (220, 248, 255),   # ice glow bright (pulse)
    'C': (60, 88, 140),     # cape
    'c': (38, 56, 96),      # cape shade
    'B': (210, 240, 255),   # blade light
    'b': (130, 190, 230),   # blade mid
    'e': (40, 200, 255),    # eyes
})
def frozen_sovereign(c):
    # cape behind, flaring left, ragged hem
    for y in range(14, 44):
        left = 15 - (y - 14) // 3
        c.span(y, max(2, left), 22, 'C' if y % 3 else 'c')
    for x in range(3, 22, 3):
        c.span(44, x, x + 1, 'c')
    # legs and greaves
    blob(c, 34, [(18, 23)] * 10, 'p')
    blob(c, 34, [(25, 30)] * 10, 'p')
    for y in (36, 40):
        c.span(y, 18, 23, 'P')
        c.span(y, 25, 30, 'P')
    c.span(44, 16, 23, 'o')
    c.span(44, 25, 32, 'o')
    # torso plate, broad shoulders
    blob(c, 16, [(16, 32), (14, 34), (14, 34), (15, 33), (16, 32), (16, 32), (17, 31),
                 (17, 31), (17, 31), (17, 31), (18, 30), (18, 30), (17, 31), (17, 31),
                 (18, 30), (18, 30), (18, 30), (18, 30)], 'p')
    for y in range(17, 33, 3):
        c.span(y, 20, 28, 'P')
    c.put(23, 20, 'II')
    c.put(22, 21, 'IIII')
    c.put(23, 22, 'II')
    # pauldrons with icy spikes
    blob(c, 14, [(11, 17), (10, 18), (11, 17)], 'P')
    blob(c, 14, [(31, 37), (30, 38), (31, 37)], 'P')
    c.put(12, 12, 'I'); c.put(13, 11, 'I'); c.put(35, 12, 'I'); c.put(34, 11, 'I')
    # head: closed helm, glowing eyes, horned ice crown
    blob(c, 6, [(21, 27), (20, 28), (20, 28), (20, 28), (21, 27), (21, 27), (22, 26), (22, 26)], 'o')
    c.span(9, 22, 26, 'K')
    c.put(23, 9, 'e'); c.put(25, 9, 'e')
    c.put(19, 3, 'I'); c.put(19, 4, 'I'); c.put(20, 5, 'I')
    c.put(29, 3, 'I'); c.put(29, 4, 'I'); c.put(28, 5, 'I')
    c.put(22, 2, 'I'); c.put(24, 1, 'I'); c.put(26, 2, 'I')
    c.span(5, 21, 27, 'I')
    # forward arm raising the great ice blade
    blob(c, 18, [(33, 36), (34, 37), (35, 38), (36, 39)], 'p')
    c.span(16, 37, 40, 'o')
    for y in range(0, 17):
        c.span(y, 39, 41, 'b')
        c.put(40, y, 'B')
    c.span(16, 36, 43, 'P')


# ------------------------------------------------------------- Burning Tyrant
# Duskara's sorcerer-king: layered robes in ember and gold, a crown of flame,
# a staff topped with a burning orb, and embers drifting around him.
@boss('burning_tyrant', 22, {'F': 'Y', 'f': 'F', 'R': 'Y'}, {
    'G': (236, 190, 80),    # gold
    'g': (168, 116, 40),    # gold dark
    'M': (170, 40, 30),     # robe
    'm': (110, 22, 20),     # robe shade
    'n': (70, 14, 14),      # robe deep
    'k': (60, 36, 24),      # staff wood
    'R': (255, 120, 30),    # flame
    'F': (255, 190, 60),    # flame bright
    'Y': (255, 245, 170),   # flame white (pulse)
    'f': (255, 140, 40),    # ember
    's': (196, 150, 110),   # skin
})
def burning_tyrant(c):
    # robes: a wide bell flaring to the floor
    for y in range(18, 46):
        half = 6 + (y - 18) // 2
        c.span(y, 24 - half, 24 + half, 'M' if (y // 2) % 3 else 'm')
    for y in range(20, 46, 2):
        c.put(24, y, 'g')
    c.span(45, 10, 38, 'n')
    for x in range(11, 38, 4):
        c.put(x, 44, 'G')  # gold hem
    # sash and chest
    blob(c, 16, [(18, 30), (17, 31), (17, 31)], 'm')
    c.span(24, 15, 33, 'G')
    c.span(25, 15, 33, 'g')
    # shoulders / mantle
    blob(c, 13, [(16, 32), (14, 34), (13, 35)], 'G')
    blob(c, 16, [(13, 16), (32, 35)], 'g')
    # head: hood shadow, burning eyes, crown of flame
    blob(c, 5, [(20, 28), (19, 29), (19, 29), (19, 29), (20, 28), (21, 27), (21, 27), (22, 26)], 'n')
    c.span(9, 21, 27, 's')
    c.span(8, 22, 26, 'K')
    c.put(22, 8, 'F'); c.put(26, 8, 'F')
    for x, h in ((20, 3), (22, 4), (24, 5), (26, 4), (28, 3)):
        for k in range(h):
            c.put(x, 4 - k, 'R' if k < h - 1 else 'F')
    c.span(4, 20, 28, 'G')
    # staff in the forward hand, burning orb on top
    for y in range(6, 46):
        c.put(37, y, 'k')
    blob(c, 1, [(35, 39), (34, 40), (34, 40), (35, 39)], 'R')
    blob(c, 2, [(36, 38), (36, 38)], 'F')
    blob(c, 26, [(33, 37), (34, 38)], 's')
    # embers drifting (float free, no outline)
    for x, y in ((8, 20), (6, 30), (41, 22), (43, 34), (10, 12), (40, 12), (5, 40)):
        c.put(x, y, 'f')


# ------------------------------------------------------------- Drowned Admiral
# Selavon's commander: a waterlogged greatcoat, a tricorn hat, barnacles and
# weed, a raised cutlass, eyes glowing like deep-sea lights, water dripping.
@boss('drowned_admiral', 24, {'E': 'e', 'D': 'd'}, {
    'N': (40, 66, 96),      # coat
    'n': (24, 42, 66),      # coat shade
    'H': (30, 34, 44),      # hat
    'G': (210, 180, 90),    # brass / trim
    'w': (60, 120, 80),     # seaweed
    'B': (200, 200, 190),   # barnacles
    'S': (150, 200, 196),   # drowned skin
    's': (96, 140, 140),    # skin shade
    'C': (214, 222, 232),   # cutlass light
    'c': (130, 140, 156),   # cutlass dark
    'E': (120, 255, 220),   # eyes
    'e': (220, 255, 245),   # eyes bright (pulse)
    'D': (120, 190, 230),   # water drop
    'd': (190, 230, 255),   # water drop bright
})
def drowned_admiral(c):
    # greatcoat: long, split tails
    for y in range(16, 45):
        half = 7 + (y - 16) // 4
        c.span(y, 24 - half, 24 + half, 'N' if y % 4 else 'n')
    c.span(44, 16, 22, 'n')
    c.span(44, 26, 32, 'n')
    for y in range(30, 45):
        c.put(24, y, '.')  # the split between the tails
    # brass buttons and trim, a sash of weed
    for y in range(18, 30, 3):
        c.put(21, y, 'G'); c.put(27, y, 'G')
    for y in range(16, 30):
        c.put(24, y, 'n')
    for x, y in ((18, 20), (19, 21), (20, 22), (28, 24), (29, 25), (17, 33), (31, 36)):
        c.put(x, y, 'w')
    for x, y in ((16, 26), (31, 20), (20, 38), (29, 41), (17, 31)):
        c.put(x, y, 'B')
    # epaulettes
    blob(c, 14, [(14, 19), (13, 19)], 'G')
    blob(c, 14, [(29, 34), (29, 35)], 'G')
    # head: drowned face, glowing eyes, tricorn
    blob(c, 7, [(20, 28), (20, 28), (20, 28), (21, 27), (21, 27), (22, 26)], 'S')
    c.span(11, 21, 27, 's')
    c.put(22, 9, 'E'); c.put(26, 9, 'E')
    c.span(12, 22, 26, 'w')  # a weed-tangled beard
    blob(c, 2, [(18, 30), (16, 32), (15, 33), (17, 31)], 'H')
    c.span(5, 15, 33, 'G')
    c.put(24, 2, 'G')
    # forward arm, cutlass raised
    blob(c, 18, [(33, 36), (34, 37), (35, 38)], 'N')
    c.span(16, 36, 40, 'G')
    for y in range(2, 16):
        x = 39 + (16 - y) // 5
        c.put(x, y, 'C')
        c.put(x + 1, y, 'c')
    # water dripping off him (floats free)
    for x, y in ((14, 30), (12, 40), (34, 42), (36, 30), (18, 46), (30, 46)):
        c.put(x, y, 'D')


if __name__ == '__main__':
    build(ACT2)
