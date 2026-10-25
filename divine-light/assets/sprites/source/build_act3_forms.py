"""The heroes' Act III forms (Cory, 2026-10-25: "the final set should
completely change the characters... more powerful, ready to kick ass").
Wearing a complete Act III set swaps the whole walk sheet for one of these
instead of recoloring (SetLooks.FORMS).

Same layout as the base walk sheets (rows down / up / right, columns idle /
stepA / stepB; left = right flipped) but each frame is 24x32 instead of
16x32, so pauldrons, wings, capes and auras can reach past the body. The body
stays centred on the same 16px column, feet on the same row, so the forms
stand exactly where the base sprites do.

Drawn on a small canvas like the boss sprites: parts placed as spans and
pixels, the dark outline added around the silhouette at the end. Characters
in WISPS (auras, sparks) float free with no outline.

Usage: python build_act3_forms.py <out_dir> [preview.png]
"""
import os
import sys

from PIL import Image

W, H = 24, 32
FEET = 29          # last row of the boots (row 30 is their outline)
CX = 12            # body centre: cols 4..19 are the old 16px frame
OUTLINE = (26, 20, 32)
WISPS = set('fFxXoO*')


class Canvas:
    def __init__(self):
        self.g = [['.'] * W for _ in range(H)]

    def put(self, x, y, ch):
        if 0 <= x < W and 0 <= y < H and ch != ' ':
            self.g[y][x] = ch

    def rect(self, x0, y0, x1, y1, ch):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.put(x, y, ch)

    def mirror_put(self, x, y, ch):
        """x is on the viewer's left; also draws the mirrored pixel."""
        self.put(x, y, ch)
        self.put(2 * CX - 1 - x, y, ch)

    def mirror_rect(self, x0, y0, x1, y1, ch):
        self.rect(x0, y0, x1, y1, ch)
        self.rect(2 * CX - 1 - x1, y0, 2 * CX - 1 - x0, y1, ch)

    def outline(self):
        src = [r[:] for r in self.g]
        for y in range(H):
            for x in range(W):
                if src[y][x] != '.':
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < W and 0 <= ny < H and src[ny][nx] not in '.K' and src[ny][nx] not in WISPS:
                        self.g[y][x] = 'K'
                        break


# ------------------------------------------------------------------ legs
def legs_front(c, pose, top, thigh, shin, boot, boot_hi, gap=1, width=3):
    """Two legs from `top` to the feet. stepA lifts the viewer-right leg 2px,
    stepB the viewer-left one (the base sheets' rhythm)."""
    lx0 = CX - gap - width
    rx0 = CX + gap
    for i, x0 in enumerate((lx0, rx0)):
        lift = 2 if (pose == 'stepA' and i == 1) or (pose == 'stepB' and i == 0) else 0
        bottom = FEET - lift
        c.rect(x0, top, x0 + width - 1, bottom - 3, thigh)
        c.rect(x0, top + 1, x0, bottom - 3, shin)
        c.rect(x0 - (1 if i == 0 else 0), bottom - 2, x0 + width - 1 + (1 if i == 1 else 0), bottom, boot)
        c.rect(x0, bottom - 2, x0 + width - 1, bottom - 2, boot_hi)
    for y in range(top, FEET + 1):
        if c.g[y][CX - 1] == '.' and c.g[y][CX] == '.':
            pass


def legs_side(c, pose, top, thigh, shin, boot, boot_hi):
    """Profile legs (facing right): idle together, stepA near leg forward,
    stepB near leg back."""
    if pose == 'idle':
        spots = [(CX - 2, 0), (CX, 0)]
    elif pose == 'stepA':
        spots = [(CX - 3, -1), (CX + 1, 1)]
    else:
        spots = [(CX + 1, -1), (CX - 3, 1)]
    for k, (x, lean) in enumerate(spots):
        ch = shin if k == 0 else thigh  # far leg darker
        for y in range(top, FEET - 2):
            off = lean * (y - top) // 4
            c.rect(x + off, y, x + off + 2, y, ch)
        off = lean * (FEET - 2 - top) // 4
        c.rect(x + off, FEET - 2, x + off + 3, FEET, boot)
        c.rect(x + off, FEET - 2, x + off + 2, FEET - 2, boot_hi)


