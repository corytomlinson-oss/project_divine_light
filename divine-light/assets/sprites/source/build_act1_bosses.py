"""Hand-placed battle sprites for Act I's four dungeon bosses and three escape
wardens (Milestone 21).

Same output as build_enemies.py: a 2-frame idle sheet per boss, frames side
by side, 48x48 each like the Hollow Warden, facing right (toward the party):
assets/sprites/enemies/<slug>.png. Frame 2 breathes (everything above a row
sinks 1px; a floating boss rises 1px instead) and pulses the glow colors.

These are bigger than the Milestone 16 enemies, so each is drawn on a small
canvas: the large plates (cape, shield, armor) are placed as hand-picked
spans row by row, the details (visor, emblem, cracks, glow) pixel by pixel,
and the dark outline is added around the whole silhouette at the end.
Characters in WISPS float free (aura motes) and get no outline.

Usage: python build_act1_bosses.py <out_dir> [preview.png]
"""
import os
import sys

from PIL import Image

W = H = 48

BASE = {
    '.': None,
    'K': (26, 20, 32),      # outline
    'V': (170, 80, 220),    # corruption glow
    'v': (96, 40, 140),     # corruption glow dark
    'X': (220, 150, 255),   # corruption glow bright (frame-2 pulse)
    'w': (150, 70, 200),    # aura wisp
    'x': (210, 140, 250),   # aura wisp bright
}
WISPS = {'w', 'x', 'q', 'Q', 'i', 'I', 'y', 'Y'}  # also the Archmage's elemental motes


class Canvas:
    def __init__(self):
        self.g = [['.'] * W for _ in range(H)]

    def put(self, x, y, s):
        """Writes s starting at (x, y); spaces leave what's underneath."""
        for i, ch in enumerate(s):
            if ch != ' ' and 0 <= x + i < W and 0 <= y < H:
                self.g[y][x + i] = ch

    def span(self, y, x0, x1, ch):
        self.put(x0, y, ch * (x1 - x0 + 1))

    def outline(self):
        src = [row[:] for row in self.g]
        for y in range(H):
            for x in range(W):
                if src[y][x] != '.':
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < W and 0 <= ny < H and src[ny][nx] not in ('.', 'K') and src[ny][nx] not in WISPS:
                        self.g[y][x] = 'K'
                        break

    def rows(self):
        return [''.join(r) for r in self.g]


BOSSES = {}


def boss(slug, breathe_row, glow, pal):
    def register(draw):
        c = Canvas()
        draw(c)
        c.outline()
        BOSSES[slug] = dict(rows=c.rows(), split=breathe_row, glow=glow, pal=dict(BASE, **pal))
        return draw
    return register


