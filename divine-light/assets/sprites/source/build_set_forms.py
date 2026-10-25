"""Every armor set's form (Cory, 2026-10-25: "different models for each of
the sets... a gradual increase of their badassdom"). Wearing a complete set
swaps the hero's whole walk sheet for that set's form (SetLooks.FORMS):

  Act I sets   - the hero sharpened up with real gear, close to the base
                 silhouette.
  Act II sets  - clearly stronger: heavier armour, a cape or mantle, the
                 first touches of elemental power.
  Act III sets - the full transformation (drawn in build_act3_forms.py).

All forms share the 24x32 frame and the base sheets' 3x3 layout (rows
down / up / right, columns idle / stepA / stepB), body on the same centre
column and feet on the same row. Writes assets/sprites/<hero>_<set>_walk.png.

Usage: python build_set_forms.py <out_dir> [preview.png]
"""
import os
import sys

from PIL import Image

import build_act3_forms as A
from build_act3_forms import CX, FEET, legs_front, legs_side

POSES = A.POSES


def k(pose):
    return {'idle': 0, 'stepA': 1, 'stepB': 2}[pose]


# ============================================================ VAEL, Act I
# Holy Guardian: a knight in steel, plumed helm, white tabard with a gold
# cross, kite shield, longsword at his side.
HOLY_GUARDIAN = {
    'S': (176, 184, 202), 's': (124, 132, 156), 'D': (78, 86, 110),   # steel
    'T': (240, 236, 222), 't': (190, 182, 162),                        # tabard
    'G': (232, 190, 70), 'g': (168, 124, 38),                          # gold
    'R': (200, 40, 48), 'r': (130, 24, 32),                            # plume
    'V': (20, 16, 26), 'B': (214, 222, 236), 'b': (140, 150, 172),     # visor, blade
    'N': (96, 66, 42),
}


def hg_front(c, pose):
    legs_front(c, pose, 24, 'S', 's', 'D', 's')
    c.rect(CX - 4, 11, CX + 3, 23, 'S')
    c.mirror_rect(CX - 4, 12, CX - 4, 23, 's')
    c.rect(CX - 3, 12, CX + 2, 23, 'T')            # tabard
    c.rect(CX - 3, 20, CX + 2, 23, 't')
    c.rect(CX - 1, 13, CX, 19, 'G'); c.rect(CX - 2, 15, CX + 1, 15, 'G')  # cross
    c.rect(CX - 4, 20, CX + 3, 20, 'N')            # belt
    c.mirror_rect(CX - 6, 11, CX - 4, 12, 'S')     # pauldrons
    c.mirror_put(CX - 6, 11, 'B')
    c.mirror_rect(CX - 6, 13, CX - 5, 19, 's')     # arms
    c.mirror_rect(CX - 6, 20, CX - 5, 20, 'D')
    # longsword at the viewer's left, point down
    c.rect(CX - 8, 18, CX - 8, FEET - 2, 'B'); c.rect(CX - 9, 17, CX - 7, 17, 'G'); c.put(CX - 8, 16, 'N')
    # kite shield at the viewer's right
    c.rect(CX + 4, 14, CX + 8, 21, 'T')
    c.rect(CX + 5, 22, CX + 7, 22, 'T'); c.put(CX + 6, 23, 'T')
    c.rect(CX + 6, 15, CX + 6, 21, 'G'); c.rect(CX + 5, 17, CX + 7, 17, 'G')
    c.rect(CX + 4, 14, CX + 8, 14, 'g')
    # helm with a red plume
    c.rect(CX - 3, 3, CX + 2, 10, 'S'); c.mirror_rect(CX - 3, 4, CX - 3, 10, 's')
    c.rect(CX - 2, 6, CX + 1, 6, 'V'); c.rect(CX - 3, 10, CX + 2, 10, 'D')
    c.rect(CX - 1, 0, CX, 2, 'R'); c.put(CX + 1, 1 + k(pose) % 2, 'r')


def hg_back(c, pose):
    legs_front(c, pose, 24, 's', 'D', 'D', 's')
    c.rect(CX - 4, 11, CX + 3, 23, 'S')
    c.rect(CX - 3, 12, CX + 2, 23, 'T'); c.rect(CX - 3, 20, CX + 2, 23, 't')
    c.rect(CX - 4, 20, CX + 3, 20, 'N')
    c.mirror_rect(CX - 6, 11, CX - 4, 12, 'S'); c.mirror_rect(CX - 6, 13, CX - 5, 19, 's')
    c.rect(CX - 9, 14, CX - 5, 21, 'N'); c.rect(CX - 9, 14, CX - 5, 14, 'g')  # shield back
    c.rect(CX + 6, 7, CX + 6, 10, 'N'); c.rect(CX + 5, 10, CX + 7, 10, 'G')  # sword hilt
    c.rect(CX - 3, 3, CX + 2, 10, 'S'); c.rect(CX + 1, 4, CX + 2, 10, 's')
    c.rect(CX - 1, 0, CX, 4, 'R')


