"""Hand-placed battle sprites for the 8 current enemies.

Each enemy faces right (toward the party) and gets a 2-frame idle sheet, frames
side by side: assets/sprites/enemies/<slug>.png. Standard enemies are 24x32 (three
fit across the 78px enemy area), the boss is 48x48. Rows shorter than the frame
are padded right, and grids shorter than the frame are padded at the top, so
every sprite stands on the bottom edge.

Frame 2 is derived from frame 1 by the enemy's IDLE rule:
  ('breathe', row) - everything above `row` sinks 1px (a breathing squash)
  ('float',)       - the whole sprite rises 1px
plus GLOW swaps (char -> char) so eyes/cracks pulse between frames.

Usage: python build_enemies.py <out_dir> [preview.png]
"""
import os
import sys

from PIL import Image

BASE = {
    '.': None,
    'K': (26, 20, 32),      # outline
    'W': (236, 232, 220),   # bone / highlight
    'V': (170, 80, 220),    # corruption glow
    'v': (96, 40, 140),     # corruption glow dark
    'X': (220, 150, 255),   # corruption glow bright (frame-2 pulse)
    'E': (200, 255, 120),   # sick eye glow
    'e': (130, 190, 60),    # sick eye glow dim
    'R': (255, 70, 60),     # red eye glow
    'r': (170, 30, 40),     # red eye glow dim
}

ENEMIES = {}


def enemy(slug, size, idle, glow, pal, grid):
    ENEMIES[slug] = dict(size=size, idle=idle, glow=glow, pal=dict(BASE, **pal), grid=grid)


# --------------------------------------------------------------- Blighted Wolf
enemy('blighted_wolf', (24, 32), ('breathe', 7), {'E': 'e', 'V': 'X'}, {
    'F': (118, 112, 100), 'f': (76, 72, 70), 'l': (164, 156, 138),
}, [
    ".................K..K...",
    "................KlKKlK..",
    "...............KllllllK.",
    "..............KlllllEllK",
    "KK...........KFllllllllK",
    "KfKK.....KKKFFFfllllKWK.",
    ".KffKKKKFFFFFFFFFfllKK..",
    "..KffFFFFVFFFFFFFfflK...",
    "...KfFFFFFVVFFFFFFffK...",
    "....KfFFFFFFFVFFFFffK...",
    "....KffFfffffffFFffK....",
    "....KffK.KfK....KffKfK..",
    "....KfK..KfK....KfK.KfK.",
    "...KfK...KfK....KfK.KfK.",
    "..KffK..KffK...KffK.KffK",
    "..KKKK..KKKK...KKKK.KKKK",
])

# --------------------------------------------------------------- Hollow Archer
enemy('hollow_archer', (24, 32), ('breathe', 13), {'E': 'e'}, {
    'C': (84, 78, 66), 'c': (40, 36, 36), 'h': (116, 108, 90),
    'P': (150, 148, 132), 'N': (110, 74, 44), 'n': (70, 46, 28), 's': (200, 196, 176),
}, [
    ".........KKKK.......K...",
    "........KhCCCK.....KnK..",
    ".......KhCCCCCK....KsnK.",
    ".......KhCKKKKK....Ks.nK",
    ".......KhKcEcEK....Ks.nK",
    ".......KhKccccK....Ks.nK",
    ".......KhCKKKKK....Ks.nK",
    "......KhCCCCCCCK...Ks.nK",
    ".....KhCCCCCCCCCK..Ks.nK",
    ".....KhCCCCCCKKKKKKKKKnK",
    ".....KhCCCCCKPPPPPPPKNnK",
    ".....KhCCCCCCKKKKKKKKKnK",
    ".....KhCCCCCCCK....Ks.nK",
    ".....KhCCCCCCCK....Ks.nK",
    ".....KhCCCVCCCK....Ks.nK",
    "....KhCCCCCCCCCK...Ks.nK",
    "....KhCCCCCCVCCK...Ks.nK",
    "....KhCCCCCCCCCK...KsnK.",
    "...KhCCCCCCCCCCCK...KnK.",
    "...KhCCCCCCCCCCCK....K..",
    "...KhCKCCKCCKCCCK.......",
    "...KK.KCK.KCKKKK........",
    "......KcK..KcK..........",
    "......KcK..KcK..........",
    ".....KccK.KccK..........",
    ".....KKKK.KKKK..........",
])