# ================================================================== VAEL
VAEL = {
    'P': (236, 236, 246), 'p': (172, 178, 202), 'q': (120, 126, 156),   # pearl plate
    'L': (244, 210, 112), 'S': (206, 160, 64), 'D': (140, 98, 40),       # gold
    'W': (255, 250, 228),                                               # gleam
    'C': (64, 94, 196), 'c': (36, 54, 124),                             # royal cape
    'E': (150, 236, 255),                                               # visor glow
    'H': (255, 246, 196), 'h': (214, 184, 112),                         # wings
    'B': (232, 242, 255), 'b': (150, 170, 206),                         # blade
    'V': (14, 10, 20),
    'x': (255, 250, 200),                                               # sparkle (wisp)
}


def vael_front(c, pose):
    # cape behind, flaring
    for y in range(12, FEET):
        half = 7 + (y - 12) // 4
        c.rect(CX - half, y, CX + half - 1, y, 'c' if (y + (pose == 'stepA')) % 3 == 0 else 'C')
    legs_front(c, pose, 24, 'P', 'p', 'S', 'L')
    # tassets
    c.rect(CX - 4, 21, CX + 3, 23, 'p')
    c.mirror_rect(CX - 4, 23, CX - 3, 23, 'S')
    c.rect(CX - 4, 21, CX + 3, 21, 'S')  # belt
    c.put(CX - 1, 21, 'L'); c.put(CX, 21, 'L')
    # chest plate with the sun
    c.rect(CX - 4, 12, CX + 3, 20, 'P')
    c.mirror_rect(CX - 4, 13, CX - 4, 20, 'p')
    c.rect(CX - 2, 14, CX + 1, 17, 'S')
    c.rect(CX - 1, 13, CX, 18, 'L')
    c.rect(CX - 2, 15, CX + 1, 16, 'L')
    c.put(CX - 1, 15, 'W'); c.put(CX, 16, 'W')
    # great pauldrons
    for i, (x0, x1) in enumerate([(CX - 8, CX - 4), (CX - 9, CX - 4), (CX - 9, CX - 4), (CX - 8, CX - 5)]):
        c.mirror_rect(x0, 11 + i, x1, 11 + i, 'L' if i == 0 else ('S' if i < 3 else 'D'))
    c.mirror_put(CX - 7, 11, 'W')
    # arms
    c.mirror_rect(CX - 7, 15, CX - 5, 19, 'p')
    c.mirror_rect(CX - 7, 20, CX - 5, 21, 'S')  # gauntlets
    # greatsword, point down at the viewer's left
    c.rect(CX - 10, 17, CX - 9, FEET - 1, 'B')
    c.rect(CX - 9, 18, CX - 9, FEET - 1, 'b')
    c.rect(CX - 11, 16, CX - 6, 16, 'S')  # crossguard
    c.put(CX - 11, 16, 'L')
    c.rect(CX - 10, 14, CX - 9, 15, 'D')  # grip
    c.put(CX - 10, 13, 'L')
    # tower shield at the viewer's right
    c.rect(CX + 5, 15, CX + 10, 25, 'P')
    c.rect(CX + 5, 15, CX + 10, 15, 'S'); c.rect(CX + 5, 25, CX + 10, 25, 'S')
    c.rect(CX + 5, 15, CX + 5, 25, 'S'); c.rect(CX + 10, 15, CX + 10, 25, 'S')
    c.rect(CX + 7, 17, CX + 8, 23, 'L'); c.rect(CX + 6, 19, CX + 9, 21, 'L')
    c.put(CX + 7, 20, 'W')
    # helm with wings and crest
    c.rect(CX - 3, 3, CX + 2, 10, 'P')
    c.mirror_rect(CX - 3, 4, CX - 3, 10, 'p')
    c.rect(CX - 3, 3, CX + 2, 3, 'S')
    c.rect(CX - 2, 6, CX + 1, 6, 'E')
    c.rect(CX - 1, 7, CX, 9, 'E')   # T-visor
    c.rect(CX - 3, 10, CX + 2, 10, 'S')
    c.rect(CX - 1, 0, CX, 2, 'L')   # crest
    c.put(CX - 1, 0, 'W')
    for k, (dx, dy) in enumerate(((4, 5), (5, 4), (6, 3), (7, 2), (8, 1))):
        c.mirror_put(CX - dx, dy, 'H')
        c.mirror_put(CX - dx, dy + 1, 'H')
        c.mirror_put(CX - dx, dy + 2, 'h')
    if pose != 'idle':
        c.put(CX + 9 if pose == 'stepA' else CX - 11, 9, 'x')