def hg_side(c, pose):
    legs_side(c, pose, 24, 'S', 's', 'D', 's')
    c.rect(CX - 3, 11, CX + 3, 23, 'S'); c.rect(CX - 2, 12, CX + 3, 23, 'T')
    c.rect(CX - 2, 20, CX + 3, 23, 't'); c.rect(CX - 3, 20, CX + 3, 20, 'N')
    c.rect(CX + 1, 14, CX + 1, 18, 'G'); c.rect(CX, 15, CX + 2, 15, 'G')
    c.rect(CX - 3, 11, CX + 1, 12, 'S')
    # shield held forward, edge-on
    c.rect(CX + 4, 13, CX + 5, 22, 'T'); c.rect(CX + 5, 13, CX + 5, 22, 'g')
    # sword hanging at the near side
    c.rect(CX - 1, 15, CX, 19, 's'); c.rect(CX - 1, 20, CX - 1, FEET - 3, 'B'); c.rect(CX - 2, 19, CX, 19, 'G')
    c.rect(CX - 3, 3, CX + 2, 10, 'S'); c.rect(CX - 3, 4, CX - 2, 10, 's')
    c.rect(CX, 6, CX + 2, 6, 'V')
    c.rect(CX - 2, 0, CX - 1, 2, 'R'); c.put(CX - 3, 1 + k(pose) % 2, 'r')


# ============================================================ VAEL, Act II
# Sacred Aegis: silver-blue plate, a crested helm with a blue plume, a half
# cape, a great round aegis shield with a glowing gem.
SACRED_AEGIS = {
    'S': (196, 210, 232), 's': (132, 148, 182), 'D': (74, 88, 128),   # silver-blue plate
    'W': (240, 246, 255),
    'C': (40, 70, 160), 'c': (24, 42, 104),                            # cape
    'G': (226, 196, 110), 'g': (156, 128, 60),                         # trim
    'E': (110, 220, 255), 'e': (40, 140, 220),                          # gem / visor
    'P': (70, 120, 220), 'p': (40, 80, 170),                            # plume
    'B': (226, 236, 252), 'b': (146, 164, 200),
}


def sa_front(c, pose):
    for y in range(12, 25):  # half cape
        half = 6 + (y - 12) // 4
        c.rect(CX - half, y, CX + half - 1, y, 'c' if y % 3 == 0 else 'C')
    legs_front(c, pose, 23, 'S', 's', 'D', 'S')
    c.rect(CX - 4, 11, CX + 3, 22, 'S'); c.mirror_rect(CX - 4, 12, CX - 4, 22, 's')
    c.rect(CX - 2, 13, CX + 1, 16, 'W'); c.rect(CX - 1, 14, CX, 15, 'E')   # chest gem
    c.rect(CX - 4, 19, CX + 3, 19, 'G'); c.rect(CX - 4, 20, CX + 3, 22, 's')
    for i, (x0, x1) in enumerate([(CX - 7, CX - 4), (CX - 8, CX - 4), (CX - 7, CX - 5)]):
        c.mirror_rect(x0, 11 + i, x1, 11 + i, 'W' if i == 0 else 'S')  # round pauldrons
    c.mirror_put(CX - 8, 12, 'G')
    c.mirror_rect(CX - 7, 14, CX - 5, 19, 's'); c.mirror_rect(CX - 7, 20, CX - 5, 21, 'G')
    # longsword held up at the viewer's left
    c.rect(CX - 9, 9, CX - 9, 19, 'B'); c.rect(CX - 8, 10, CX - 8, 19, 'b')
    c.rect(CX - 10, 20, CX - 7, 20, 'G'); c.put(CX - 9, 8, 'W')
    # round aegis at the viewer's right
    for y, (x0, x1) in zip(range(14, 25), [(7, 9), (6, 10), (5, 11), (5, 11), (5, 11), (5, 11), (5, 11), (5, 11), (5, 11), (6, 10), (7, 9)]):
        c.rect(CX + x0, y, CX + x1, y, 'S')
        c.put(CX + x0, y, 'G'); c.put(CX + x1, y, 'G')
    c.rect(CX + 7, 18, CX + 9, 20, 'E'); c.put(CX + 8, 19, 'W'); c.put(CX + 7, 20, 'e')
    # crested helm, glowing visor, blue plume
    c.rect(CX - 3, 3, CX + 2, 10, 'S'); c.mirror_rect(CX - 3, 4, CX - 3, 10, 's')
    c.rect(CX - 2, 6, CX + 1, 6, 'E'); c.rect(CX - 3, 10, CX + 2, 10, 'G')
    c.rect(CX - 1, 1, CX, 3, 'G')
    c.rect(CX - 1, 0, CX + 3, 0, 'P'); c.rect(CX + 2, 1, CX + 4, 2 + k(pose) % 2, 'p')
    c.mirror_put(CX - 4, 4, 'G'); c.mirror_put(CX - 5, 3, 'G')  # crest wings


def sa_back(c, pose):
    legs_front(c, pose, 23, 's', 'D', 'D', 'S')
    sway = (0, 1, -1)[k(pose)]
    for y in range(11, 26):
        half = 6 + (y - 11) // 4
        s = sway if y > 18 else 0
        c.rect(CX - half + s, y, CX + half - 1 + s, y, 'C')
        c.put(CX + s, y, 'c')
    c.rect(CX - 8, 25, CX + 7, 25, 'G')
    for i, (x0, x1) in enumerate([(CX - 7, CX - 4), (CX - 8, CX - 4)]):
        c.mirror_rect(x0, 11 + i, x1, 11 + i, 'W' if i == 0 else 'S')
    for y, (x0, x1) in zip(range(14, 23), [(7, 9), (6, 10), (6, 10), (6, 10), (6, 10), (6, 10), (6, 10), (6, 10), (7, 9)]):
        c.rect(CX - 1 - x1, y, CX - 1 - x0, y, 'D')
    c.rect(CX - 3, 3, CX + 2, 10, 'S'); c.rect(CX + 1, 4, CX + 2, 10, 's')
    c.rect(CX - 1, 0, CX, 9, 'G'); c.rect(CX + 1, 0, CX + 3, 2, 'P')