# ------------------------------------------------------------------ Shade Wisp
# Translucent: the outer glow layers carry alpha.
enemy('shade_wisp', (24, 32), ('float',), {'E': 'e', 'Z': 'z'}, {
    'o': (96, 40, 140, 110), 'O': (150, 70, 200, 170),
    'Z': (150, 210, 110), 'z': (110, 170, 80), 'Y': (230, 255, 200),
}, [
    "............o...........",
    "...........oO...........",
    "..........oOOo..........",
    ".........oOZZOo.........",
    "........oOZZZZOo........",
    ".......oOZYYYYZOo.......",
    "......oOZYYYYYYZOo......",
    "......oOZKYYYYKZOo......",
    "......oOZYKYYKYZOo......",
    "......oOZYKYKYKZOo......",
    "......oOZZYYYYZZOo......",
    ".......oOZZZZZZOo.......",
    "........oOZZZZOOo.......",
    ".........oOZZOOo........",
    "........oOOZOOo.........",
    ".......oOOZOOo..........",
    "......oOOOOo............",
    ".....oOOo...............",
    "....oOo.................",
    "....o...................",
    "........................",
    "........................",
    "........................",
])

# ------------------------------------------------------------ Corrupted Farmer
enemy('corrupted_farmer', (24, 32), ('breathe', 14), {'R': 'r', 'V': 'X'}, {
    'H': (196, 164, 88), 'h': (140, 112, 56),          # straw hat
    'S': (150, 150, 128), 's': (104, 106, 92),         # sallow skin
    'B': (82, 96, 120), 'b': (52, 62, 84),             # torn overalls
    'T': (150, 120, 88), 't': (104, 80, 58),           # shirt
    'N': (110, 74, 44), 'n': (70, 46, 28), 'I': (150, 156, 170),  # pitchfork
}, [
    "..................K.K.K.",
    "..................KIKIKI",
    "..................KIKIKI",
    ".......KKKKK......KIKIKI",
    "......KHHHHHK.....KKKNKK",
    "....KKHHHHHHHKK.....KnK.",
    "...KhhhhhhhhhhhK....KnK.",
    "......KSSSRSSK......KnK.",
    "......KsSSSSVK......KnK.",
    "......KsSSSSSK......KnK.",
    "....KKKTsSSSKTKK....KnK.",
    "...KTTTTKKKKTTTTK...KnK.",
    "..KTTBBTTTTTTBBTTK.KSnK.",
    "..KTTBBBBBBBBBBTTKKSSnK.",
    ".KTTKBBBBVBBBBBKTTSSKnK.",
    ".KTTKBBBBBVBBBBKKKKKKnK.",
    ".KSSKBBBBBBBBBBK....KnK.",
    ".KSsKBBBBBBBBBbK....KnK.",
    "..KKKbBBBBBBBBbK....KnK.",
    "....KbBBBBKBBBbK....KnK.",
    "....KbBBBK.KBBbK....KnK.",
    "....KbBBK..KBBbK....KnK.",
    "....KbBBK..KbBBK....KnK.",
    "....KbbbK..KbbbK....KnK.",
    "...KnnnnK..KnnnnK...KnK.",
    "...KKKKKK..KKKKKK...KKK.",
])

# --------------------------------------------------------------- Fallen Priest
enemy('fallen_priest', (24, 32), ('breathe', 12), {'E': 'e', 'G': 'g'}, {
    'S': (206, 204, 184), 's': (160, 158, 140),        # sickly pale skin
    'M': (70, 36, 48), 'm': (44, 22, 32), 'u': (100, 54, 66),  # tattered robe
    'G': (176, 150, 70), 'g': (120, 100, 40),          # tarnished gold
}, [
    ".........KKKKK..........",
    "........KSSSSSK.........",
    ".......KSSSSSSSK........",
    ".......KSSSSEKSK........",
    ".......KsSSSSSSK........",
    ".......KsSSSKSSK........",
    "........KsSSSSK.........",
    "......KKmKsssKKK........",
    ".....KumMKKKKMMuK.......",
    "....KuMMMMGMMMMMuK......",
    "....KuMMMMGMMMMMMuK.....",
    "...KuMMMMGGGMMMKSSK.....",
    "...KuMMMMMGMMMMKsSK.....",
    "...KuMMMMMMMMMMMKK......",
    "...KuMMMMMMMMMMMuK......",
    "...KuMMMMMMmMMMMuK......",
    "..KuMMMMMMMmMMMMMuK.....",
    "..KuMMMMMMMmMMMMMuK.....",
    "..KuMMMMMMMmMMMMMMuK....",
    "..KuMMMMMMmMMMMMMMuK....",
    ".KuMMMMMMMmMMMMMMMMuK...",
    ".KuMMMMMMmMMMMMMMMMuK...",
    ".KmMMMKMMmMMKMMMKMMmK...",
    ".KKmKK.KmKKmK.KmK.KKK...",
    "...K....K..K...K........",
])