# ------------------------------------------------------------- Fallen Guardian
# The Cathedral's boss: a holy knight gone wrong. Tarnished gold plate, a
# great helm with a violet visor, a stained tabard with a cracked sun, a kite
# shield on the far arm and a greatsword planted point-down in front.
@boss('fallen_guardian', 26, {'V': 'X', 'w': 'x'}, {
    'A': (222, 186, 98),    # gold light
    'a': (174, 136, 62),    # gold mid
    'd': (112, 82, 40),     # gold dark
    'T': (214, 206, 186),   # tabard / shield field
    't': (150, 140, 128),   # tabard shade
    'C': (104, 32, 52),     # cape
    'c': (66, 20, 36),      # cape shade
    'S': (204, 210, 224),   # blade light
    's': (122, 130, 152),   # blade dark
    'g': (60, 44, 34),      # grip leather
})
def fallen_guardian(c):
    # cape behind, flaring out to the left and down, ragged hem
    for y in range(13, 42):
        left = 17 - (y - 13) // 4
        c.span(y, left, 20, 'C')
        c.put(left, y, 'c')
    for x, drop in [(10, 1), (12, 2), (14, 0), (16, 2), (18, 1)]:
        for k in range(drop):
            c.put(x, 42 + k, 'c')
    # kite shield on the far arm
    shield = [  # (y, x0, x1)
        (16, 5, 16), (17, 4, 17), (18, 4, 17), (19, 4, 17), (20, 4, 17), (21, 4, 17),
        (22, 4, 17), (23, 4, 17), (24, 4, 17), (25, 4, 17), (26, 5, 16), (27, 5, 16),
        (28, 6, 15), (29, 6, 15), (30, 7, 14), (31, 7, 14), (32, 8, 13), (33, 9, 12),
        (34, 10, 11),
    ]
    for y, x0, x1 in shield:
        c.span(y, x0, x1, 'T')
        c.put(x0, y, 'a')
        c.put(x1, y, 'd')
    c.span(16, 5, 16, 'A')
    for y, x0, x1 in shield[1:]:
        c.put(x0 + 1, y, 't')
    # the cracked sun on the shield
    c.put(9, 19, ' AAA ')
    c.put(8, 20, 'AAaAA')
    c.put(7, 21, 'AAaVaA')
    c.put(8, 22, 'AAVAA')
    c.put(9, 23, 'VAA')
    c.put(8, 24, 'V')
    c.put(7, 25, 'v')
    for x, y in [(6, 19), (13, 19), (6, 24), (13, 24), (10, 17), (10, 26)]:
        c.put(x, y, 'a')  # rays
    # violet plume
    c.put(23, 0, 'vV')
    c.put(22, 1, 'vVX')
    c.put(21, 2, 'vVVV')
    # great helm
    helm = [(3, 20, 27), (4, 19, 28), (5, 19, 28), (6, 19, 28), (7, 19, 28),
            (8, 19, 28), (9, 19, 28), (10, 20, 27), (11, 21, 26)]
    for y, x0, x1 in helm:
        c.span(y, x0, x1, 'a')
        c.put(x0, y, 'A')
        c.put(x1, y, 'd')
    c.span(3, 21, 25, 'A')
    c.span(4, 20, 24, 'A')
    c.put(22, 6, 'dddddd')      # visor
    c.put(22, 7, 'dVXVdV')
    c.put(22, 8, 'dddddd')
    c.put(23, 9, 'V')           # a crack running down from the visor
    c.put(22, 10, 'V')
    c.span(12, 21, 26, 'd')     # gorget
    # back pauldron (behind the body, partly hidden)
    for y, x0, x1 in [(13, 15, 20), (14, 14, 20), (15, 14, 20), (16, 14, 20), (17, 15, 20)]:
        c.span(y, x0, x1, 'a')
        c.put(x0, y, 'd')
    # breastplate + tabard
    for y in range(13, 26):
        c.span(y, 19, 29, 'a')
        c.put(19, y, 'd')
        c.put(29, y, 'A')
    for y in range(15, 33):
        x0, x1 = (21, 27) if y < 26 else (20, 28)
        c.span(y, x0, x1, 'T')
        c.put(x0, y, 't')
    c.put(23, 17, 'AA')         # small sun on the tabard, cracked
    c.put(22, 18, 'AVAA')
    c.put(23, 19, 'VA')
    c.put(24, 21, 'v')
    c.put(23, 22, 'V')
    c.put(24, 23, 'v')
    c.span(26, 19, 29, 'd')     # sword belt
    c.put(23, 26, 'AA')
    for y in range(27, 33):     # faulds either side of the tabard
        c.put(18, y, 'da')
        c.put(28, y, 'aA')
    for x in (20, 22, 24, 26, 28):  # ragged tabard hem
        c.put(x, 33, 't')
    # legs
    for y in range(33, 44):
        c.span(y, 19, 22, 'a')
        c.put(19, y, 'd')
        c.span(y, 25, 28, 'a')
        c.put(28, y, 'A')
    for y in (36, 37):
        c.span(y, 19, 22, 'A')  # knee cops
        c.span(y, 25, 28, 'A')
    c.put(21, 39, 'V')          # corruption seeping through the greaves
    c.put(26, 41, 'V')
    c.span(44, 18, 23, 'd')     # sabatons
    c.span(44, 25, 30, 'd')
    c.span(45, 18, 23, 'a')
    c.span(45, 25, 31, 'a')
    # front pauldron
    for y, x0, x1 in [(12, 27, 32), (13, 26, 34), (14, 26, 35), (15, 26, 35), (16, 27, 35), (17, 28, 34)]:
        c.span(y, x0, x1, 'a')
        c.put(x1, y, 'd')
    c.span(13, 27, 32, 'A')
    c.put(30, 15, 'V')
    # front arm down to the hands on the pommel
    for y in range(18, 23):
        c.span(y, 31, 34, 'a')
        c.put(34, y, 'd')
    c.span(23, 32, 37, 'A')     # gauntlets
    c.span(24, 32, 37, 'a')
    # greatsword, point down
    c.put(34, 21, 'dd')         # pommel above the hands
    c.put(34, 22, 'gg')
    c.span(25, 31, 38, 'A')     # crossguard
    c.put(31, 25, 'd')
    c.put(38, 25, 'd')
    for y in range(26, 43):
        c.put(33, y, 'sSs')     # blade with a bright fuller
    c.put(33, 43, 'sSs')
    c.put(34, 44, 'S')
    c.put(34, 45, 's')
    c.put(34, 30, 'V')          # a violet vein running down the steel
    c.put(34, 31, 'V')
    c.put(33, 35, 'v')
    c.put(34, 36, 'V')
    # tarnish and corruption: dark patches on the plate, stains on the tabard
    for x, y, ch in [(20, 14, 'd'), (21, 20, 'd'), (28, 21, 'd'), (20, 24, 'V'), (28, 17, 'v'),
                     (29, 19, 'V'), (19, 29, 'v'), (32, 16, 'd'), (33, 14, 'd'), (31, 19, 'v'),
                     (16, 15, 'v'), (20, 40, 'd'), (27, 38, 'd'), (21, 42, 'v')]:
        c.put(x, y, ch)
    c.put(22, 28, 'tt')
    c.put(25, 30, 'ttt')
    c.put(21, 31, 'v')
    c.put(26, 25, 'v')
    # aura wisps
    for x, y in [(12, 6), (38, 9), (41, 17), (3, 30), (40, 33), (16, 2)]:
        c.put(x, y, 'w')