def sa_side(c, pose):
    sway = (0, 1, 0)[k(pose)]
    for y in range(12, 26):
        back = 3 + (y - 12) // 3 + sway
        c.rect(CX - 2 - back, y, CX - 1, y, 'C' if y % 3 else 'c')
    legs_side(c, pose, 23, 'S', 's', 'D', 'S')
    c.rect(CX - 3, 11, CX + 3, 22, 'S'); c.rect(CX - 3, 12, CX - 2, 22, 's')
    c.rect(CX - 3, 19, CX + 3, 19, 'G'); c.put(CX + 2, 14, 'E')
    c.rect(CX - 3, 10, CX + 2, 11, 'W'); c.rect(CX - 4, 12, CX + 2, 13, 'S')
    # aegis held forward
    c.rect(CX + 4, 12, CX + 6, 23, 'S'); c.rect(CX + 6, 12, CX + 6, 23, 'G')
    c.rect(CX + 4, 16, CX + 5, 18, 'E')
    c.rect(CX - 3, 3, CX + 2, 10, 'S'); c.rect(CX - 3, 4, CX - 2, 10, 's')
    c.rect(CX, 6, CX + 2, 6, 'E'); c.rect(CX - 2, 1, CX, 3, 'G')
    c.rect(CX - 5, 0, CX - 1, 0, 'P'); c.rect(CX - 6, 1, CX - 4, 1 + k(pose) % 2, 'p')


# ============================================================ RYN, Act I
# Iron Monk: grey gi, iron bracers and knuckles, a topknot, prayer beads.
IRON_MONK = {
    'G': (150, 150, 162), 'g': (100, 100, 114),                        # grey gi
    'I': (96, 100, 112), 'i': (60, 62, 74), 'L': (176, 182, 196),       # iron
    'S': (226, 168, 128), 's': (172, 112, 84),
    'A': (40, 30, 34), 'O': (130, 80, 46), 'o': (90, 52, 30),           # hair, beads
    'P': (70, 66, 80), 'p': (46, 44, 54), 'R': (196, 160, 90),          # trousers, rope belt
}


def im_front(c, pose):
    legs_front(c, pose, 22, 'P', 'p', 'i', 'I')
    c.rect(CX - 4, 11, CX + 3, 20, 'G'); c.mirror_rect(CX - 4, 11, CX - 4, 20, 'g')
    c.rect(CX - 1, 11, CX, 13, 'S')                                       # open collar
    c.rect(CX - 4, 19, CX + 3, 20, 'R')
    for x, y in ((CX - 2, 12), (CX - 2, 14), (CX - 1, 15), (CX, 15), (CX + 1, 14), (CX + 1, 12)):
        c.put(x, y, 'O')                                                  # prayer beads
    c.mirror_rect(CX - 6, 11, CX - 5, 13, 'G')
    c.mirror_rect(CX - 6, 14, CX - 5, 16, 'S')
    c.mirror_rect(CX - 7, 17, CX - 5, 20, 'I'); c.mirror_put(CX - 6, 17, 'L')  # iron bracers
    c.rect(CX - 3, 5, CX + 2, 10, 'S'); c.rect(CX - 3, 9, CX + 2, 10, 's')
    c.put(CX - 2, 7, 'A'); c.put(CX + 1, 7, 'A')
    c.rect(CX - 3, 3, CX + 2, 5, 'A')
    c.rect(CX - 1, 0, CX, 2, 'A')                                         # topknot


def im_back(c, pose):
    legs_front(c, pose, 22, 'p', 'P', 'i', 'I')
    c.rect(CX - 4, 11, CX + 3, 20, 'G'); c.rect(CX - 4, 19, CX + 3, 20, 'R')
    c.rect(CX - 1, 13, CX, 16, 'g')
    c.mirror_rect(CX - 6, 11, CX - 5, 13, 'G'); c.mirror_rect(CX - 6, 14, CX - 5, 16, 'S')
    c.mirror_rect(CX - 7, 17, CX - 5, 20, 'I')
    c.rect(CX - 3, 3, CX + 2, 10, 'A'); c.rect(CX - 1, 0, CX, 2, 'A')


def im_side(c, pose):
    legs_side(c, pose, 22, 'P', 'p', 'i', 'I')
    c.rect(CX - 3, 11, CX + 3, 20, 'G'); c.rect(CX - 3, 19, CX + 3, 20, 'R')
    c.rect(CX, 12, CX + 3, 14, 'g'); c.put(CX + 2, 13, 'O')
    c.rect(CX - 1, 13, CX + 1, 15, 'S'); c.rect(CX + 2, 14, CX + 4, 16, 'I'); c.put(CX + 4, 14, 'L')
    c.rect(CX - 2, 5, CX + 2, 10, 'S'); c.rect(CX - 2, 5, CX - 1, 9, 'A'); c.put(CX + 1, 7, 'A')
    c.rect(CX - 2, 3, CX + 2, 4, 'A'); c.rect(CX - 2, 1, CX - 1, 2, 'A')