def vael_back(c, pose):
    legs_front(c, pose, 24, 'p', 'q', 'S', 'L')
    # the cape covers the back, gold-hemmed, swaying
    sway = {'idle': 0, 'stepA': 1, 'stepB': -1}[pose]
    for y in range(12, FEET):
        half = 7 + (y - 12) // 4
        s = sway if y > 20 else 0
        c.rect(CX - half + s, y, CX + half - 1 + s, y, 'C')
        c.put(CX - 2 + s, y, 'c'); c.put(CX + 2 + s, y, 'c')
    c.rect(CX - 11 + sway, FEET - 2, CX + 10 + sway, FEET - 2, 'S')
    # pauldrons over the cape
    for i, (x0, x1) in enumerate([(CX - 8, CX - 4), (CX - 9, CX - 4), (CX - 9, CX - 4)]):
        c.mirror_rect(x0, 11 + i, x1, 11 + i, 'L' if i == 0 else 'S')
    c.rect(CX - 4, 11, CX + 3, 12, 'p')  # collar
    # sword hilt over the right shoulder, shield rim on the left
    c.rect(CX + 7, 6, CX + 8, 10, 'D'); c.rect(CX + 5, 10, CX + 10, 10, 'S')
    c.rect(CX - 11, 15, CX - 10, 24, 'S')
    # helm, back
    c.rect(CX - 3, 3, CX + 2, 10, 'P')
    c.rect(CX + 1, 4, CX + 2, 10, 'p')
    c.rect(CX - 3, 3, CX + 2, 3, 'S'); c.rect(CX - 3, 10, CX + 2, 10, 'S')
    c.rect(CX - 1, 0, CX, 9, 'L')  # crest runs down the back
    for dx, dy in ((4, 5), (5, 4), (6, 3), (7, 2), (8, 1)):
        c.mirror_put(CX - dx, dy, 'H'); c.mirror_put(CX - dx, dy + 1, 'H'); c.mirror_put(CX - dx, dy + 2, 'h')


def vael_side(c, pose):
    sway = {'idle': 0, 'stepA': 1, 'stepB': 0}[pose]
    # cape streaming behind (left)
    for y in range(12, FEET):
        back = 3 + (y - 12) // 3 + sway
        c.rect(CX - 2 - back, y, CX - 1, y, 'C' if y % 3 else 'c')
    legs_side(c, pose, 23, 'P', 'p', 'S', 'L')
    c.rect(CX - 3, 21, CX + 3, 23, 'p'); c.rect(CX - 3, 21, CX + 3, 21, 'S')
    c.rect(CX - 3, 12, CX + 3, 20, 'P'); c.rect(CX - 3, 12, CX - 2, 20, 'p')
    c.rect(CX + 1, 14, CX + 3, 17, 'S'); c.put(CX + 2, 15, 'L')
    # pauldron
    c.rect(CX - 3, 10, CX + 2, 11, 'L'); c.rect(CX - 4, 12, CX + 2, 13, 'S'); c.rect(CX - 3, 14, CX + 1, 14, 'D')
    # arm forward holding the greatsword raised
    c.rect(CX, 15, CX + 2, 18, 'p'); c.rect(CX + 2, 17, CX + 4, 18, 'S')
    c.rect(CX + 5, 3, CX + 6, 16, 'B'); c.rect(CX + 6, 4, CX + 6, 16, 'b')
    c.put(CX + 5, 2, 'W'); c.rect(CX + 3, 17, CX + 8, 17, 'S'); c.rect(CX + 5, 18, CX + 6, 19, 'D')
    # helm in profile: visor slit facing right, wing swept back
    c.rect(CX - 3, 3, CX + 2, 10, 'P'); c.rect(CX - 3, 4, CX - 2, 10, 'p')
    c.rect(CX - 3, 3, CX + 2, 3, 'S'); c.rect(CX - 3, 10, CX + 2, 10, 'S')
    c.rect(CX, 6, CX + 2, 6, 'E')
    c.rect(CX - 2, 0, CX, 2, 'L')
    for dx, dy in ((4, 5), (5, 4), (6, 3), (7, 2), (8, 2)):
        c.put(CX - dx, dy, 'H'); c.put(CX - dx, dy + 1, 'H'); c.put(CX - dx, dy + 2, 'h')
    if pose == 'stepA':
        c.put(CX + 8, 1, 'x')


