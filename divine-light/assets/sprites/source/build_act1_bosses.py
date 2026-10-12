"""Hand-placed battle sprites for Act I's four dungeon bosses (Milestone 21).

Same output as build_enemies.py: a 2-frame idle sheet per boss, frames side
by side, 48x48 each like the Hollow Warden, facing right (toward the party):
assets/sprites/enemies/<slug>.png. Frame 2 breathes (everything above a row
sinks 1px) and pulses the glow colors.

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
WISPS = {'w', 'x'}


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


def render(b, glow_frame):
    grid = b['rows']
    if glow_frame:
        grid = [''.join(b['glow'].get(ch, ch) for ch in row) for row in grid]
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