# ============================================================ RYN, Act II
# Storm Dragon: blue-and-gold gi, a dragon-scale pauldron, long headband
# tails, spikier hair, lightning crackling at the fists.
STORM_DRAGON = {
    'B': (60, 104, 200), 'b': (34, 64, 140), 'G': (232, 188, 64), 'g': (166, 122, 30),
    'S': (226, 168, 128), 's': (172, 112, 84),
    'A': (40, 30, 34), 'a': (70, 54, 52), 'T': (240, 240, 248),         # hair, white headband
    'P': (36, 40, 70), 'p': (24, 26, 48),
    'x': (150, 240, 255), 'X': (255, 255, 255),                         # lightning (wisps)
    'E': (255, 240, 170),
}


def sd_front(c, pose):
    legs_front(c, pose, 22, 'P', 'p', 'g', 'G')
    c.rect(CX - 5, 11, CX + 4, 19, 'B'); c.mirror_rect(CX - 5, 11, CX - 5, 19, 'b')
    c.rect(CX - 1, 11, CX, 15, 'S'); c.mirror_rect(CX - 2, 11, CX - 2, 18, 'G')
    c.rect(CX - 5, 19, CX + 4, 21, 'G'); c.rect(CX - 5, 20, CX + 4, 20, 'g')
    # dragon-scale pauldron on the viewer's left
    c.rect(CX - 8, 10, CX - 5, 13, 'G'); c.put(CX - 7, 11, 'g'); c.put(CX - 6, 12, 'g'); c.put(CX - 8, 10, 'E')
    c.rect(CX + 4, 11, CX + 6, 13, 'B')
    c.mirror_rect(CX - 7, 14, CX - 6, 17, 'S')
    c.mirror_rect(CX - 8, 18, CX - 6, 21, 'G'); c.mirror_put(CX - 7, 18, 'E')
    # lightning at the fists
    for i, (x, y) in enumerate(((CX - 9, 17), (CX - 10, 19), (CX - 9, 22))):
        if (i + k(pose)) % 3 != 2:
            c.mirror_put(x, y, 'x')
    c.mirror_put(CX - 10, 18 + k(pose) % 2, 'X')
    # head: spikier hair, glowing eyes, headband
    c.rect(CX - 3, 5, CX + 2, 10, 'S'); c.rect(CX - 3, 9, CX + 2, 10, 's')
    c.put(CX - 2, 7, 'E'); c.put(CX + 1, 7, 'E')
    c.rect(CX - 3, 5, CX + 2, 5, 'T')
    c.rect(CX - 4, 2, CX + 3, 4, 'A')
    for x, top in ((CX - 4, 1), (CX - 2, 0), (CX + 1, 0), (CX + 3, 1)):
        c.put(x, top, 'A'); c.put(x, top + 1, 'A')
    c.put(CX - 1, 3, 'a')


