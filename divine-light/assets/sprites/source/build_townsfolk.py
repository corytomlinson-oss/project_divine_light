"""Walk sheets for Act I's townsfolk (Milestone 21), hand-placed.

Same sheet layout as the heroes (pixelgrid.py: 16x32 frames, rows down / up /
right, columns idle / stepA / stepB, left = right flipped in Godot), plus a
<name>_frames.tres per sheet with the same animation names.

People here are built from shared parts - a head, a body, the three walk
poses - then each design adds its own details (hat, robe, apron, spear...).
The outline is added automatically around each frame. Several designs come
in two colorings so the same role in Verdance and Edenmere (or two roles that
share a build) still look like different people:

  elder / mayor, worker (farmer) / smith, merchant (innkeeper) / innkeeper_b /
  shopkeeper, child / child_b, guard / guard_b, priestess, traveler

Usage: python build_townsfolk.py <sprites_dir> [preview.png]
"""
import os
import sys

from PIL import Image

from build_act1_bosses import Canvas

FW, FH = 16, 32
VIEWS = ['down', 'up', 'right']
POSES = ['idle', 'stepA', 'stepB']

BASE = {
    '.': None,
    'K': (26, 20, 32),
    'F': (236, 188, 148), 'f': (196, 140, 104),   # skin
    'o': (66, 46, 34),                            # shoes
}


# ------------------------------------------------------------------ parts

def head(c, view, y, hair='h', style='short'):
    """A 6-wide head, rows y..y+5. style: short, bald, long, beard."""
    if view == 'right':
        for r in range(6):
            c.span(y + r, 6, 10, 'F')
        c.put(11, y + 3, 'F')                       # nose
        c.put(9, y + 2, 'K')                        # eye
        c.span(y + 5, 7, 10, 'f')
        if style != 'bald':
            c.span(y - 1, 6, 10, hair)
            c.span(y, 5, 8, hair)
            c.put(5, y + 1, hair * 2)
            c.put(5, y + 2, hair)
        else:
            c.put(5, y + 2, 'F')                    # ear
            c.put(6, y, 'f')
        if style == 'long':
            for r in range(1, 7):
                c.put(5, y + r, hair * 2)
        if style == 'beard':
            c.put(8, y + 4, hair * 3)
            c.put(7, y + 5, hair * 4)
            c.put(8, y + 6, hair * 2)
        return
    for r in range(6):
        c.span(y + r, 5, 10, 'F')
    c.span(y + 5, 6, 9, 'f')
    if view == 'down':
        c.put(6, y + 2, 'K')
        c.put(9, y + 2, 'K')
        if style != 'bald':
            c.span(y - 1, 5, 10, hair)
            c.span(y, 5, 10, hair)
            c.put(5, y + 1, hair)
            c.put(10, y + 1, hair)
        else:
            c.put(4, y + 2, 'F')
            c.put(11, y + 2, 'F')
        if style == 'long':
            for r in range(1, 7):
                c.put(4, y + r, hair)
                c.put(11, y + r, hair)
        if style == 'beard':
            c.span(y + 4, 6, 9, hair)
            c.span(y + 5, 6, 9, hair)
            c.span(y + 6, 7, 8, hair)
    else:  # up: the back of the head
        if style == 'bald':
            c.span(y + 1, 5, 10, 'f')
        else:
            for r in range(-1, 5):
                c.span(y + r, 5, 10, hair)
        if style == 'long':
            for r in range(5, 8):
                c.span(y + r, 5, 10, hair)


def body(c, view, y0, y1, cloth, shade, arms=True, hands=True):
    """Torso rows y0..y1; arms down the sides (front/back) or one at the side."""
    if view == 'right':
        for y in range(y0, y1 + 1):
            c.span(y, 5, 10, cloth)
            c.put(5, y, shade)
        if arms:
            for y in range(y0 + 1, y1):
                c.put(7, y, shade + cloth)
            if hands:
                c.put(7, y1, 'Ff')
        return
    for y in range(y0, y1 + 1):
        c.span(y, 4, 11, cloth)
        c.put(4, y, shade)
    if arms:
        for y in range(y0 + 1, y1):
            c.put(3, y, cloth)
            c.put(12, y, shade)
        if hands:
            c.put(3, y1, 'F')
            c.put(12, y1, 'f')