# ================================================================== RYN
RYN = {
    'R': (214, 52, 40), 'r': (140, 26, 24), 'G': (246, 196, 72), 'g': (176, 122, 30),
    'Y': (255, 240, 160),                                              # gauntlet gleam
    'K2': None,
    'S': (226, 168, 128), 's': (172, 112, 84),                         # skin
    'A': (40, 30, 34), 'a': (70, 52, 50),                              # hair
    'T': (255, 214, 90),                                               # headband
    'P': (52, 40, 48), 'p': (34, 26, 32),                              # trousers
    'E': (255, 236, 150),                                              # glowing eyes
    'f': (255, 150, 40), 'F': (255, 220, 110),                          # ki flame (wisps)
}


def ryn_hair(c):
    """One mass of hair swept up like a flame, side spikes flaring out,
    tips burning gold."""
    for y, (x0, x1) in zip(range(0, 5), [(CX - 2, CX), (CX - 3, CX + 2), (CX - 4, CX + 3), (CX - 5, CX + 4), (CX - 5, CX + 4)]):
        c.rect(x0, y, x1, y, 'A')
    for x, y in ((CX - 6, 3), (CX - 7, 2), (CX + 5, 3), (CX + 6, 2), (CX + 1, 0)):
        c.put(x, y, 'A')
    for x, y in ((CX - 2, 0), (CX + 1, 0), (CX - 7, 2), (CX + 6, 2), (CX - 4, 2), (CX + 3, 2)):
        c.put(x, y, 'G')
    for x, y in ((CX - 1, 1), (CX - 3, 3), (CX + 1, 2), (CX + 2, 3)):
        c.put(x, y, 'a')


def ryn_aura(c, pose, side=False):
    """Ki flames rising off the fists and feet (wisps: no outline)."""
    k = {'idle': 0, 'stepA': 1, 'stepB': 2}[pose]
    if side:
        fists = [(CX + 6, 11)]
    else:
        fists = [(CX - 9, 16), (CX + 8, 16)]
    for x, y in fists:
        c.put(x, y, 'F'); c.put(x + (k % 2), y - 1, 'f'); c.put(x - 1 + (k + 1) % 3, y - 2, 'F' if k else 'f')
        c.put(x + 1, y, 'f')
    for x in ((CX - 6, CX + 5) if not side else (CX - 4, CX + 4)):
        c.put(x, FEET - (k + x) % 2, 'f')
        c.put(x + 1, FEET - 1 - (k + x + 1) % 2, 'F')


def ryn_front(c, pose):
    legs_front(c, pose, 22, 'P', 'p', 'g', 'G', width=3)
    # sash and open gi
    c.rect(CX - 4, 19, CX + 3, 21, 'R'); c.rect(CX - 4, 20, CX + 3, 20, 'G')
    c.rect(CX - 5, 11, CX + 4, 18, 'R')
    c.rect(CX - 2, 11, CX + 1, 18, 'S')   # bare chest
    c.rect(CX - 1, 13, CX, 13, 's'); c.rect(CX - 2, 15, CX + 1, 15, 's')
    c.mirror_rect(CX - 5, 11, CX - 5, 18, 'r')
    c.mirror_rect(CX - 3, 11, CX - 3, 18, 'G')  # gold lapels
    # broad shoulders and arms out, fists blazing
    c.mirror_rect(CX - 7, 11, CX - 5, 12, 'R')
    c.mirror_rect(CX - 8, 13, CX - 6, 16, 'S')
    c.mirror_rect(CX - 10, 17, CX - 6, 21, 'G')
    c.mirror_rect(CX - 10, 17, CX - 10, 21, 'g'); c.mirror_put(CX - 9, 17, 'Y'); c.mirror_put(CX - 8, 17, 'Y')
    c.mirror_rect(CX - 9, 19, CX - 7, 19, 'g')
    sh = {'idle': 0, 'stepA': 1, 'stepB': 2}[pose]
    # head: spiked hair, glowing eyes, headband tails
    c.rect(CX - 3, 5, CX + 2, 10, 'S')
    c.rect(CX - 3, 9, CX + 2, 10, 's')
    c.put(CX - 2, 7, 'E'); c.put(CX + 1, 7, 'E')
    c.rect(CX - 3, 5, CX + 2, 5, 'T')
    ryn_hair(c)
    ryn_aura(c, pose)


