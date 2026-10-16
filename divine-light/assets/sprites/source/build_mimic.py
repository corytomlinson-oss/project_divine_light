"""The Mimic's battle sprite (Milestone 23b): a wooden chest - the same wood
and iron as the dungeon chests - with its lid flung up, rows of teeth, a
violet eye in the dark of its mouth and a long tongue lolling over the front.

24x32 two-frame idle like the Act I enemies (build_act1_enemies.py): frame 2
drops everything above the jaw 1px, so it reads as chomping.

Usage: python build_mimic.py <out_dir> [preview.png]
"""
from build_act1_bosses import boss, build

ENEMIES = {}

PAL = {
    'l': (190, 132, 76), 'o': (146, 94, 52), 'w': (96, 58, 34),   # wood (chests.png)
    'S': (150, 158, 178), 'D': (78, 84, 104),                     # iron bands
    'm': (70, 18, 28), 'M': (110, 30, 42),                        # mouth
    'T': (240, 236, 220),                                         # teeth
    'P': (214, 92, 120), 'p': (160, 56, 84),                      # tongue
    'Y': (255, 232, 140),                                         # lock
}


@boss('mimic', 15, {'V': 'X'}, PAL, size=(24, 32), registry=ENEMIES)
def mimic(c):
    # The lid, hinged at the back (left) and flung up toward the party.
    for x in range(2, 21):
        top = 10 - (x - 2) * 7 // 18
        c.put(x, top, 'l')
        for y in range(top + 1, top + 4):
            c.put(x, y, 'o')
        c.put(x, top + 4, 'w')
        if x in (5, 17):
            for y in range(top, top + 5):
                c.put(x, y, 'S' if y < top + 4 else 'D')
        # the mouth below the lid, down to the jaw
        for y in range(top + 5, 19):
            c.put(x, y, 'M' if y > 16 else 'm')
        if x % 2 == 0:
            c.put(x, top + 5, 'T')  # upper teeth
    c.put(19, 4, 'YY')              # the lock, now on the lid's lip
    # The body.
    for y in range(19, 30):
        c.span(y, 2, 20, 'l' if y == 19 else 'w' if y == 29 else 'o')
    for y in range(19, 30):
        c.put(5, y, 'S' if y < 29 else 'D')
        c.put(17, y, 'S' if y < 29 else 'D')
    for x in range(3, 21, 2):
        c.put(x, 18, 'T')           # lower teeth
    # Its eye, deep in the mouth.
    c.put(7, 13, 'VV')
    c.put(7, 14, 'vv')
    # The tongue, lolling out over the front.
    for y, x0, x1 in [(16, 11, 16), (17, 13, 19), (18, 16, 21), (19, 18, 22),
                      (20, 19, 22), (21, 20, 22), (22, 20, 22), (23, 21, 22)]:
        c.span(y, x0, x1, 'P')
    c.put(21, 23, 'p')
    c.put(14, 17, 'pp')
    c.put(20, 21, 'p')
    # Stubby claws where it has been dragging itself along.
    c.put(3, 30, 'ww')
    c.put(18, 30, 'ww')


if __name__ == '__main__':
    build(ENEMIES)