# ------------------------------------------------------- Corrupted Grandmaster
# The Monastery's boss: an old master whose discipline the Unraveling twisted.
# Bald, long white beard, torn terracotta robes and prayer beads, caught
# mid-strike in a wide stance; corrupted ki burns violet around both fists
# and seeps through cracks in the skin.
@boss('corrupted_grandmaster', 25, {'V': 'X', 'w': 'x'}, {
    'F': (212, 168, 128),   # skin
    'f': (156, 110, 82),    # skin shade
    'b': (234, 230, 218),   # beard
    'B': (168, 164, 158),   # beard shade
    'O': (198, 112, 52),    # robe
    'o': (134, 68, 36),     # robe shade
    'r': (82, 40, 28),      # trousers / wraps
    'n': (72, 46, 84),      # sash
    'p': (120, 76, 42),     # prayer beads
})
def corrupted_grandmaster(c):
    # back leg, stretched out behind (left)
    for y, x0, x1 in [(32, 15, 21), (33, 14, 20), (34, 13, 19), (35, 12, 18), (36, 11, 17),
                      (37, 10, 16), (38, 10, 15), (39, 9, 14), (40, 9, 13), (41, 8, 13), (42, 8, 12)]:
        c.span(y, x0, x1, 'r')
        c.put(x0, y, 'o')
    c.span(43, 6, 12, 'F')      # bare back foot
    c.span(44, 5, 12, 'f')
    # front leg, bent forward (right)
    for y, x0, x1 in [(32, 24, 30), (33, 25, 31), (34, 26, 32), (35, 27, 33), (36, 28, 33),
                      (37, 28, 33), (38, 29, 33), (39, 29, 33), (40, 29, 33), (41, 29, 33), (42, 29, 33)]:
        c.span(y, x0, x1, 'r')
        c.put(x1, y, 'o')
    c.span(38, 29, 33, 'n')     # shin wraps
    c.span(40, 29, 33, 'n')
    c.span(43, 29, 36, 'F')     # bare front foot
    c.span(44, 29, 37, 'f')
    # robe skirt, torn, flaring over the hips
    for y, x0, x1 in [(25, 17, 30), (26, 16, 31), (27, 15, 31), (28, 15, 32), (29, 14, 32),
                      (30, 14, 32), (31, 14, 31)]:
        c.span(y, x0, x1, 'O')
        c.put(x0, y, 'o')
        c.put(x0 + 1, y, 'o')
    for x, drop in [(14, 2), (16, 1), (19, 3), (22, 1), (27, 2), (30, 1)]:
        for k in range(drop):
            c.put(x, 32 + k, 'o')
    c.put(23, 27, 'oo')         # the split between the legs
    c.put(23, 28, 'o.o')
    c.put(23, 29, '...')
    c.put(23, 30, '...')
    c.put(23, 31, '...')
    # torso: robe leaning into the punch
    for y, x0, x1 in [(13, 20, 28), (14, 19, 29), (15, 19, 29), (16, 18, 29), (17, 18, 29),
                      (18, 18, 29), (19, 17, 29), (20, 17, 29), (21, 17, 29), (22, 17, 30),
                      (23, 17, 30), (24, 17, 30)]:
        c.span(y, x0, x1, 'O')
        c.put(x0, y, 'o')
    for y in range(13, 22):     # robe hangs open: chest and the skin crack
        c.span(y, 25, 28, 'F')
        c.put(25, y, 'f')
    c.put(27, 16, 'V')
    c.put(26, 17, 'V')
    c.put(27, 18, 'v')
    c.span(23, 17, 30, 'n')     # sash
    c.span(24, 17, 30, 'n')
    c.put(18, 24, 'nn')
    c.put(17, 25, 'n')          # sash tail
    c.put(16, 26, 'n')
    # prayer beads across the chest
    for x, y in [(21, 13), (22, 14), (23, 15), (24, 16), (25, 17), (26, 18), (27, 19), (28, 20)]:
        c.put(x, y, 'p')
    c.put(28, 21, 'V')          # the bead that's gone violet
    # back arm, fist pulled to the hip
    for y, x0, x1 in [(14, 17, 20), (15, 16, 19), (16, 16, 19), (17, 15, 18), (18, 15, 18), (19, 15, 18)]:
        c.span(y, x0, x1, 'o')
        c.put(x1, y, 'O')
    c.span(20, 14, 18, 'F')     # fist chambered at the hip
    c.span(21, 14, 18, 'F')
    c.span(22, 14, 18, 'f')
    c.put(15, 20, 'f f')        # knuckles
    c.put(12, 19, 'v')          # ki licking around it
    c.put(12, 20, 'VX')
    c.put(11, 21, 'VXV')
    c.put(12, 22, 'VV')
    c.put(13, 23, 'v')
    # front arm: bare, wiry, thrown forward
    for y, x0, x1 in [(13, 29, 32), (14, 29, 35), (15, 30, 36), (16, 31, 36)]:
        c.span(y, x0, x1, 'F')
    c.span(16, 31, 36, 'f')
    c.put(32, 14, 'V')          # cracks up the forearm
    c.put(34, 15, 'V')
    c.put(30, 13, 'f')
    c.span(12, 37, 41, 'F')     # the fist, big and square
    c.span(13, 37, 41, 'F')
    c.span(14, 37, 41, 'F')
    c.span(15, 37, 41, 'f')
    c.span(16, 37, 41, 'f')
    c.put(41, 12, 'f')
    c.put(41, 14, 'f')
    c.put(37, 12, 'fff')        # curled fingers
    # corrupted ki bursting off the fist
    for x, y, t in [(42, 11, 'v'), (42, 12, 'VV'), (42, 13, 'VXXV'), (42, 14, 'XXXVv'),
                    (42, 15, 'VXXV'), (42, 16, 'VV'), (42, 17, 'v'), (39, 10, 'v'),
                    (40, 11, 'V'), (39, 18, 'v'), (40, 17, 'V'), (46, 14, 'v')]:
        c.put(x, y, t)
    # and rising off the shoulders like heat
    for x, y, t in [(19, 10, 'v'), (18, 11, 'VV'), (19, 12, 'V'), (17, 9, 'v'), (30, 10, 'v'),
                    (31, 11, 'V'), (16, 12, 'v')]:
        c.put(x, y, t)
    # head: bald, heavy brow, long beard
    for y, x0, x1 in [(3, 23, 27), (4, 22, 28), (5, 21, 29), (6, 21, 29), (7, 21, 29),
                      (8, 21, 29), (9, 22, 29), (10, 22, 28), (11, 23, 28)]:
        c.span(y, x0, x1, 'F')
        c.put(x0, y, 'f')
    c.put(24, 4, 'bb')          # scalp shine
    c.put(23, 5, 'b')
    c.put(25, 7, 'BBBB')        # white brows
    c.put(26, 8, 'VFX')         # glowing eye
    c.put(29, 8, 'f')           # nose
    c.put(29, 9, 'F')
    c.put(23, 6, 'V')           # violet crack across the scalp
    c.put(22, 7, 'V')
    c.put(21, 9, 'f')           # ear
    # beard, long and ragged
    for y, x0, x1 in [(10, 25, 29), (11, 24, 30), (12, 24, 30), (13, 24, 29), (14, 24, 29),
                      (15, 25, 28), (16, 25, 28), (17, 26, 28), (18, 26, 27), (19, 26, 26)]:
        c.span(y, x0, x1, 'b')
        c.put(x0, y, 'B')
    c.put(27, 13, 'B')
    c.put(28, 16, 'B')
    # aura wisps
    for x, y in [(17, 6), (33, 4), (36, 9), (10, 15), (8, 27), (38, 24), (14, 2), (40, 30)]:
        c.put(x, y, 'w')