def ryn_back(c, pose):
    legs_front(c, pose, 22, 'p', 'P', 'g', 'G', width=3)
    c.rect(CX - 4, 19, CX + 3, 21, 'R'); c.rect(CX - 4, 20, CX + 3, 20, 'G')
    c.rect(CX - 5, 11, CX + 4, 18, 'R')
    c.rect(CX - 1, 12, CX, 16, 'G'); c.rect(CX - 2, 13, CX + 1, 14, 'G')  # gold dragon crest on the back
    c.mirror_rect(CX - 7, 11, CX - 5, 12, 'R')
    c.mirror_rect(CX - 8, 13, CX - 6, 16, 'S')
    c.mirror_rect(CX - 9, 17, CX - 6, 20, 'G')
    # headband tails streaming down
    sway = {'idle': 0, 'stepA': 1, 'stepB': -1}[pose]
    for y in range(6, 14):
        c.put(CX - 1 + sway * (y - 6) // 4, y, 'T')
        c.put(CX + 1 + sway * (y - 6) // 3, y, 'T')
    c.rect(CX - 3, 5, CX + 2, 10, 'A')
    c.rect(CX - 3, 5, CX + 2, 5, 'T')
    ryn_hair(c)
    ryn_aura(c, pose)


def ryn_side(c, pose):
    legs_side(c, pose, 22, 'P', 'p', 'g', 'G')
    c.rect(CX - 3, 19, CX + 3, 21, 'R'); c.rect(CX - 3, 20, CX + 3, 20, 'G')
    c.rect(CX - 3, 11, CX + 3, 18, 'R'); c.rect(CX + 1, 11, CX + 3, 17, 'S')
    c.rect(CX, 11, CX, 18, 'G')
    # guard stance: fist forward, blazing
    c.rect(CX - 2, 12, CX, 13, 'R')
    c.rect(CX + 1, 13, CX + 4, 15, 'S')
    c.rect(CX + 5, 12, CX + 7, 15, 'G'); c.put(CX + 6, 12, 'Y')
    sh = {'idle': 0, 'stepA': 1, 'stepB': 2}[pose]
    # head in profile, headband tails flying back
    c.rect(CX - 2, 5, CX + 2, 10, 'S'); c.rect(CX - 2, 5, CX - 1, 10, 'A')
    c.put(CX + 1, 7, 'E')
    c.rect(CX - 2, 5, CX + 2, 5, 'T')
    c.rect(CX - 3, 1, CX + 2, 4, 'A')
    for x, top in ((CX - 5, 2), (CX - 3, 0), (CX - 1, 0), (CX + 1, 1)):
        c.rect(x, top, x + 1, 4, 'A'); c.put(x, top, 'G')
    c.rect(CX - 6, 3, CX - 4, 4, 'A'); c.put(CX - 6, 3, 'G')
    ryn_aura(c, pose, side=True)
    tail = {'idle': 0, 'stepA': 1, 'stepB': 2}[pose]
    for i in range(6):
        c.put(CX - 3 - i, 5 + (i + tail) // 3, 'T')
        c.put(CX - 3 - i, 6 + (i + tail + 1) // 3, 'T')


# ================================================================== LYRA
LYRA = {
    'N': (40, 34, 100), 'n': (22, 18, 60), 'M': (70, 60, 150),          # starfield robe
    'O': (255, 255, 255), 'o': (170, 160, 230),                         # stars (wisps)
    'G': (210, 220, 255), 'g': (130, 140, 200),                         # silver trim
    'S': (240, 200, 176), 's': (200, 150, 130),                         # skin
    'A': (200, 70, 50), 'a': (130, 40, 36), 'Y': (255, 210, 120),       # hair, glowing tips
    'C': (150, 230, 255), 'c': (80, 160, 230),                          # crystals
    'W': (120, 84, 56), 'w': (80, 54, 36),                              # staff
    'X': (255, 250, 210), 'x': (190, 220, 255),                         # staff star / motes (wisps)
    'E': (140, 230, 255),
}


def lyra_robe(c, top, pose, front=True):
    for y in range(top, FEET + 1):
        half = 4 + (y - top) // 3
        c.rect(CX - half, y, CX + half - 1, y, 'N')
        c.put(CX - half, y, 'n'); c.put(CX + half - 1, y, 'n')
    hem = FEET
    half = 4 + (hem - top) // 3
    c.rect(CX - half, hem, CX + half - 1, hem, 'G')
    if front:
        c.rect(CX - 1, top, CX, hem, 'M')  # the robe's opening, lit
    # stars inside the robe
    for i, (dx, dy) in enumerate(((-3, 4), (2, 7), (-5, 11), (4, 13), (-1, 16), (5, 3), (-4, 8))):
        y = top + dy
        if y < hem:
            c.put(CX + dx, y, 'O' if (i + {'idle': 0, 'stepA': 1, 'stepB': 2}[pose]) % 3 else 'o')


def lyra_front(c, pose):
    # high collar and mantle
    lyra_robe(c, 11, pose)
    c.mirror_rect(CX - 7, 11, CX - 4, 12, 'M')
    c.mirror_rect(CX - 6, 9, CX - 4, 10, 'G')   # tall collar
    c.mirror_rect(CX - 7, 13, CX - 6, 18, 'N')  # sleeves
    c.mirror_rect(CX - 7, 19, CX - 6, 19, 'G')
    c.put(CX - 7, 20, 'S'); c.put(CX + 6, 20, 'S')
    # staff at the viewer's right, star on top
    c.rect(CX + 8, 3, CX + 8, FEET, 'W'); c.rect(CX + 9, 4, CX + 9, FEET, 'w')
    c.rect(CX + 7, 0, CX + 10, 3, 'C'); c.put(CX + 8, 1, 'X'); c.put(CX + 9, 2, 'X')
    # face, hair and its glowing ends
    c.rect(CX - 4, 4, CX + 3, 12, 'A')
    c.rect(CX - 2, 4, CX + 1, 9, 'S'); c.rect(CX - 2, 9, CX + 1, 9, 's')
    c.put(CX - 2, 6, 'E'); c.put(CX + 1, 6, 'E')
    c.mirror_put(CX - 4, 12, 'Y'); c.mirror_put(CX - 4, 11, 'Y')
    # crown of floating crystals
    b = {'idle': 0, 'stepA': 1, 'stepB': 0}[pose]
    for x, y in ((CX - 4, 2), (CX - 1, 1), (CX + 2, 2)):
        c.rect(x, y - b, x + 1, y + 1 - b, 'C'); c.put(x, y - b, 'x')
    c.rect(CX - 3, 3, CX + 2, 3, 'G')
    # orbiting motes
    for x, y in ((CX - 10, 14 + b), (CX - 9, 22 - b), (CX + 10, 18 + b)):
        c.put(x, y, 'x')


def lyra_back(c, pose):
    lyra_robe(c, 11, pose, front=False)
    c.mirror_rect(CX - 7, 11, CX - 4, 12, 'M')
    c.mirror_rect(CX - 6, 9, CX - 4, 10, 'G')
    c.mirror_rect(CX - 7, 13, CX - 6, 18, 'N')
    c.rect(CX - 9, 3, CX - 9, FEET, 'W'); c.rect(CX - 10, 0, CX - 7, 3, 'C'); c.put(CX - 9, 1, 'X')
    # long hair down the back, glowing at the ends
    c.rect(CX - 4, 3, CX + 3, 17, 'A'); c.rect(CX - 1, 5, CX, 17, 'a')
    c.rect(CX - 3, 17, CX + 2, 18, 'Y')
    b = {'idle': 0, 'stepA': 1, 'stepB': 0}[pose]
    for x, y in ((CX - 4, 1), (CX - 1, 0), (CX + 2, 1)):
        c.rect(x, y - b + 1, x + 1, y + 2 - b, 'C')


def lyra_side(c, pose):
    lyra_robe(c, 11, pose, front=False)
    c.rect(CX - 3, 9, CX + 1, 12, 'M'); c.rect(CX - 3, 9, CX - 2, 11, 'G')
    # arm forward holding the staff out
    c.rect(CX, 13, CX + 3, 14, 'N'); c.put(CX + 4, 14, 'S')
    c.rect(CX + 5, 2, CX + 5, FEET, 'W'); c.rect(CX + 4, 0, CX + 7, 2, 'C'); c.put(CX + 5, 1, 'X')
    c.rect(CX - 3, 4, CX + 2, 11, 'A'); c.rect(CX, 4, CX + 2, 9, 'S'); c.put(CX + 1, 6, 'E')
    # hair streaming back, glowing tips
    t = {'idle': 0, 'stepA': 1, 'stepB': 2}[pose]
    for i in range(5):
        c.rect(CX - 4 - i, 6 + (i + t) // 2, CX - 4 - i, 9 + (i + t) // 2, 'A')
    c.put(CX - 8, 9 + (4 + t) // 2, 'Y'); c.put(CX - 8, 8 + (4 + t) // 2, 'Y')
    b = {'idle': 0, 'stepA': 1, 'stepB': 0}[pose]
    for x, y in ((CX - 3, 2), (CX, 1), (CX + 2, 2)):
        c.rect(x, y - b, x + 1, y + 1 - b, 'C')
    c.put(CX - 9, 16 + b, 'x'); c.put(CX + 8, 20 - b, 'x')


# ================================================================== SILAS
SILAS = {
    'A': (30, 26, 34), 'a': (18, 16, 22), 'Q': (52, 46, 60),           # cloak
    'B': (220, 212, 196), 'b': (160, 150, 136),                         # bone mask
    'E': (255, 40, 50),                                                 # eyes
    'R': (196, 30, 44), 'r': (120, 16, 26),                             # scarf
    'L': (220, 226, 236), 'l': (130, 136, 150),                         # blades
    'H': (60, 52, 66),                                                  # horns
    'P': (40, 36, 46), 'p': (26, 24, 30),                               # legs
    'g': (120, 110, 100),                                               # buckles
    'F': (255, 60, 70), 'f': (150, 20, 30),                             # red embers (wisps)
}


def silas_cloak(c, top, pose, front=True):
    sway = {'idle': 0, 'stepA': 1, 'stepB': -1}[pose]
    for y in range(top, FEET + 1):
        half = 5 + (y - top) // 3
        s = sway if y > top + 8 else 0
        c.rect(CX - half + s, y, CX + half - 1 + s, y, 'A')
        c.put(CX - half + s, y, 'r'); c.put(CX + half - 1 + s, y, 'r')
    # tattered hem
    half = 5 + (FEET - top) // 3
    for x in range(CX - half + sway, CX + half + sway, 2):
        c.put(x, FEET, '.')
    if front:
        c.rect(CX - 2, top, CX + 1, FEET - 6, 'Q')  # the cloak open at the front


def silas_horns(c):
    """Two heavy horns curling up and out of the hood."""
    for dx, dy in ((4, 3), (5, 2), (5, 3), (6, 1), (6, 2), (7, 0), (7, 1)):
        c.mirror_put(CX - dx, dy, 'H')
    c.mirror_put(CX - 8, 0, 'H')


def silas_front(c, pose):
    legs_front(c, pose, 21, 'P', 'p', 'p', 'P', width=3)
    silas_cloak(c, 11, pose)
    c.rect(CX - 2, 13, CX + 1, 20, 'P')
    c.rect(CX - 2, 16, CX + 1, 16, 'g'); c.rect(CX - 2, 19, CX + 1, 19, 'g')  # straps
    # arms low, the curved blades sweeping out to each side
    c.mirror_rect(CX - 6, 14, CX - 5, 18, 'Q')
    for k in range(6):
        c.mirror_put(CX - 7 - k, 19 + k // 2, 'L')
        c.mirror_put(CX - 7 - k, 20 + k // 2, 'l')
    c.mirror_put(CX - 12, 22, 'L'); c.mirror_put(CX - 12, 21, 'L')
    # scarf
    c.rect(CX - 3, 10, CX + 2, 12, 'R'); c.rect(CX - 3, 12, CX + 2, 12, 'r')
    sw = {'idle': 0, 'stepA': 1, 'stepB': 2}[pose]
    c.rect(CX + 2, 12, CX + 3, 16 + sw % 2, 'R')
    # hood with horns, bone mask, red eyes
    c.rect(CX - 4, 3, CX + 3, 10, 'A')
    c.rect(CX - 2, 5, CX + 1, 9, 'B'); c.rect(CX - 2, 9, CX + 1, 9, 'b')
    c.put(CX - 2, 6, 'E'); c.put(CX + 1, 6, 'E')
    c.put(CX - 1, 8, 'a'); c.put(CX, 8, 'a')
    silas_horns(c)
    c.put(CX - 1, 14, 'R'); c.put(CX, 14, 'R'); c.put(CX - 1, 15, 'r'); c.put(CX, 13, 'r')
    if pose != 'idle':
        c.put(CX - 11 if pose == 'stepA' else CX + 10, 12, 'F')


def silas_back(c, pose):
    legs_front(c, pose, 21, 'p', 'P', 'p', 'P', width=3)
    silas_cloak(c, 11, pose, front=False)
    # blades crossed on the back
    for k in range(10):
        c.put(CX - 5 + k, 12 + k, 'l')
        c.put(CX + 4 - k, 12 + k, 'l')
    c.rect(CX - 3, 10, CX + 2, 11, 'R')
    sw = {'idle': 0, 'stepA': 1, 'stepB': -1}[pose]
    for y in range(11, 20):
        c.put(CX + (y - 11) * sw // 3, y, 'R')
        c.put(CX + 1 + (y - 11) * sw // 3, y, 'r')
    c.rect(CX - 4, 3, CX + 3, 10, 'A'); c.rect(CX - 1, 3, CX, 10, 'a')
    silas_horns(c)


def silas_side(c, pose):
    legs_side(c, pose, 21, 'P', 'p', 'p', 'P')
    # cloak streaming back
    sway = {'idle': 0, 'stepA': 1, 'stepB': 0}[pose]
    for y in range(11, FEET + 1):
        back = 2 + (y - 11) // 3 + sway
        c.rect(CX - 2 - back, y, CX + 1, y, 'A')
        c.put(CX - 2 - back, y, 'a')
    for x in range(CX - 10, CX + 2, 2):
        c.put(x, FEET, '.')
    c.rect(CX - 1, 13, CX + 2, 20, 'P')
    # blade held forward, low and curved
    c.rect(CX, 15, CX + 3, 16, 'Q')
    for k in range(7):
        c.put(CX + 4 + k, 16 - k // 2, 'L')
        c.put(CX + 4 + k, 17 - k // 2, 'l')
    c.put(CX + 11, 12, 'L')
    # scarf streaming behind
    sw = {'idle': 0, 'stepA': 1, 'stepB': 2}[pose]
    c.rect(CX - 2, 10, CX + 2, 12, 'R')
    for i in range(7):
        c.put(CX - 3 - i, 10 + (i + sw) // 3, 'R')
        c.put(CX - 3 - i, 11 + (i + sw) // 3, 'r')
    # hood, horn, mask in profile
    c.rect(CX - 3, 3, CX + 2, 10, 'A')
    c.rect(CX, 5, CX + 2, 9, 'B'); c.put(CX + 1, 6, 'E')
    for x, y in ((CX - 3, 2), (CX - 4, 2), (CX - 4, 1), (CX - 5, 1), (CX - 5, 0), (CX - 6, 0)):
        c.put(x, y, 'H')
    if pose == 'stepA':
        c.put(CX + 12, 15, 'F')


HEROES = {
    'vael': (VAEL, vael_front, vael_back, vael_side),
    'ryn': (RYN, ryn_front, ryn_back, ryn_side),
    'lyra': (LYRA, lyra_front, lyra_back, lyra_side),
    'silas': (SILAS, silas_front, silas_back, silas_side),
}
POSES = ['idle', 'stepA', 'stepB']


def render(pal, draw, pose):
    c = Canvas()
    draw(c, pose)
    c.outline()
    im = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    full = dict(pal, K=OUTLINE)
    for y in range(H):
        for x in range(W):
            ch = c.g[y][x]
            if ch != '.' and full.get(ch):
                im.putpixel((x, y), full[ch] + (255,))
    return im


def sheet(name):
    pal, front, back, side = HEROES[name]
    out = Image.new('RGBA', (W * 3, H * 3), (0, 0, 0, 0))
    for r, draw in enumerate((front, back, side)):
        for col, pose in enumerate(POSES):
            out.paste(render(pal, draw, pose), (col * W, r * H))
    return out


if __name__ == '__main__':
    out_dir = sys.argv[1]
    sheets = {n: sheet(n) for n in HEROES}
    for n, s in sheets.items():
        s.save(os.path.join(out_dir, '%s_ascended_walk.png' % n))
    if len(sys.argv) > 2:
        prev = Image.new('RGBA', (sum(s.width for s in sheets.values()) + 50, H * 3 + 8), (52, 46, 64, 255))
        x = 10
        for s in sheets.values():
            prev.alpha_composite(s, (x, 4))
            x += s.width + 10
        prev.resize((prev.width * 5, prev.height * 5), Image.NEAREST).save(sys.argv[2])