def legs(c, view, pose, y0=25, low='U', shade='u', short=False):
    """Trousered legs from y0 down to the shoes on row 29."""
    bottom = 28
    if view == 'right':
        if pose == 'idle':
            for y in range(y0, bottom + 1):
                c.span(y, 6, 9, low)
                c.put(6, y, shade)
            c.span(29, 6, 10, 'o')
        else:
            back, front = (shade, low) if pose == 'stepA' else (low, shade)
            for k, y in enumerate(range(y0, bottom + 1)):
                c.span(y, 6 - k // 2, 7 - k // 2, back)
                c.span(y, 8 + k // 2, 9 + k // 2, front)
            n = (bottom - y0) // 2
            c.span(29, 4 - n, 7 - n, 'o')
            c.span(29, 8 + n, 11 + n, 'o')
        return
    lift_l = 1 if pose == 'stepA' else 0
    lift_r = 1 if pose == 'stepB' else 0
    for y in range(y0, bottom + 1 - lift_l):
        c.span(y, 5, 7, low)
    for y in range(y0, bottom + 1 - lift_r):
        c.span(y, 8, 10, shade if view == 'up' else low)
    c.put(8, y0, shade)
    c.span(29 - lift_l, 4, 7, 'o')
    c.span(29 - lift_r, 8, 11, 'o')


def robe_feet(c, view, pose):
    """Feet peeking out under a floor-length robe (rows 28-29)."""
    if view == 'right':
        if pose == 'idle':
            c.span(29, 6, 10, 'o')
        else:
            c.span(29, 4, 6, 'o')
            c.span(29, 9, 11, 'o')
        return
    if pose != 'stepB':
        c.span(29, 5, 7, 'o')
    if pose != 'stepA':
        c.span(29, 8, 10, 'o')


def robe(c, view, y0, cloth, shade, trim=None):
    """A long robe from y0 to row 28, flaring a little."""
    for y in range(y0, 29):
        flare = (y - y0) // 6
        if view == 'right':
            c.span(y, 5 - flare, 10 + flare, cloth)
            c.put(5 - flare, y, shade)
        else:
            c.span(y, 4 - flare, 11 + flare, cloth)
            c.put(4 - flare, y, shade)
    if trim:
        if view == 'right':
            c.span(28, 4, 11, trim)
        else:
            c.span(28, 3, 12, trim)


# ---------------------------------------------------------------- designs
# Each design: draw(c, view, pose). Palettes may be swapped per variant.

def elder(c, view, pose):
    robe(c, view, 12, 'R', 'r', 'r')
    robe_feet(c, view, pose)
    body(c, view, 12, 20, 'R', 'r')
    if view != 'up':                         # chain of office (mayor) / cord (elder)
        x0, x1 = (6, 9) if view == 'down' else (7, 9)
        c.span(13, x0, x1, 'C')
        c.put(x0 + 1, 14, 'C')
    head(c, view, 5, 'h', 'beard')
    if view == 'down':                       # walking stick
        for y in range(10, 30):
            c.put(13, y, 'n')
        c.put(12, 18, 'F')
    elif view == 'right':
        for y in range(10, 30):
            c.put(12, y, 'n')
        c.put(10, 18, 'FF')


def worker(c, view, pose):
    legs(c, view, pose, 24)
    body(c, view, 13, 23, 'S', 's')
    # apron (smith) / overalls (farmer)
    if view == 'down':
        for y in range(14, 25):
            c.span(y, 5, 10, 'A')
        c.put(5, 13, 'A')
        c.put(10, 13, 'A')
        c.put(5, 12, 'A')
        c.put(10, 12, 'A')
    elif view == 'right':
        for y in range(14, 25):
            c.span(y, 8, 10, 'A')
        c.put(8, 13, 'A')
    else:
        c.put(5, 13, 'A')
        c.put(10, 13, 'A')
        for k in range(4):
            c.put(5 + k, 14 + k, 'A')
            c.put(10 - k, 14 + k, 'A')
        c.span(23, 4, 11, 'A')
    head(c, view, 6, 'h', 'short')
    # cap
    if view == 'right':
        c.span(4, 6, 10, 'P')
        c.span(5, 5, 12, 'P')
        c.put(5, 5, 'p')
    else:
        c.span(4, 5, 10, 'P')
        c.span(5, 4, 11, 'P')
        c.put(4, 5, 'p')


def merchant(c, view, pose):
    legs(c, view, pose, 25)
    for y in range(12, 25):                  # stout body
        if view == 'right':
            c.span(y, 4, 11, 'S')
            c.put(4, y, 's')
        else:
            c.span(y, 3, 12, 'S')
            c.put(3, y, 's')
    if view == 'down':
        for y in range(15, 25):
            c.span(y, 5, 10, 'A')            # apron
        c.span(14, 6, 9, 'A')
        c.put(2, 22, 'F')
        c.put(13, 22, 'f')
        for y in range(14, 22):
            c.put(2, y, 'S')
            c.put(13, y, 's')
    elif view == 'right':
        for y in range(15, 25):
            c.span(y, 10, 11, 'A')
        c.put(7, 21, 'Ff')
    else:
        c.span(15, 3, 12, 'A')               # apron strings
        c.put(7, 16, 'AA')
        for y in range(14, 22):
            c.put(2, y, 'S')
            c.put(13, y, 's')
    c.span(24, 3 if view != 'right' else 4, 12 if view != 'right' else 11, 's')
    head(c, view, 5, 'h', 'bald')
    if view == 'down':
        c.put(4, 6, 'hh')                    # side hair
        c.put(10, 6, 'hh')
        c.put(4, 7, 'h')
        c.put(11, 7, 'h')
        c.span(9, 6, 9, 'h')                 # mustache
    elif view == 'right':
        c.put(5, 5, 'hhh')
        c.put(5, 6, 'hh')
        c.put(9, 9, 'hh')
    else:
        c.span(6, 5, 10, 'h')
        c.span(7, 5, 10, 'h')


def child(c, view, pose):
    legs(c, view, pose, 26)
    body(c, view, 18, 25, 'S', 's')
    c.span(25, 4 if view != 'right' else 5, 11 if view != 'right' else 10, 's')
    head(c, view, 11, 'h', 'short')
    if view == 'down':                       # pigtails
        c.put(3, 12, 'h')
        c.put(3, 13, 'hP')
        c.put(12, 12, 'h')
        c.put(11, 13, 'Ph')
    elif view == 'right':
        c.put(4, 12, 'h')
        c.put(4, 13, 'hP')
    else:
        c.put(3, 12, 'h')
        c.put(12, 12, 'h')
        c.put(3, 13, 'h')
        c.put(12, 13, 'h')


def guard(c, view, pose):
    legs(c, view, pose, 25, 'U', 'u')
    body(c, view, 12, 24, 'M', 'm')          # mail
    if view == 'down':                       # tabard
        for y in range(13, 25):
            c.span(y, 6, 9, 'T')
        c.put(7, 16, 'BB')                   # town badge
        c.put(7, 17, 'BB')
    elif view == 'right':
        for y in range(13, 25):
            c.span(y, 8, 10, 'T')
    else:
        for y in range(13, 25):
            c.span(y, 6, 9, 't')
    c.span(23, 4 if view != 'right' else 5, 11 if view != 'right' else 10, 'n')
    head(c, view, 5, 'h', 'short')
    # kettle helmet
    if view == 'right':
        c.span(3, 6, 10, 'L')
        c.span(4, 5, 11, 'L')
        c.span(5, 4, 12, 'l')
    else:
        c.span(3, 5, 10, 'L')
        c.span(4, 4, 11, 'L')
        c.span(5, 3, 12, 'l')
        if view == 'up':
            c.span(6, 5, 10, 'h')
    # spear
    x = 13 if view == 'down' else (2 if view == 'up' else 12)
    for y in range(3, 30):
        c.put(x, y, 'n')
    c.put(x, 0, 'L')
    c.put(x, 1, 'L')
    c.put(x, 2, 'l')
    if view == 'right':
        c.put(10, 18, 'FF')
    else:
        c.put(x if view == 'down' else x + 1, 18, 'F')


def priestess(c, view, pose):
    robe(c, view, 12, 'W', 'w', 'G')
    robe_feet(c, view, pose)
    body(c, view, 12, 21, 'W', 'w')
    if view == 'down':
        c.span(19, 4, 11, 'G')               # sash
        c.put(7, 14, 'GG')                   # sun pendant
        c.put(7, 15, 'GG')
    elif view == 'right':
        c.span(19, 5, 10, 'G')
        c.put(9, 14, 'G')
    else:
        c.span(19, 4, 11, 'G')
    head(c, view, 5, 'h', 'long')
    # veil
    if view == 'right':
        c.span(3, 6, 10, 'W')
        c.span(4, 5, 10, 'W')
        for y in range(5, 13):
            c.put(4, y, 'Ww')
        c.span(4, 6, 10, 'G')
    elif view == 'down':
        c.span(3, 5, 10, 'W')
        c.span(4, 4, 11, 'G')
        for y in range(5, 13):
            c.put(3, y, 'W')
            c.put(12, y, 'w')
    else:
        for y in range(3, 13):
            c.span(y, 4, 11, 'W')
        c.span(4, 4, 11, 'G')
        c.span(12, 4, 11, 'w')


def traveler(c, view, pose):
    legs(c, view, pose, 24)
    for y in range(10, 25):                  # hooded cloak
        if view == 'right':
            c.span(y, 4, 10, 'H')
            c.put(4, y, 'j')
        else:
            c.span(y, 3, 12, 'H')
            c.put(3, y, 'j')
    if view == 'down':
        for y in range(12, 25):
            c.span(y, 6, 9, 'S')             # tunic showing
        c.span(18, 6, 9, 'n')
    elif view == 'right':
        for y in range(12, 25):
            c.span(y, 9, 10, 'S')
    head(c, view, 5, 'h', 'short')
    if view == 'right':
        c.span(3, 5, 10, 'H')
        c.span(4, 4, 10, 'H')
        for y in range(5, 10):
            c.put(4, y, 'HH')
    elif view == 'down':
        c.span(3, 5, 10, 'H')
        c.span(4, 4, 11, 'H')
        for y in range(5, 10):
            c.put(4, y, 'H')
            c.put(11, y, 'j')
    else:
        for y in range(3, 11):
            c.span(y, 4, 11, 'H')
        c.span(10, 4, 11, 'j')
    # walking staff
    x = 13 if view == 'down' else (2 if view == 'up' else 12)
    for y in range(4, 30):
        c.put(x, y, 'n')
    c.put(x, 3, 'N')
    if view == 'right':
        c.put(10, 17, 'FF')
    else:
        c.put(x if view == 'down' else x + 1, 17, 'F')


# --------------------------------------------------------------- palettes

PEOPLE = {
    'elder': (elder, {'R': (150, 140, 164), 'r': (104, 96, 120), 'C': (104, 96, 120),
                      'h': (226, 224, 216), 'n': (110, 80, 52)}),
    'mayor': (elder, {'R': (104, 52, 112), 'r': (68, 32, 76), 'C': (226, 186, 84),
                      'h': (176, 170, 160), 'n': (70, 46, 34)}),
    'worker': (worker, {'S': (206, 180, 132), 's': (160, 134, 92), 'A': (72, 100, 150),
                        'U': (110, 84, 60), 'u': (80, 60, 44), 'h': (96, 64, 40),
                        'P': (96, 128, 70), 'p': (64, 90, 46)}),
    'smith': (worker, {'S': (150, 120, 100), 's': (106, 84, 70), 'A': (88, 60, 42),
                       'U': (70, 66, 74), 'u': (48, 46, 54), 'h': (40, 30, 28),
                       'P': (60, 58, 64), 'p': (40, 38, 44)}),
    'merchant': (merchant, {'S': (150, 96, 60), 's': (104, 64, 40), 'A': (236, 232, 220),
                            'U': (90, 78, 68), 'u': (62, 54, 48), 'h': (110, 72, 44)}),
    'innkeeper_b': (merchant, {'S': (120, 72, 90), 's': (82, 46, 62), 'A': (230, 214, 180),
                               'U': (80, 70, 80), 'u': (56, 48, 56), 'h': (60, 40, 30)}),
    'shopkeeper': (merchant, {'S': (80, 120, 90), 's': (52, 84, 60), 'A': (232, 222, 190),
                              'U': (96, 84, 66), 'u': (66, 58, 46), 'h': (40, 30, 30)}),
    'child': (child, {'S': (190, 70, 60), 's': (136, 46, 40), 'h': (120, 76, 42),
                      'P': (230, 200, 90), 'U': (90, 110, 150), 'u': (64, 80, 112)}),
    'child_b': (child, {'S': (100, 150, 200), 's': (66, 104, 150), 'h': (200, 150, 70),
                        'P': (200, 80, 90), 'U': (110, 90, 70), 'u': (80, 64, 50)}),
    'guard': (guard, {'M': (130, 136, 150), 'm': (92, 96, 110), 'T': (60, 90, 150), 't': (40, 62, 110),
                      'B': (226, 186, 84), 'L': (190, 196, 210), 'l': (130, 136, 150),
                      'U': (80, 76, 90), 'u': (56, 52, 64), 'h': (90, 60, 40), 'n': (110, 80, 52)}),
    'guard_b': (guard, {'M': (130, 136, 150), 'm': (92, 96, 110), 'T': (70, 120, 70), 't': (48, 84, 48),
                        'B': (226, 186, 84), 'L': (190, 196, 210), 'l': (130, 136, 150),
                        'U': (80, 76, 90), 'u': (56, 52, 64), 'h': (40, 30, 28), 'n': (110, 80, 52)}),
    'priestess': (priestess, {'W': (240, 236, 226), 'w': (190, 184, 176), 'G': (226, 186, 84),
                              'h': (150, 90, 50)}),
    'traveler': (traveler, {'H': (80, 110, 70), 'j': (52, 76, 46), 'S': (170, 140, 100),
                            'U': (96, 80, 64), 'u': (66, 54, 44), 'h': (70, 50, 36),
                            'n': (120, 88, 56), 'N': (90, 64, 40)}),
}


def frame(draw, pal, view, pose):
    c = Canvas(FW, FH)
    draw(c, view, pose)
    c.outline()
    im = Image.new('RGBA', (FW, FH), (0, 0, 0, 0))
    for y, row in enumerate(c.rows()):
        for x, ch in enumerate(row):
            col = pal[ch]
            if col:
                im.putpixel((x, y), col + (255,))
    return im


def sheet(draw, pal):
    out = Image.new('RGBA', (FW * 3, FH * 3), (0, 0, 0, 0))
    for r, view in enumerate(VIEWS):
        for col, pose in enumerate(POSES):
            out.paste(frame(draw, pal, view, pose), (col * FW, r * FH))
    return out


def frames_tres(sprites_dir, name):
    """<name>_frames.tres: a copy of Silas's with the sheet path swapped (same
    regions and animation names, since every walk sheet shares the layout)."""
    src = open(os.path.join(sprites_dir, 'silas_frames.tres'), encoding='utf-8').read()
    out = src.replace('res://assets/sprites/silas_walk.png', 'res://assets/sprites/%s_walk.png' % name)
    assert out != src
    with open(os.path.join(sprites_dir, name + '_frames.tres'), 'w', encoding='utf-8', newline='\n') as f:
        f.write(out)


if __name__ == '__main__':
    sprites_dir = sys.argv[1]
    sheets = {}
    for name, (draw, pal) in PEOPLE.items():
        sheets[name] = sheet(draw, dict(BASE, **pal))
        sheets[name].save(os.path.join(sprites_dir, name + '_walk.png'))
        frames_tres(sprites_dir, name)
    if len(sys.argv) > 2:
        prev = Image.new('RGBA', ((FW * 3 + 4) * len(sheets) + 4, FH * 3 + 8), (60, 52, 70, 255))
        for i, s in enumerate(sheets.values()):
            prev.alpha_composite(s, (4 + i * (FW * 3 + 4), 4))
        prev.resize((prev.width * 4, prev.height * 4), Image.NEAREST).save(sys.argv[2])