def sd_back(c, pose):
    legs_front(c, pose, 22, 'p', 'P', 'g', 'G')
    c.rect(CX - 5, 11, CX + 4, 19, 'B')
    c.rect(CX - 2, 12, CX + 1, 16, 'G'); c.rect(CX - 1, 13, CX, 15, 'b')   # dragon crest
    c.rect(CX - 5, 19, CX + 4, 21, 'G')
    c.rect(CX + 4, 10, CX + 7, 13, 'G'); c.rect(CX - 6, 11, CX - 4, 13, 'B')
    c.mirror_rect(CX - 7, 14, CX - 6, 17, 'S'); c.mirror_rect(CX - 8, 18, CX - 6, 21, 'G')
    sway = (0, 1, -1)[k(pose)]
    for y in range(6, 15):
        c.put(CX - 1 + sway * (y - 6) // 4, y, 'T'); c.put(CX + 1 + sway * (y - 6) // 3, y, 'T')
    c.rect(CX - 3, 5, CX + 2, 10, 'A'); c.rect(CX - 3, 5, CX + 2, 5, 'T')
    c.rect(CX - 4, 2, CX + 3, 4, 'A')
    for x, top in ((CX - 4, 1), (CX - 2, 0), (CX + 1, 0), (CX + 3, 1)):
        c.put(x, top, 'A'); c.put(x, top + 1, 'A')


def sd_side(c, pose):
    legs_side(c, pose, 22, 'P', 'p', 'g', 'G')
    c.rect(CX - 3, 11, CX + 3, 19, 'B'); c.rect(CX + 1, 11, CX + 3, 15, 'S'); c.rect(CX, 11, CX, 18, 'G')
    c.rect(CX - 3, 19, CX + 3, 21, 'G')
    c.rect(CX - 3, 10, CX, 13, 'G'); c.put(CX - 2, 11, 'g')
    c.rect(CX + 1, 13, CX + 3, 15, 'S'); c.rect(CX + 4, 12, CX + 6, 15, 'G'); c.put(CX + 5, 12, 'E')
    c.put(CX + 7, 13 + k(pose) % 2, 'x'); c.put(CX + 8, 12, 'X' if k(pose) else 'x'); c.put(CX + 7, 16, 'x')
    c.rect(CX - 2, 5, CX + 2, 10, 'S'); c.rect(CX - 2, 5, CX - 1, 10, 'A'); c.put(CX + 1, 7, 'E')
    c.rect(CX - 2, 5, CX + 2, 5, 'T')
    c.rect(CX - 3, 2, CX + 2, 4, 'A')
    for x, top in ((CX - 3, 1), (CX - 1, 0), (CX + 1, 1)):
        c.put(x, top, 'A')
    for i in range(6):
        c.put(CX - 3 - i, 5 + (i + k(pose)) // 3, 'T')


# ============================================================ LYRA, Act I
# Arcane Scholar: a purple scholar's robe with the hood down, a floating
# open spellbook, a gem-topped staff.
ARCANE_SCHOLAR = {
    'U': (120, 76, 176), 'u': (78, 46, 124), 'G': (226, 192, 96),
    'H': (96, 58, 146),                                                 # hood
    'S': (240, 200, 176), 's': (200, 150, 130),
    'A': (200, 70, 50), 'a': (130, 40, 36),
    'W': (120, 84, 56), 'w': (80, 54, 36), 'M': (200, 120, 255),        # staff, gem
    'P': (246, 238, 214), 'p': (190, 176, 150), 'K2': None,             # book pages
    'x': (220, 180, 255),
}


def lyra_robe(c, top, body, shade, trim, flare=3):
    for y in range(top, FEET + 1):
        half = 4 + (y - top) // flare
        c.rect(CX - half, y, CX + half - 1, y, body)
        c.put(CX - half, y, shade); c.put(CX + half - 1, y, shade)
    half = 4 + (FEET - top) // flare
    c.rect(CX - half, FEET, CX + half - 1, FEET, trim)


def as_front(c, pose):
    lyra_robe(c, 11, 'U', 'u', 'G', flare=4)
    c.rect(CX - 1, 12, CX, FEET - 1, 'G')
    c.rect(CX - 5, 10, CX + 4, 12, 'H')                                    # hood down on the shoulders
    c.mirror_rect(CX - 6, 13, CX - 5, 18, 'U'); c.mirror_put(CX - 6, 19, 'S')
    # staff, viewer's right
    c.rect(CX + 7, 4, CX + 7, FEET, 'W'); c.rect(CX + 6, 2, CX + 8, 4, 'G'); c.put(CX + 7, 3, 'M')
    # floating book, viewer's left
    b = k(pose) % 2
    c.rect(CX - 10, 15 - b, CX - 7, 17 - b, 'P'); c.rect(CX - 9, 15 - b, CX - 9, 17 - b, 'p')
    c.put(CX - 10, 14 - b, 'x')
    c.rect(CX - 4, 4, CX + 3, 11, 'A')
    c.rect(CX - 2, 4, CX + 1, 9, 'S'); c.rect(CX - 2, 9, CX + 1, 9, 's')
    c.put(CX - 2, 6, 'a'); c.put(CX + 1, 6, 'a')
    c.rect(CX - 3, 2, CX + 2, 3, 'A')


def as_back(c, pose):
    lyra_robe(c, 11, 'U', 'u', 'G', flare=4)
    c.rect(CX - 5, 10, CX + 4, 14, 'H'); c.rect(CX - 4, 14, CX + 3, 14, 'G')
    c.mirror_rect(CX - 6, 13, CX - 5, 18, 'U')
    c.rect(CX - 8, 4, CX - 8, FEET, 'W'); c.rect(CX - 9, 2, CX - 7, 4, 'G')
    c.rect(CX - 4, 2, CX + 3, 12, 'A'); c.rect(CX - 1, 4, CX, 12, 'a')


def as_side(c, pose):
    lyra_robe(c, 11, 'U', 'u', 'G', flare=4)
    c.rect(CX - 4, 10, CX + 1, 12, 'H')
    c.rect(CX, 13, CX + 2, 14, 'U'); c.put(CX + 3, 14, 'S')
    c.rect(CX + 4, 3, CX + 4, FEET, 'W'); c.rect(CX + 3, 1, CX + 5, 3, 'G'); c.put(CX + 4, 2, 'M')
    c.rect(CX - 3, 3, CX + 2, 11, 'A'); c.rect(CX, 4, CX + 2, 9, 'S'); c.put(CX + 1, 6, 'a')
    b = k(pose) % 2
    c.rect(CX - 9, 15 - b, CX - 7, 17 - b, 'P'); c.put(CX - 8, 15 - b, 'p')


# ============================================================ LYRA, Act II
# Elemental Weave: a crimson layered robe with a flame-edged hem, a jewelled
# circlet, a crystal staff, four elemental motes orbiting her.
ELEMENTAL_WEAVE = {
    'R': (186, 50, 60), 'r': (120, 28, 40), 'O': (240, 140, 50),        # robe, flame hem
    'M': (90, 30, 50),                                                  # mantle
    'G': (236, 200, 110),
    'S': (240, 200, 176), 's': (200, 150, 130),
    'A': (200, 70, 50), 'a': (130, 40, 36),
    'W': (120, 84, 56), 'C': (170, 230, 255), 'c': (90, 170, 230),
    'E': (140, 230, 255),
    'f': (255, 120, 40), 'x': (150, 230, 255), 'F': (255, 240, 120), 'o': (120, 200, 90),  # motes
}


def ew_motes(c, pose, spots):
    order = ['f', 'x', 'F', 'o']
    for i, (x, y) in enumerate(spots):
        c.put(x, y, order[(i + k(pose)) % 4])


def ew_front(c, pose):
    lyra_robe(c, 11, 'R', 'r', 'O', flare=3)
    for x in range(CX - 9, CX + 9, 2):
        c.put(x, FEET - 1, 'O') if c.g[FEET - 1][x] != '.' else None
    c.rect(CX - 1, 12, CX, FEET - 1, 'G')
    c.mirror_rect(CX - 7, 11, CX - 3, 13, 'M'); c.mirror_put(CX - 7, 11, 'G')      # layered mantle
    c.mirror_rect(CX - 7, 14, CX - 6, 19, 'R'); c.mirror_rect(CX - 7, 20, CX - 6, 20, 'G')
    c.put(CX - 7, 21, 'S'); c.put(CX + 6, 21, 'S')
    c.rect(CX + 8, 3, CX + 8, FEET, 'W'); c.rect(CX + 7, 0, CX + 9, 3, 'C'); c.put(CX + 8, 1, 'c')
    c.rect(CX - 4, 4, CX + 3, 12, 'A')
    c.rect(CX - 2, 4, CX + 1, 9, 'S'); c.rect(CX - 2, 9, CX + 1, 9, 's')
    c.put(CX - 2, 6, 'E'); c.put(CX + 1, 6, 'E')
    c.rect(CX - 3, 3, CX + 2, 3, 'G'); c.put(CX - 1, 2, 'C'); c.put(CX, 2, 'C')   # circlet + gem
    c.rect(CX - 3, 1, CX + 2, 2, 'A'); c.put(CX - 1, 2, 'C'); c.put(CX, 2, 'C')
    ew_motes(c, pose, [(CX - 10, 9), (CX - 10, 18), (CX + 10, 12), (CX + 10, 21)])


def ew_back(c, pose):
    lyra_robe(c, 11, 'R', 'r', 'O', flare=3)
    c.mirror_rect(CX - 7, 11, CX - 3, 13, 'M'); c.rect(CX - 3, 11, CX + 2, 13, 'M')
    c.mirror_rect(CX - 7, 14, CX - 6, 19, 'R')
    c.rect(CX - 9, 3, CX - 9, FEET, 'W'); c.rect(CX - 10, 0, CX - 8, 3, 'C')
    c.rect(CX - 4, 2, CX + 3, 16, 'A'); c.rect(CX - 1, 4, CX, 16, 'a'); c.rect(CX - 3, 3, CX + 2, 3, 'G')
    ew_motes(c, pose, [(CX + 9, 9), (CX + 10, 18), (CX - 11, 12), (CX - 11, 21)])


def ew_side(c, pose):
    lyra_robe(c, 11, 'R', 'r', 'O', flare=3)
    c.rect(CX - 4, 11, CX + 1, 13, 'M')
    c.rect(CX, 14, CX + 3, 15, 'R'); c.put(CX + 4, 15, 'S')
    c.rect(CX + 5, 2, CX + 5, FEET, 'W'); c.rect(CX + 4, 0, CX + 6, 2, 'C')
    c.rect(CX - 3, 4, CX + 2, 12, 'A'); c.rect(CX, 4, CX + 2, 9, 'S'); c.put(CX + 1, 6, 'E')
    c.rect(CX - 3, 3, CX + 2, 3, 'G'); c.put(CX + 2, 2, 'C')
    for i in range(4):
        c.rect(CX - 4 - i, 6 + (i + k(pose)) // 2, CX - 4 - i, 10 + (i + k(pose)) // 2, 'A')
    ew_motes(c, pose, [(CX - 10, 10), (CX + 9, 8), (CX - 9, 20), (CX + 8, 22)])


# ============================================================ SILAS, Act I
# Shadow Walker: a violet hood and short cloak, a face mask, a violet scarf,
# twin daggers.
SHADOW_WALKER = {
    'H': (70, 56, 96), 'h': (44, 34, 64), 'j': (96, 80, 128),          # hood / cloak
    'M': (40, 34, 48),                                                  # mask
    'E': (230, 220, 255),                                               # eyes
    'V': (130, 70, 170), 'v': (84, 40, 116),                            # scarf
    'P': (52, 46, 60), 'p': (34, 30, 40), 'N': (90, 64, 46),
    'L': (210, 216, 228), 'l': (130, 136, 150),
}


def sw_front(c, pose):
    legs_front(c, pose, 21, 'P', 'p', 'p', 'P')
    for y in range(11, 21):   # short cloak
        half = 5 + (y - 11) // 4
        c.rect(CX - half, y, CX + half - 1, y, 'H')
        c.put(CX - half, y, 'h'); c.put(CX + half - 1, y, 'h')
    c.rect(CX - 2, 12, CX + 1, 21, 'P'); c.rect(CX - 2, 18, CX + 1, 18, 'N')
    c.mirror_rect(CX - 6, 14, CX - 5, 18, 'H')
    c.mirror_rect(CX - 7, 18, CX - 7, 21, 'L'); c.mirror_put(CX - 7, 17, 'N')     # daggers
    c.rect(CX - 3, 10, CX + 2, 11, 'V'); c.rect(CX + 2, 11, CX + 3, 14 + k(pose) % 2, 'V')
    c.rect(CX - 4, 3, CX + 3, 10, 'H'); c.mirror_rect(CX - 4, 4, CX - 4, 10, 'h')
    c.rect(CX - 2, 5, CX + 1, 9, 'M'); c.put(CX - 2, 6, 'E'); c.put(CX + 1, 6, 'E')
    c.rect(CX - 2, 2, CX + 1, 2, 'H'); c.put(CX - 1, 3, 'j')


def sw_back(c, pose):
    legs_front(c, pose, 21, 'p', 'P', 'p', 'P')
    for y in range(10, 22):
        half = 5 + (y - 10) // 4
        c.rect(CX - half, y, CX + half - 1, y, 'H')
    c.rect(CX - 1, 12, CX, 21, 'h')
    c.mirror_rect(CX - 7, 18, CX - 7, 21, 'L')
    sway = (0, 1, -1)[k(pose)]
    for y in range(11, 17):
        c.put(CX + (y - 11) * sway // 3, y, 'V')
    c.rect(CX - 4, 2, CX + 3, 10, 'H'); c.rect(CX - 1, 3, CX, 10, 'h')


def sw_side(c, pose):
    legs_side(c, pose, 21, 'P', 'p', 'p', 'P')
    for y in range(11, 22):
        back = 2 + (y - 11) // 4 + (0, 1, 0)[k(pose)]
        c.rect(CX - 2 - back, y, CX + 1, y, 'H')
    c.rect(CX - 1, 12, CX + 2, 21, 'P')
    c.rect(CX, 14, CX + 2, 15, 'H'); c.rect(CX + 3, 15, CX + 5, 15, 'L')
    c.rect(CX - 2, 10, CX + 2, 11, 'V')
    for i in range(4):
        c.put(CX - 3 - i, 10 + (i + k(pose)) // 3, 'V')
    c.rect(CX - 3, 3, CX + 2, 10, 'H'); c.rect(CX, 5, CX + 2, 9, 'M'); c.put(CX + 1, 6, 'E')


# ============================================================ SILAS, Act II
# Venom Weave: green-black leathers, a half mask with glowing green eyes, a
# bandolier of glowing vials, serrated blades dripping venom, toxic mist.
VENOM_WEAVE = {
    'H': (34, 48, 40), 'h': (20, 30, 24), 'j': (56, 74, 60),            # leathers / hood
    'M': (30, 26, 34), 'E': (150, 255, 90),                             # mask, eyes
    'Q': (90, 120, 70), 'q': (60, 84, 48),                              # scarf
    'P': (40, 46, 42), 'p': (26, 30, 28), 'N': (80, 58, 40),
    'V': (130, 240, 80), 'v': (70, 160, 40),                            # vials
    'L': (200, 220, 200), 'l': (110, 140, 110),
    'o': (130, 240, 80), 'O': (190, 255, 140),                          # venom drips / mist (wisps)
}


def vw_front(c, pose):
    legs_front(c, pose, 21, 'P', 'p', 'p', 'P')
    for y in range(11, 24):   # longer cloak, ragged
        half = 5 + (y - 11) // 3
        c.rect(CX - half, y, CX + half - 1, y, 'H')
        c.put(CX - half, y, 'h'); c.put(CX + half - 1, y, 'h')
    for x in range(CX - 9, CX + 9, 2):
        c.put(x, 23, '.')
    c.rect(CX - 2, 12, CX + 1, 21, 'P')
    for i in range(5):   # bandolier with glowing vials
        c.put(CX - 3 + i, 12 + i, 'N')
        if i % 2 == 0:
            c.put(CX - 3 + i, 13 + i, 'V')
    c.mirror_rect(CX - 6, 14, CX - 5, 18, 'H')
    # serrated blades, dripping
    c.mirror_rect(CX - 8, 18, CX - 8, 23, 'L'); c.mirror_put(CX - 9, 19, 'l'); c.mirror_put(CX - 9, 21, 'l')
    c.mirror_put(CX - 8, 17, 'N')
    c.mirror_put(CX - 8, 24 + k(pose) % 2, 'o')
    c.rect(CX - 3, 10, CX + 2, 11, 'Q'); c.rect(CX + 2, 11, CX + 3, 15 + k(pose) % 2, 'Q')
    c.rect(CX - 4, 3, CX + 3, 10, 'H'); c.mirror_rect(CX - 4, 4, CX - 4, 10, 'h')
    c.rect(CX - 2, 5, CX + 1, 6, 'j'); c.rect(CX - 2, 7, CX + 1, 9, 'M')       # half mask
    c.put(CX - 2, 6, 'E'); c.put(CX + 1, 6, 'E')
    c.mirror_put(CX - 4, 2, 'H'); c.mirror_put(CX - 3, 2, 'H'); c.rect(CX - 2, 2, CX + 1, 2, 'H')
    for x, y in ((CX - 7, FEET), (CX + 6, FEET - 1), (CX - 9, FEET - 1)):   # mist at the feet
        c.put(x + k(pose) % 2, y, 'O' if (x + k(pose)) % 3 == 0 else 'o')


def vw_back(c, pose):
    legs_front(c, pose, 21, 'p', 'P', 'p', 'P')
    for y in range(10, 25):
        half = 5 + (y - 10) // 3
        c.rect(CX - half, y, CX + half - 1, y, 'H')
    for x in range(CX - 9, CX + 9, 2):
        c.put(x, 24, '.')
    c.rect(CX - 1, 12, CX, 22, 'h')
    for i in range(6):
        c.put(CX + 3 - i, 12 + i, 'N')
        if i % 2:
            c.put(CX + 3 - i, 13 + i, 'V')
    c.mirror_rect(CX - 8, 18, CX - 8, 23, 'L')
    c.rect(CX - 4, 2, CX + 3, 10, 'H'); c.rect(CX - 1, 3, CX, 10, 'h')
    sway = (0, 1, -1)[k(pose)]
    for y in range(11, 18):
        c.put(CX + (y - 11) * sway // 3, y, 'Q')


def vw_side(c, pose):
    legs_side(c, pose, 21, 'P', 'p', 'p', 'P')
    for y in range(11, 25):
        back = 2 + (y - 11) // 3 + (0, 1, 0)[k(pose)]
        c.rect(CX - 2 - back, y, CX + 1, y, 'H')
    for x in range(CX - 9, CX + 2, 2):
        c.put(x, 24, '.')
    c.rect(CX - 1, 12, CX + 2, 21, 'P'); c.put(CX, 14, 'V'); c.put(CX + 1, 17, 'V')
    c.rect(CX, 14, CX + 2, 15, 'H')
    for i in range(5):
        c.put(CX + 3 + i, 15 - i // 3, 'L')
    c.put(CX + 5, 16, 'l'); c.put(CX + 7, 17 + k(pose) % 2, 'o')
    c.rect(CX - 2, 10, CX + 2, 11, 'Q')
    for i in range(5):
        c.put(CX - 3 - i, 10 + (i + k(pose)) // 3, 'Q')
    c.rect(CX - 3, 3, CX + 2, 10, 'H'); c.rect(CX, 7, CX + 2, 9, 'M'); c.put(CX + 1, 6, 'E')
    c.put(CX - 3, 2, 'H'); c.put(CX - 2, 2, 'H')


# (hero, set) -> palette and views. Act III's come from build_act3_forms.py.
FORMS = {
    ('vael', 'holy_guardian'): (HOLY_GUARDIAN, hg_front, hg_back, hg_side),
    ('vael', 'sacred_aegis'): (SACRED_AEGIS, sa_front, sa_back, sa_side),
    ('vael', 'divine_champion'): (A.VAEL, A.vael_front, A.vael_back, A.vael_side),
    ('ryn', 'iron_monk'): (IRON_MONK, im_front, im_back, im_side),
    ('ryn', 'storm_dragon'): (STORM_DRAGON, sd_front, sd_back, sd_side),
    ('ryn', 'rising_force'): (A.RYN, A.ryn_front, A.ryn_back, A.ryn_side),
    ('lyra', 'arcane_scholar'): (ARCANE_SCHOLAR, as_front, as_back, as_side),
    ('lyra', 'elemental_weave'): (ELEMENTAL_WEAVE, ew_front, ew_back, ew_side),
    ('lyra', 'cosmic_conduit'): (A.LYRA, A.lyra_front, A.lyra_back, A.lyra_side),
    ('silas', 'shadow_walker'): (SHADOW_WALKER, sw_front, sw_back, sw_side),
    ('silas', 'venom_weave'): (VENOM_WEAVE, vw_front, vw_back, vw_side),
    ('silas', 'deaths_hand'): (A.SILAS, A.silas_front, A.silas_back, A.silas_side),
}


def sheet(key):
    pal, front, back, side = FORMS[key]
    out = Image.new('RGBA', (A.W * 3, A.H * 3), (0, 0, 0, 0))
    for r, draw in enumerate((front, back, side)):
        for col, pose in enumerate(POSES):
            out.paste(A.render(pal, draw, pose), (col * A.W, r * A.H))
    return out


if __name__ == '__main__':
    out_dir = sys.argv[1]
    sheets = {key: sheet(key) for key in FORMS}
    for (hero, set_id), s in sheets.items():
        s.save(os.path.join(out_dir, '%s_%s_walk.png' % (hero, set_id)))
    if len(sys.argv) > 2:
        # one row per hero: base idle-down, then each set's three facings
        rows = []
        for hero in ('vael', 'ryn', 'lyra', 'silas'):
            row = Image.new('RGBA', (A.W * 10, A.H), (0, 0, 0, 0))
            base = Image.open(os.path.join(out_dir, '%s_walk.png' % hero)).convert('RGBA')
            row.paste(base.crop((0, 0, 16, 32)), (4, 0))
            col = 1
            for (h, set_id), s in sheets.items():
                if h != hero:
                    continue
                for r in range(3):
                    row.paste(s.crop((0, r * A.H, A.W, (r + 1) * A.H)), (col * A.W, 0))
                    col += 1
            rows.append(row)
        prev = Image.new('RGBA', (A.W * 10 + 8, (A.H + 4) * 4 + 4), (52, 46, 64, 255))
        for i, row in enumerate(rows):
            prev.alpha_composite(row, (4, 4 + i * (A.H + 4)))
        prev.resize((prev.width * 4, prev.height * 4), Image.NEAREST).save(sys.argv[2])