# -------------------------------------------------------------- Cursed Paladin
enemy('cursed_paladin', (24, 32), ('breathe', 13), {'R': 'r', 'V': 'X'}, {
    'D': (52, 54, 70), 'S': (86, 90, 110), 'L': (124, 128, 148),  # blackened steel
    'M': (60, 24, 36), 'm': (36, 14, 24),              # dark shield / tabard
}, [
    "......KKKKKKKK..........",
    ".....KLLLLLSSDK.........",
    "....KDSSSSSSSSDK........",
    "....KSLLSSSSSSDK........",
    "....KSLLSSVSSSDK........",
    "....KSLLSKRRRRRK........",
    "....KSLLSSSSSSDK........",
    "....KSLLSSSSKSDK........",
    "....KDSSSSSSSSDK........",
    "...KKKKKKKKKKKKKK.......",
    "..KLLSSKMMMMKSSDDK......",
    ".KLLSSDKMmMMKLSDDKKKKKK.",
    ".KLSSDDKMMMMKSSDKMMMMMMK",
    ".KSSKKKKMMMMKDDKMmVVVMMK",
    ".KSSKMMMMMMMKSDKMmMVMMMK",
    ".KSSKMMMMVMMKSDKMmMVMMMK",
    ".KDDKMMMMMMMKDDKMmMMMMMK",
    ".KSLKmmmmmmmKKKKKMmMMMMK",
    "KWLSKMMMMMMMMK..KMmMMMK.",
    "KWLKKMMMMVMMMK...KMmMK..",
    "KWLK.KMMMMMMK.....KMK...",
    "KWLK.KSSKKSSK......K....",
    "KWLK.KSSK.KSSK..........",
    "KWLK.KSSK.KSSK..........",
    ".KK..KDDK.KDDK..........",
    "....KDDDK.KDDDK.........",
    "....KKKKK.KKKKK.........",
])

# -------------------------------------------------------------- Shadow Acolyte
enemy('shadow_acolyte', (24, 32), ('breathe', 12), {'E': 'e', 'V': 'X'}, {
    'A': (62, 44, 86), 'a': (38, 26, 56), 'h': (92, 70, 124),  # ceremonial robes
    'S': (160, 150, 170),                              # grey hands
}, [
    "................KVK.....",
    "...............KVXVK....",
    "..........KKK...KVK.....",
    ".........KhAAK..........",
    "........KhAAAAK.........",
    "........KhAKKKK...K.K...",
    "........KhKaEaK..KSKSK..",
    "........KhKaaaK..KSSSK..",
    "........KhAKKKK..KSSK...",
    ".......KhAAAAAAK.KShK...",
    "......KhAAAAAAAAKhhK....",
    "......KhAAAAAAAAKhK.....",
    "......KhAAAVAAAAKK......",
    "......KhAAAVAAAAK.......",
    ".....KhAAAAVAAAAK.......",
    ".....KhAAAAAAAAAK.......",
    ".....KhAAAAVAAAAAK......",
    "....KhAAAAAVAAAAAK......",
    "....KhAAAAAVAAAAAAK.....",
    "....KhAAAAAAAAAAAAK.....",
    "...KhAAAAAAVAAAAAAAK....",
    "...KhAAAAAAAAAAAAAAK....",
    "...KaAAKAAAaAAKAAAaK....",
    "...KKaKKKaKKaKKKaKKK....",
    ".....K...K..K...K.......",
])