# --------------------------------------------------------------- Void Archmage
# The Observatory's boss: a brilliant mage consumed by the void. Deep indigo
# robes with star-silver trim, an empty hood with two cold eyes, a staff
# crowned with a black void orb, and a hem that dissolves into dripping void
# - it hovers. Fire, ice and lightning motes orbit it (its spells cycle
# through them).
@boss('void_archmage', None, {'V': 'X', 'w': 'x', 'q': 'Q', 'i': 'I', 'y': 'Y', 'E': 'e'}, {
    'R': (70, 48, 118),     # robe
    'r': (44, 28, 80),      # robe shade
    'd': (26, 16, 48),      # robe deep shade
    'L': (196, 204, 232),   # star-silver trim
    'l': (124, 132, 172),   # trim shade
    'H': (10, 6, 18),       # inside the hood
    'E': (236, 228, 255),   # eyes
    'e': (190, 160, 240),   # eyes dim (frame 2)
    'F': (176, 158, 198),   # pale, void-touched hands
    'f': (124, 106, 148),
    'n': (96, 74, 62),      # staff
    'N': (62, 46, 40),
    'o': (14, 8, 26),       # void orb core
    'q': (255, 128, 44), 'Q': (255, 196, 120),   # fire mote
    'i': (110, 214, 255), 'I': (200, 240, 255),  # ice mote
    'y': (250, 232, 80), 'Y': (255, 252, 190),   # lightning mote
})
def void_archmage(c):
    # robe body, widening to the hem
    for y in range(14, 41):
        x0 = 19 - (y - 14) // 4
        x1 = 31 + (y - 14) // 9
        c.span(y, x0, x1, 'R')
        c.put(x0, y, 'd')
        c.put(x0 + 1, y, 'r')
        c.put(x0 + 2, y, 'r')
    for y in range(16, 41):     # front opening with star-silver trim
        c.put(27, y, 'Ld')
        c.put(29, y, 'l')
    c.span(40, 13, 34, 'L')     # hem trim
    for x, y in [(16, 20), (22, 27), (18, 34), (31, 23), (24, 37), (21, 18)]:
        c.put(x, y, 'L')        # stars stitched into the robe
    # the hem dissolving into void
    for x, drop in [(13, 3), (15, 5), (17, 2), (19, 4), (21, 6), (23, 3), (25, 5), (27, 2),
                    (29, 4), (31, 3), (33, 5)]:
        for k in range(drop):
            c.put(x, 41 + k, 'V' if k < drop - 1 else 'v')
        c.put(x + 1, 41, 'v')
    # back arm raised mid-cast, palm open, a rune hanging above it
    for y, x0, x1 in [(15, 17, 20), (14, 15, 19), (13, 14, 18), (12, 13, 17), (11, 12, 16)]:
        c.span(y, x0, x1, 'r')
        c.put(x0, y, 'd')
    c.span(11, 12, 16, 'L')     # cuff
    c.span(9, 12, 15, 'F')      # hand
    c.span(10, 12, 15, 'f')
    c.put(12, 8, 'F F')         # fingers
    c.put(15, 8, 'F')
    c.put(11, 4, ' V ')         # the rune
    c.put(11, 5, 'VXV')
    c.put(11, 6, ' V ')
    # hood, peak swept back
    for y, x0, x1 in [(2, 18, 20), (3, 18, 23), (4, 19, 26), (5, 20, 28), (6, 20, 29),
                      (7, 20, 30), (8, 20, 30), (9, 20, 30), (10, 20, 30), (11, 21, 30),
                      (12, 21, 30), (13, 19, 32), (14, 18, 32)]:
        c.span(y, x0, x1, 'R')
        c.put(x0, y, 'r')
    c.put(17, 1, 'R')           # the peak's tip
    c.put(16, 0, 'r')
    for y, x0, x1 in [(6, 25, 28), (7, 24, 29), (8, 24, 30), (9, 24, 30), (10, 24, 30), (11, 25, 30), (12, 26, 29)]:
        c.span(y, x0, x1, 'H')
    c.put(26, 9, 'EE')          # narrow, cold eyes
    c.put(29, 9, 'EE')
    c.put(26, 10, 'v')
    c.put(30, 10, 'v')
    c.span(13, 22, 31, 'L')     # mantle trim
    c.span(14, 20, 32, 'l')
    # front arm, holding the staff
    for y, x0, x1 in [(16, 30, 33), (17, 30, 34), (18, 31, 34), (19, 31, 34)]:
        c.span(y, x0, x1, 'R')
        c.put(x1, y, 'd')
    c.span(20, 31, 34, 'L')     # cuff
    # staff (the hand is drawn over it)
    for y in range(9, 45):
        c.put(36, y, 'nN')
    c.span(21, 34, 38, 'F')
    c.span(22, 34, 38, 'f')
    c.put(35, 8, 'llll')        # silver collar under the orb
    # void orb
    for y, x0, x1 in [(1, 35, 38), (2, 34, 39), (3, 33, 40), (4, 33, 40), (5, 33, 40), (6, 34, 39), (7, 35, 38)]:
        c.span(y, x0, x1, 'o')
        c.put(x0, y, 'V')
        c.put(x1, y, 'V')
    c.span(1, 35, 38, 'V')
    c.span(7, 35, 38, 'v')
    c.put(35, 3, 'X')           # glint
    c.put(36, 4, 'v')
    # elemental motes orbiting (fire, ice, lightning), plus loose void wisps
    for x, y, lo, hi in [(8, 16, 'q', 'Q'), (43, 14, 'i', 'I'), (9, 31, 'y', 'Y')]:
        c.put(x, y - 1, lo)     # a small glowing cross each
        c.put(x - 1, y, lo + hi + lo)
        c.put(x, y + 1, lo)
    for x, y, ch in [(42, 28, 'q'), (5, 23, 'i'), (40, 36, 'y')]:
        c.put(x, y, ch)
    for x, y in [(23, 0), (33, 11), (5, 38), (43, 21), (11, 44), (38, 45)]:
        c.put(x, y, 'w')


# ----------------------------------------------------------------- Shadow Lord
# The Guild's boss: the old guildmaster, hollowed out by Vorath. A tall cowl
# with a green scarf over the lower face and violet eyes above it, a long
# tattered cloak lined in Guild green, dark leathers with the gold guild coin
# at the chest - crouched, one curved dagger raised high, the other thrust
# forward, both dripping venom. Smoke curls around its feet.
@boss('shadow_lord', 25, {'V': 'X', 'w': 'x', 'Z': 'z'}, {
    'H': (54, 50, 70),      # hood / cloak
    'h': (84, 78, 104),     # cloak highlight
    'j': (30, 26, 42),      # cloak shadow / boots
    'L': (42, 80, 60),      # cloak lining (Guild green)
    'M': (54, 100, 72),     # scarf
    'm': (32, 64, 46),
    'F': (190, 164, 146),   # pale skin
    'f': (126, 104, 98),
    'A': (94, 74, 62),      # leathers
    'a': (60, 48, 42),
    'C': (228, 188, 86),    # guild coin
    'c': (150, 112, 44),
    'S': (206, 212, 226),   # blade
    's': (122, 130, 152),
    'Z': (150, 232, 92),    # venom
    'z': (96, 168, 56),
    'w': (70, 50, 96),      # smoke (darker than the other bosses' wisps)
    'x': (104, 76, 140),
})
def shadow_lord(c):
    # cloak flaring out behind, tattered
    for y in range(12, 41):
        x0 = 19 - (y - 12) * 14 // 28
        x1 = 22 if y < 20 else 20
        c.span(y, x0, x1, 'H')
        c.put(x0, y, 'j')
        c.put(x1, y, 'L')       # the green lining showing at the inner edge
        if y % 5 == 0:
            c.put(x0 + 2, y, 'h')
    for x, drop in [(5, 3), (7, 1), (9, 4), (11, 2), (13, 3), (15, 1), (17, 2), (19, 3)]:
        for k in range(drop):
            c.put(x, 41 + k, 'H' if k < drop - 1 else 'j')
    # back leg, knee bent out behind
    for y, x0, x1 in [(26, 20, 24), (27, 19, 23), (28, 18, 22), (29, 17, 21), (30, 16, 20),
                      (31, 16, 19), (32, 16, 19), (33, 16, 19), (34, 16, 19), (35, 15, 18),
                      (36, 15, 18), (37, 14, 18), (38, 14, 18), (39, 14, 18), (40, 14, 18),
                      (41, 14, 18), (42, 14, 18)]:
        c.span(y, x0, x1, 'a')
    for y in range(37, 43):     # boot
        c.span(y, 14, 18, 'j')
    c.span(43, 12, 19, 'j')
    # front leg, lunging forward
    for y, x0, x1 in [(26, 26, 30), (27, 27, 31), (28, 28, 32), (29, 29, 33), (30, 30, 34),
                      (31, 31, 35), (32, 31, 35), (33, 31, 35), (34, 31, 35), (35, 31, 35),
                      (36, 31, 35), (37, 31, 35), (38, 31, 35), (39, 31, 35), (40, 31, 35),
                      (41, 31, 35), (42, 31, 35)]:
        c.span(y, x0, x1, 'A')
        c.put(x1, y, 'a')
    for y in range(36, 43):
        c.span(y, 31, 35, 'j')
    c.span(43, 31, 38, 'j')
    c.put(32, 37, 'h')
    # torso, leaning in
    for y, x0, x1 in [(13, 21, 29), (14, 20, 30), (15, 20, 30), (16, 20, 30), (17, 20, 30),
                      (18, 21, 30), (19, 21, 29), (20, 22, 29), (21, 22, 29), (22, 22, 29),
                      (23, 21, 30), (24, 21, 31), (25, 20, 31)]:
        c.span(y, x0, x1, 'A')
        c.put(x0, y, 'a')
        c.put(x0 + 1, y, 'a')
        c.put(x1, y, 'a')
    for k in range(9):          # strap across the chest
        c.put(21 + k, 14 + k, 'a')
    c.put(24, 15, 'cCc')        # the guild coin
    c.put(24, 16, 'CcC')
    c.put(24, 17, 'cCc')
    c.span(23, 21, 30, 'j')     # belt
    c.put(27, 24, 'aa')         # pouch
    c.put(27, 25, 'aa')
    c.put(21, 24, 'V')          # corruption at the seams
    c.put(29, 20, 'V')
    # back arm raised high, dagger pointing up
    for y, x0, x1 in [(13, 18, 21), (12, 17, 20), (11, 16, 19), (10, 15, 18), (9, 15, 18)]:
        c.span(y, x0, x1, 'H')
        c.put(x0, y, 'j')
    c.put(14, 6, 'FFF')         # fist around the hilt
    c.put(14, 7, 'FFf')
    c.put(14, 8, 'fff')
    c.put(15, 5, 'a')           # hilt
    for x, y in [(15, 4), (15, 3), (14, 2), (14, 1), (13, 0)]:
        c.put(x, y, 'Ss')       # curved blade
    c.put(17, 5, 'Z')           # venom running down
    c.put(17, 9, 'z')
    # hood, peak leaning forward
    for y, x0, x1 in [(2, 22, 25), (3, 21, 27), (4, 21, 28), (5, 20, 29), (6, 20, 30),
                      (7, 20, 30), (8, 20, 30), (9, 20, 30), (10, 20, 30), (11, 20, 30),
                      (12, 21, 30)]:
        c.span(y, x0, x1, 'H')
        c.put(x0, y, 'j')
    c.put(26, 1, 'HH')          # the cowl's peak tipping forward
    c.put(28, 2, 'H')
    c.put(29, 3, 'h')
    for y, x0, x1 in [(6, 25, 29), (7, 25, 30), (8, 25, 30), (9, 25, 30)]:
        c.span(y, x0, x1, 'j')  # shadow under the hood
    c.span(8, 26, 30, 'f')      # the strip of face above the scarf
    c.put(27, 8, 'V')           # eyes
    c.put(29, 8, 'V')
    for y, x0, x1 in [(9, 25, 30), (10, 24, 30), (11, 23, 30), (12, 23, 29)]:
        c.span(y, x0, x1, 'M')  # scarf over the lower face
        c.put(x0, y, 'm')
    c.put(23, 13, 'Mm')         # its tail
    c.put(22, 14, 'm')
    # mantle over the shoulders
    for y, x0, x1 in [(13, 19, 31), (14, 19, 32), (15, 20, 32), (16, 21, 31)]:
        c.span(y, x0, x1, 'H')
        c.put(x0, y, 'j')
    c.span(13, 21, 30, 'h')
    c.put(24, 15, 'cCc')        # the guild coin pins the mantle
    c.put(24, 16, 'CcC')
    c.put(24, 17, 'cCc')
    # front arm thrust forward, dagger out, edge down
    for y, x0, x1 in [(15, 30, 33), (16, 30, 35), (17, 31, 35), (18, 32, 35)]:
        c.span(y, x0, x1, 'H')
        c.put(x1, y, 'j')
    c.span(16, 35, 37, 'F')     # hand
    c.span(17, 35, 37, 'F')
    c.span(18, 35, 37, 'f')
    c.put(38, 16, 'aa')         # hilt
    for x, y in [(40, 16), (41, 16), (42, 16), (43, 17), (44, 17), (45, 18)]:
        c.put(x, y, 'S')        # curved blade
    for x, y in [(40, 17), (41, 17), (42, 17), (44, 18)]:
        c.put(x, y, 's')
    c.put(42, 18, 'Z')          # venom dripping off it
    c.put(42, 19, 'z')
    c.put(42, 21, 'Z')
    # smoke curling around
    for x, y in [(23, 44), (27, 45), (11, 45), (39, 41), (42, 37), (36, 9), (9, 22), (6, 30), (38, 28)]:
        c.put(x, y, 'w')
    c.put(24, 45, 'w')
    c.put(37, 42, 'w')