# ------------------------------------------------------ Hollow Warden (boss)
# A stone-and-iron jailer construct with a hollow, glowing chest cavity.
enemy('hollow_warden', (48, 48), ('breathe', 22), {'R': 'r', 'V': 'X'}, {
    'G': (112, 110, 104), 'g': (78, 76, 74), 'l': (150, 146, 136),  # stone
    'I': (70, 72, 86), 'i': (46, 48, 60),              # iron bands
    'C': (130, 110, 70), 'c': (90, 74, 44),            # rusted chain / keys
}, [
    "................KKKKKKKKKKKK....................",
    "..............KKllllGGGGGGggKK..................",
    ".............KllllGGGGGGGGGggggK................",
    "............KlllGGGGGGGGGGGGgggK................",
    "............KllGGGIIIIIIIIIIggggK...............",
    "............KlGGIKKKKKKKKKKKIgggK...............",
    "............KlGGIKRRRKKKRRRKIgggK...............",
    "............KlGGIKKKRRKRRKKKIgggK...............",
    "............KlGGGIIIIIIIIIIIggggK...............",
    "............KlGGGGGGVGGGGGGGGgggK...............",
    "..........K..KlGGGGGGVGGGGGGGggK..K.............",
    ".........KlK..KKlGGGGGVGGGGGgKK..KgK............",
    "..........KKKKKKKKKKKKKKKKKKKKKKKKK.............",
    "........KKllllGGGIIIIIIIIIIIGGGGgggKK...........",
    ".......KlllGGGGGIKKKKKKKKKKIGGGGGgggK...........",
    "......KllGGGGGGIKvvvvvvvvvKIGGGGGGggK...........",
    "......KlGGGGGGGIKvVVVVVVVvKIGGGGGGggK...........",
    ".....KlGGGGKKGGIKvVXXXXXVvKIGGKKGGGgK...........",
    ".....KlGGGK..KGIKvVXXXXXVvKIGK..KGGgK...........",
    ".....KlGGGK..KGIKvVVVVVVVvKIGK..KGGgK...........",
    ".....KlGGGK..KGIKvvvvvvvvvKIGK..KGGgK...........",
    ".....KlGGGK..KGGIKKKKKKKKKIGGK..KGGgK...........",
    ".....KlGGGK..KGGGIIIIIIIIIGGGK..KGGgK...........",
    ".....KlGGGK..KGGGGGGGVGGGGGGGK..KGGgK...........",
    ".....KlGGGK..KGGGGGGGGVGGGGGGK..KGGgK...........",
    ".....KIIIIK..KGGGGGGGGGVGGGGGK..KIIIIK..........",
    "....KlGGGGGK.KGGGGGGGGGGGGGGGK.KlGGGGgK.........",
    "...KlGGGGGGgKKIIIIIIIIIIIIIIIKKlGGGGGggK........",
    "...KlGGGGGGgK.KGGGGGGKGGGGGGK.KlGGGGGggK..KK....",
    "...KlGGKKGGgK.KGGGGGGKGGGGGGK.KlGGKKGggKKKCK....",
    "....KKK..KKK..KGGGGGGKGGGGGGK..KKKCCKKKKCKK.....",
    ".............KlGGGGGKKKGGGGGgK.....KCKKCKK......",
    ".............KlGGGGGK.KGGGGGgK......KCCKK.......",
    ".............KlGGGGGK.KGGGGGgK.....KCKCK........",
    ".............KIIIIIIK.KIIIIIIK.....KCCCK........",
    "............KlGGGGGGK.KGGGGGggK.....KKK.........",
    "............KlGGGGGGK.KGGGGGggK.................",
    "...........KlGGGGGGGK.KGGGGGGggK................",
    "...........KKKKKKKKKK.KKKKKKKKKK................",
])


def render(e, glow_frame):
    w, h = e['size']
    grid = [row.ljust(w, '.') for row in e['grid']]
    assert len(grid) <= h, (len(grid), h)
    grid = ['.' * w] * (h - len(grid)) + grid
    for y, row in enumerate(grid):
        assert len(row) == w, (y, len(row), row)
    if glow_frame:
        grid = [''.join(e['glow'].get(ch, ch) for ch in row) for row in grid]
        kind = e['idle'][0]
        if kind == 'breathe':
            split = h - len(e['grid']) + e['idle'][1]
            upper = grid[:split]
            new = ['.' * w] + upper[:-1]
            # the sinking upper body's last row lands on the first lower row;
            # keep lower pixels wherever the upper row is empty
            merged = ''.join(u if u != '.' else l for u, l in zip(upper[-1], grid[split]))
            grid = new + [merged] + grid[split + 1:]
        elif kind == 'float':
            grid = grid[1:] + ['.' * w]
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    for y, row in enumerate(grid):
        for x, ch in enumerate(row):
            c = e['pal'][ch]
            if c:
                im.putpixel((x, y), c if len(c) == 4 else c + (255,))
    return im


def sheet(e):
    w, h = e['size']
    out = Image.new('RGBA', (w * 2, h), (0, 0, 0, 0))
    out.paste(render(e, False), (0, 0))
    out.paste(render(e, True), (w, 0))
    return out


if __name__ == '__main__':
    out_dir = sys.argv[1]
    os.makedirs(out_dir, exist_ok=True)
    sheets = {}
    for slug, e in ENEMIES.items():
        try:
            sheets[slug] = sheet(e)
        except AssertionError as err:
            raise SystemExit(f'{slug}: {err}')
        sheets[slug].save(os.path.join(out_dir, slug + '.png'))
    if len(sys.argv) > 2:
        # preview: every sheet side by side at 6x on a dark ground
        pw = sum(s.width for s in sheets.values()) + 4 * (len(sheets) + 1)
        prev = Image.new('RGBA', (pw, 52), (60, 52, 70, 255))
        x = 4
        for s in sheets.values():
            prev.alpha_composite(s, (x, 52 - s.height - 2))
            x += s.width + 4
        prev.resize((prev.width * 5, prev.height * 5), Image.NEAREST).save(sys.argv[2])