# ============================================================ escape wardens
# The bosses that guard each starting dungeon's exit (Batch 2). Same size and
# pipeline as the four above.

# ------------------------------------------------------------- Sparring Master
# The Monastery's warden (a Ryn start): a younger instructor in a slate
# training gi, settled into a high guard - both forearms up, palms ready to
# turn a blow aside (its counter stance). Only lightly touched by the
# corruption: violet eyes and a few cracks along the arms.
@boss('sparring_master', 26, {'V': 'X', 'w': 'x'}, {
    'F': (214, 170, 130),   # skin
    'f': (158, 112, 84),
    'h': (42, 32, 34),      # hair
    'O': (168, 184, 200),   # gi
    'o': (108, 122, 140),
    'd': (72, 82, 100),     # gi deep shade
    'n': (40, 34, 46),      # black belt
    'W': (232, 226, 212),   # hand wraps
})
def sparring_master(c):
    # back leg, planted behind
    for y, x0, x1 in [(28, 19, 24), (29, 18, 23), (30, 17, 22), (31, 16, 21), (32, 15, 20),
                      (33, 14, 19), (34, 13, 18), (35, 13, 18), (36, 12, 17), (37, 12, 17),
                      (38, 12, 16), (39, 12, 16), (40, 12, 16), (41, 12, 16)]:
        c.span(y, x0, x1, 'o')
        c.put(x0, y, 'd')
    c.span(42, 11, 16, 'F')
    c.span(43, 10, 16, 'f')
    # front leg, knee bent forward
    for y, x0, x1 in [(28, 25, 30), (29, 26, 31), (30, 27, 32), (31, 28, 33), (32, 28, 33),
                      (33, 29, 34), (34, 29, 34), (35, 29, 34), (36, 29, 33), (37, 29, 33),
                      (38, 29, 33), (39, 29, 33), (40, 29, 33), (41, 29, 33)]:
        c.span(y, x0, x1, 'O')
        c.put(x1, y, 'o')
    c.span(42, 29, 35, 'F')
    c.span(43, 29, 36, 'f')
    # gi jacket, belted
    for y, x0, x1 in [(15, 21, 30), (16, 20, 31), (17, 20, 31), (18, 20, 31), (19, 20, 31),
                      (20, 20, 31), (21, 20, 31), (22, 21, 30), (23, 21, 30), (24, 20, 31),
                      (25, 19, 31), (26, 19, 31), (27, 19, 31)]:
        c.span(y, x0, x1, 'O')
        c.put(x0, y, 'o')
    for k in range(6):          # the jacket's crossed front, open at the neck
        c.put(25 + k // 2, 15 + k, 'o')
    c.put(26, 15, 'FF')
    c.put(27, 16, 'F')
    c.span(23, 20, 31, 'n')     # black belt
    c.put(26, 24, 'nn')
    c.put(27, 25, 'n')
    # back arm: elbow down, forearm up, guarding the face
    for y, x0, x1 in [(16, 18, 21), (17, 17, 20), (18, 16, 19), (19, 16, 19), (20, 16, 19)]:
        c.span(y, x0, x1, 'O')
        c.put(x0, y, 'd')
    for y in range(13, 20):     # forearm, wrapped
        c.put(14, y, 'FFf')
    c.put(14, 15, 'WWW')
    c.put(14, 16, 'WWW')
    c.put(14, 11, 'FFF')        # open hand
    c.put(14, 12, 'FFf')
    c.put(13, 11, 'f')
    # head: shaved sides, topknot
    for y, x0, x1 in [(5, 25, 29), (6, 24, 30), (7, 23, 31), (8, 23, 31), (9, 23, 31),
                      (10, 23, 31), (11, 23, 31), (12, 24, 30), (13, 25, 29)]:
        c.span(y, x0, x1, 'F')
        c.put(x0, y, 'f')
    c.span(5, 25, 29, 'h')
    c.span(6, 24, 29, 'h')
    c.put(23, 7, 'hh')
    c.put(26, 3, 'hh')          # topknot
    c.put(26, 4, 'hhh')
    c.put(28, 8, 'hh')          # brow
    c.put(29, 9, 'V')           # eye
    c.put(31, 10, 'f')          # nose
    c.put(28, 12, 'ff')         # set jaw
    c.put(23, 9, 'f')           # ear
    c.span(14, 25, 28, 'f')     # neck
    # front arm: elbow out, forearm raised in front of the face, palm open
    for y, x0, x1 in [(16, 30, 33), (17, 31, 34), (18, 32, 35), (19, 33, 36), (20, 34, 37)]:
        c.span(y, x0, x1, 'O')
        c.put(x1, y, 'd')
    for y in range(11, 20):
        c.put(36, y, 'FFf')
    c.put(36, 15, 'WWW')
    c.put(36, 16, 'WWW')
    c.put(37, 17, 'V')          # cracks up the forearm
    c.put(36, 13, 'V')
    c.put(36, 8, 'F F')         # fingers up, palm out
    c.put(36, 9, 'FFF')
    c.put(36, 10, 'FFF')
    c.put(39, 9, 'f')           # thumb
    # a few wisps
    for x, y in [(20, 8), (40, 5), (42, 22), (9, 28), (38, 30)]:
        c.put(x, y, 'w')


# ---------------------------------------------------------------- Void Sentinel
# The Observatory's warden (a Lyra start): a construct of carved stone and
# observatory brass, its joints floating free, a void core in its chest and
# one violet eye. Blows skip off the stone - but it hates fire.
@boss('void_sentinel', 27, {'V': 'X', 'w': 'x'}, {
    'G': (110, 116, 138),   # stone
    'g': (70, 74, 94),
    'l': (152, 160, 182),   # stone highlight
    'B': (194, 154, 72),    # brass
    'b': (134, 100, 46),
    'o': (12, 8, 24),       # void core
})
def void_sentinel(c):
    def block(x0, y0, x1, y1):
        for y in range(y0, y1 + 1):
            c.span(y, x0, x1, 'G')
            c.put(x0, y, 'l')
            c.put(x1, y, 'g')
        c.span(y0, x0, x1, 'l')
        c.span(y1, x0, x1, 'g')
        for x, y in ((x0, y0), (x1, y1)):
            c.put(x, y, '.')    # worn, chipped corners
    # legs: stacked blocks with gaps (floating joints)
    block(18, 31, 23, 36)
    block(27, 31, 32, 36)
    block(17, 38, 23, 43)
    block(27, 38, 33, 43)
    c.span(44, 16, 24, 'g')     # feet
    c.span(44, 26, 34, 'g')
    c.span(45, 16, 24, 'G')
    c.span(45, 26, 35, 'G')
    # torso: one big block banded in brass
    block(17, 13, 33, 29)
    c.span(14, 18, 32, 'B')
    c.span(28, 18, 32, 'B')
    c.put(18, 15, 'b')
    c.put(32, 15, 'b')
    # engraved star chart on the stone
    for x, y in [(19, 18), (20, 24), (31, 19), (30, 25), (21, 21)]:
        c.put(x, y, 'g')
    c.put(19, 19, 'g')
    c.put(20, 20, 'g')
    # void core
    for y, x0, x1 in [(18, 23, 27), (19, 22, 28), (20, 22, 28), (21, 22, 28), (22, 22, 28), (23, 23, 27)]:
        c.span(y, x0, x1, 'o')
        c.put(x0, y, 'V')
        c.put(x1, y, 'V')
    c.span(17, 23, 27, 'V')
    c.span(24, 23, 27, 'v')
    c.put(24, 20, 'X')
    c.put(25, 21, 'v')
    for x, y in [(21, 25), (20, 26), (29, 17), (30, 16)]:
        c.put(x, y, 'V')        # void cracks spreading out from the core
    # head: a block with one eye slit
    block(21, 4, 30, 11)
    c.span(5, 22, 29, 'B')      # brass crown band
    c.span(8, 22, 30, 'o')
    c.put(26, 8, 'VXXV')        # the eye, looking right
    c.span(7, 22, 30, 'g')      # a heavy stone brow over it
    # shoulders: floating stones
    block(9, 13, 16, 19)        # (lopsided: the left one has slipped)
    block(34, 11, 41, 17)
    c.put(10, 14, 'BBBBBB')
    c.put(35, 12, 'BBBBBB')
    # arms: segments hanging free, heavy fists
    block(10, 21, 15, 26)
    block(36, 19, 40, 24)
    block(8, 28, 16, 34)
    block(34, 26, 42, 32)
    c.span(31, 9, 15, 'g')      # knuckle lines
    c.span(31, 11, 11, 'l')
    c.span(29, 35, 41, 'g')
    # void cracks running through the stone
    for x, y in [(12, 15), (13, 16), (13, 17), (38, 13), (37, 14), (11, 30), (12, 29),
                 (39, 28), (40, 29), (24, 6), (23, 7), (28, 10), (19, 30), (20, 33),
                 (31, 35), (30, 40), (21, 40), (32, 27), (18, 16)]:
        c.put(x, y, 'V')
    c.put(28, 15, 'v')
    c.put(27, 16, 'v')
    # void wisps leaking from the gaps
    for x, y in [(13, 19), (37, 19), (13, 26), (37, 26), (25, 37), (25, 30), (25, 12)]:
        c.put(x, y, 'w')
    for x, y in [(6, 8), (44, 10), (5, 30), (44, 34)]:
        c.put(x, y, 'w')


# ----------------------------------------------------------- Corrupted Enforcer
# The Guild's warden (a Silas start): the muscle that kept the Guild's
# debtors in line. Bald under a red bandana, a scar across one eye, an open
# leather vest over a bruiser's bulk, hunched forward with brass knuckles
# dripping poison.
@boss('corrupted_enforcer', 27, {'V': 'X', 'Z': 'z', 'w': 'x'}, {
    'F': (192, 142, 106),   # skin
    'f': (138, 98, 74),
    'R': (154, 46, 44),     # bandana
    'r': (100, 28, 30),
    'A': (88, 64, 50),      # vest
    'a': (56, 42, 36),
    'U': (72, 68, 84),      # trousers
    'u': (48, 44, 58),
    'j': (34, 28, 30),      # boots
    'C': (222, 182, 86),    # brass knuckles
    'c': (148, 110, 44),
    'N': (120, 120, 128),   # chain belt
    'Z': (150, 232, 92),    # poison
    'z': (96, 168, 56),
})
def corrupted_enforcer(c):
    # legs, short and thick, wide stance
    for y, x0, x1 in [(30, 16, 22), (31, 15, 21), (32, 14, 21), (33, 14, 20), (34, 13, 20),
                      (35, 13, 19), (36, 13, 19), (37, 13, 19), (38, 13, 19)]:
        c.span(y, x0, x1, 'U')
        c.put(x0, y, 'u')
    for y, x0, x1 in [(30, 26, 32), (31, 27, 33), (32, 27, 34), (33, 28, 34), (34, 28, 35),
                      (35, 29, 35), (36, 29, 35), (37, 29, 35), (38, 29, 35)]:
        c.span(y, x0, x1, 'U')
        c.put(x1, y, 'u')
    for y in range(39, 44):     # boots
        c.span(y, 12, 19, 'j')
        c.span(y, 29, 36, 'j')
    c.span(43, 11, 20, 'j')
    c.span(43, 29, 37, 'j')
    # torso: barrel chest and belly under an open vest
    for y, x0, x1 in [(13, 18, 32), (14, 16, 33), (15, 15, 34), (16, 15, 34), (17, 15, 34),
                      (18, 15, 34), (19, 15, 34), (20, 15, 34), (21, 15, 34), (22, 16, 34),
                      (23, 16, 34), (24, 16, 34), (25, 16, 33), (26, 17, 33), (27, 17, 32),
                      (28, 17, 32), (29, 17, 32)]:
        c.span(y, x0, x1, 'A')
        c.put(x0, y, 'a')
    for y, x0, x1 in [(14, 24, 30), (15, 23, 31), (16, 23, 31), (17, 23, 31), (18, 23, 31),
                      (19, 23, 31), (20, 23, 32), (21, 23, 32), (22, 23, 32), (23, 23, 32),
                      (24, 23, 32), (25, 23, 31), (26, 24, 31)]:
        c.span(y, x0, x1, 'F')  # bare chest and belly
        c.put(x0, y, 'f')
    c.put(26, 18, 'ff')         # chest line
    c.put(28, 18, 'ff')
    c.put(27, 23, 'f')          # navel
    c.put(29, 16, 'V')          # corruption veins
    c.put(30, 17, 'V')
    c.put(30, 21, 'v')
    c.span(27, 17, 32, 'N')     # chain belt
    for x in range(18, 32, 2):
        c.put(x, 27, 'u')
    c.put(24, 28, 'CC')         # buckle
    # back arm: cocked fist, knuckles up
    for y, x0, x1 in [(14, 12, 17), (15, 11, 16), (16, 10, 15), (17, 10, 15), (18, 10, 15),
                      (19, 10, 15), (20, 10, 15)]:
        c.span(y, x0, x1, 'F')
        c.put(x0, y, 'f')
    c.span(21, 9, 15, 'F')
    c.span(22, 9, 15, 'F')
    c.span(23, 9, 15, 'f')
    c.span(21, 9, 15, 'C')      # knuckle-duster
    c.put(10, 21, 'c c c')
    c.put(12, 24, 'Z')          # poison dripping
    c.put(12, 25, 'z')
    c.put(14, 26, 'z')
    # head, hunched low between the shoulders
    for y, x0, x1 in [(6, 25, 31), (7, 24, 32), (8, 24, 33), (9, 24, 33), (10, 24, 33),
                      (11, 24, 33), (12, 25, 33), (13, 26, 32)]:
        c.span(y, x0, x1, 'F')
        c.put(x0, y, 'f')
    c.span(6, 25, 31, 'R')      # bandana
    c.span(7, 24, 32, 'R')
    c.put(24, 8, 'rr')          # knot and tails
    c.put(22, 8, 'R')
    c.put(21, 9, 'Rr')
    c.put(29, 9, 'ff')          # heavy brow
    c.put(30, 10, 'V')          # eye
    c.put(28, 9, 'r')           # the scar across the eye
    c.put(29, 10, 'r')
    c.put(30, 11, 'r')
    c.put(33, 11, 'f')          # nose
    c.put(30, 12, 'fff')        # sneer
    c.put(32, 12, 'F')
    # front arm: forearm forward, fist out toward the party
    for y, x0, x1 in [(14, 31, 35), (15, 32, 37), (16, 33, 38), (17, 34, 39), (18, 35, 39),
                      (19, 35, 39)]:
        c.span(y, x0, x1, 'F')
        c.put(x1, y, 'f')
    c.put(36, 17, 'V')
    for y in range(20, 24):     # fist
        c.span(y, 35, 40, 'F')
        c.put(40, y, 'f')
    c.span(20, 35, 40, 'C')     # knuckle-duster
    c.put(36, 20, 'c c')
    c.put(41, 21, 'Z')          # poison
    c.put(41, 22, 'z')
    c.put(39, 25, 'Z')
    c.put(39, 26, 'z')
    for x, y in [(8, 10), (40, 6), (44, 28), (6, 32), (24, 45)]:
        c.put(x, y, 'w')


def render(b, glow_frame):
    grid = b['rows']
    if glow_frame:
        grid = [''.join(b['glow'].get(ch, ch) for ch in row) for row in grid]
    if glow_frame and b['split'] is None:
        grid = grid[1:] + ['.' * W]  # floats: the whole sprite rises 1px
    elif glow_frame:
        split = b['split']
        upper = grid[:split]
        merged = ''.join(u if u != '.' else l for u, l in zip(upper[-1], grid[split]))
        grid = ['.' * W] + upper[:-1] + [merged] + grid[split + 1:]
    im = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    for y, row in enumerate(grid):
        for x, ch in enumerate(row):
            col = b['pal'][ch]
            if col:
                im.putpixel((x, y), col + (255,))
    return im


def sheet(b):
    out = Image.new('RGBA', (W * 2, H), (0, 0, 0, 0))
    out.paste(render(b, False), (0, 0))
    out.paste(render(b, True), (W, 0))
    return out


if __name__ == '__main__':
    out_dir = sys.argv[1]
    os.makedirs(out_dir, exist_ok=True)
    sheets = {slug: sheet(b) for slug, b in BOSSES.items()}
    for slug, s in sheets.items():
        s.save(os.path.join(out_dir, slug + '.png'))
    if len(sys.argv) > 2:
        pw = sum(s.width for s in sheets.values()) + 4 * (len(sheets) + 1)
        prev = Image.new('RGBA', (pw, 52), (60, 52, 70, 255))
        x = 4
        for s in sheets.values():
            prev.alpha_composite(s, (x, 2))
            x += s.width + 4
        prev.resize((prev.width * 6, prev.height * 6), Image.NEAREST).save(sys.argv[2])
