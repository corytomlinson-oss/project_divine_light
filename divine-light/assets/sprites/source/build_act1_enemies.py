"""Hand-placed battle sprites for Act I's nine dungeon enemies (Milestone 21).

24x32 two-frame idle sheets like the Milestone 16 enemies (three fit across
the enemy area), facing right: assets/sprites/enemies/<slug>.png. Drawn with
the same canvas helpers as the bosses (build_act1_bosses.py): spans and
pixels, then an automatic outline.

Usage: python build_act1_enemies.py <out_dir> [preview.png]
"""
from build_act1_bosses import boss, build

ENEMIES = {}
SIZE = (24, 32)


def enemy(slug, breathe_row, glow, pal):
    return boss(slug, breathe_row, glow, pal, size=SIZE, registry=ENEMIES)


SKIN = {'F': (212, 168, 128), 'f': (156, 112, 84)}

# ================================================================ Monastery

# Corrupted Monk: a young monk in a flurry - one fist out, one pulled up.
@enemy('corrupted_monk', 18, {'V': 'X'}, dict(SKIN, **{
    'O': (198, 112, 52), 'o': (134, 68, 36), 'r': (82, 40, 28), 'n': (72, 46, 84),
}))
def corrupted_monk(c):
    for y, x0, x1 in [(24, 8, 10), (25, 7, 10), (26, 6, 9), (27, 5, 8), (28, 5, 8)]:
        c.span(y, x0, x1, 'r')  # back leg
    for y, x0, x1 in [(24, 13, 15), (25, 13, 16), (26, 14, 17), (27, 15, 17), (28, 15, 17)]:
        c.span(y, x0, x1, 'r')  # front leg
    c.span(29, 3, 8, 'F')
    c.span(29, 15, 19, 'F')
    for y, x0, x1 in [(11, 9, 14), (12, 8, 15), (13, 8, 15), (14, 8, 15), (15, 8, 15),
                      (16, 8, 15), (17, 8, 15), (18, 8, 15), (19, 7, 16), (20, 7, 16),
                      (21, 7, 16), (22, 7, 16), (23, 8, 15)]:
        c.span(y, x0, x1, 'O')
        c.put(x0, y, 'o')
    c.put(12, 11, 'FF')         # open collar
    c.put(12, 12, 'F')
    c.span(18, 8, 15, 'n')      # sash
    c.put(11, 23, '..')         # the split of the robe
    for y, x0, x1 in [(4, 10, 14), (5, 9, 15), (6, 9, 15), (7, 9, 15), (8, 9, 15), (9, 10, 14)]:
        c.span(y, x0, x1, 'F')  # bald head
        c.put(x0, y, 'f')
    c.put(11, 4, 'FFF')
    c.put(13, 6, 'V')           # eye
    c.put(15, 7, 'f')           # nose
    c.put(13, 9, 'ff')
    c.span(10, 11, 13, 'f')     # neck
    c.span(12, 15, 18, 'F')     # front arm, punching
    c.span(13, 15, 18, 'f')
    c.span(11, 19, 21, 'F')     # fist
    c.span(12, 19, 21, 'F')
    c.span(13, 19, 21, 'f')
    c.put(22, 11, 'V')          # ki
    c.put(22, 12, 'X')
    c.put(22, 13, 'V')
    c.span(12, 6, 8, 'O')       # back arm, fist raised
    c.span(11, 5, 7, 'o')
    c.span(8, 5, 7, 'F')
    c.span(9, 5, 7, 'F')
    c.span(10, 5, 7, 'f')
    c.put(4, 8, 'V')


# Berserk Warrior: shirtless, wild red hair, axe raised high.
@enemy('berserk_warrior', 19, {'V': 'X', 'R': 'Q'}, dict(SKIN, **{
    'R': (184, 62, 40), 'Q': (220, 90, 50),     # hair (flares on frame 2)
    'U': (86, 72, 60), 'u': (58, 48, 42), 'j': (40, 30, 30),
    'S': (204, 210, 224), 's': (122, 130, 152), 'n': (96, 70, 48), 'p': (160, 40, 40),
}))
def berserk_warrior(c):
    for y, x0, x1 in [(22, 7, 11), (23, 6, 11), (24, 6, 10), (25, 5, 9), (26, 5, 9), (27, 5, 9)]:
        c.span(y, x0, x1, 'U')
    for y, x0, x1 in [(22, 12, 16), (23, 12, 16), (24, 13, 17), (25, 13, 17), (26, 13, 17), (27, 13, 17)]:
        c.span(y, x0, x1, 'U')
        c.put(x1, y, 'u')
    c.span(28, 4, 9, 'j')
    c.span(29, 3, 9, 'j')
    c.span(28, 13, 18, 'j')
    c.span(29, 13, 19, 'j')
    for y, x0, x1 in [(11, 8, 15), (12, 7, 16), (13, 7, 16), (14, 7, 16), (15, 7, 16),
                      (16, 8, 15), (17, 8, 15), (18, 8, 15), (19, 8, 15)]:
        c.span(y, x0, x1, 'F')  # bare torso
        c.put(x0, y, 'f')
    c.put(10, 13, 'pp')         # war paint
    c.put(13, 15, 'pp')
    c.put(11, 17, 'f')
    c.put(14, 12, 'V')
    c.span(20, 7, 16, 'n')      # belt
    c.span(21, 7, 16, 'u')
    for y, x0, x1 in [(5, 10, 15), (6, 9, 15), (7, 9, 15), (8, 9, 15), (9, 10, 14)]:
        c.span(y, x0, x1, 'F')
        c.put(x0, y, 'f')
    for x, y in [(8, 2), (10, 1), (12, 2), (9, 3), (14, 3)]:
        c.put(x, y, 'R')        # wild hair
    c.span(3, 8, 14, 'R')
    c.span(4, 7, 15, 'R')
    c.put(7, 5, 'RR')
    c.put(6, 6, 'RR')
    c.put(7, 7, 'R')
    c.put(13, 6, 'V')           # mad eye
    c.put(12, 6, 'f')
    c.put(15, 7, 'f')
    c.put(12, 8, 'fff')         # snarl
    # arms up, both hands on the haft
    for y, x0, x1 in [(11, 15, 17), (10, 16, 18), (9, 17, 18), (8, 17, 19)]:
        c.span(y, x0, x1, 'F')
    for y, x0, x1 in [(12, 6, 8), (11, 6, 8), (10, 7, 9), (9, 8, 10)]:
        c.span(y, x0, x1, 'f')
    for k in range(9):          # haft
        c.put(16 + k // 3, 9 - k, 'n')
    c.put(9, 8, 'n')
    c.span(7, 17, 19, 'F')      # hands
    c.span(0, 18, 22, 'S')      # axe head
    c.span(1, 18, 22, 'S')
    c.span(2, 19, 22, 's')
    c.span(3, 20, 22, 's')
    c.put(22, 0, 's')


# Iron Sentinel: a temple guardian in heavy iron behind a tower shield.
@enemy('iron_sentinel', 20, {'V': 'X'}, {
    'I': (92, 96, 112), 'i': (62, 64, 78), 'l': (140, 146, 164),
    'B': (178, 128, 64), 'b': (122, 84, 40),
})
def iron_sentinel(c):
    for y in range(24, 29):
        c.span(y, 6, 9, 'I')
        c.span(y, 11, 14, 'I')
        c.put(6, y, 'i')
        c.put(11, y, 'i')
    c.span(29, 5, 9, 'i')
    c.span(29, 11, 15, 'i')
    for y in range(11, 24):
        c.span(y, 5, 15, 'I')
        c.put(5, y, 'i')
        c.put(6, y, 'l')
    c.span(11, 5, 15, 'l')
    c.span(16, 5, 15, 'B')      # bronze bands
    c.span(23, 5, 15, 'B')
    for y, x0, x1 in [(3, 8, 13), (4, 7, 14), (5, 7, 14), (6, 7, 14), (7, 7, 14), (8, 7, 14),
                      (9, 7, 14), (10, 8, 13)]:
        c.span(y, x0, x1, 'I')
        c.put(x0, y, 'l')
    c.span(3, 8, 13, 'B')
    c.put(10, 2, 'BB')          # crest
    c.span(6, 10, 14, 'i')      # visor slit
    c.put(12, 6, 'VV')
    c.span(11, 3, 6, 'I')       # pauldron
    c.span(12, 3, 6, 'I')
    c.span(11, 3, 6, 'l')
    # tower shield in front
    for y in range(9, 29):
        c.span(y, 14, 20, 'I')
        c.put(14, y, 'B')
        c.put(20, y, 'b')
    c.span(9, 14, 20, 'B')
    c.span(28, 14, 20, 'b')
    for x, y in [(15, 11), (19, 11), (15, 26), (19, 26)]:
        c.put(x, y, 'l')        # rivets
    c.span(18, 15, 19, 'B')     # cross band
    for y in range(10, 28):
        c.put(17, y, 'B')
    c.put(16, 14, 'V')          # corruption seeping through the iron
    c.put(18, 22, 'V')


# ============================================================== Observatory

# Void Mage: a stargazer gone wrong - pointed hat, starry robe, a small orb.
# Its aura icon (shown above it in battle) says which element it's in.
@enemy('void_mage', None, {'V': 'X', 'E': 'e'}, {
    'T': (40, 74, 92), 't': (26, 48, 62),       # hat / robe
    'L': (196, 204, 232),                       # stars
    'H': (10, 6, 18), 'E': (236, 228, 255), 'e': (180, 150, 230),
    'F': (176, 158, 198), 'o': (14, 8, 26),
})
def void_mage(c):
    for y in range(11, 29):
        x0 = 9 - (y - 11) // 4
        x1 = 14 + (y - 11) // 6
        c.span(y, x0, x1, 'T')
        c.put(x0, y, 't')
    for x, y in [(8, 16), (11, 21), (13, 14), (7, 25), (12, 27)]:
        c.put(x, y, 'L')
    for x, d in [(6, 2), (9, 1), (12, 2), (15, 1)]:
        for k in range(d):
            c.put(x, 29 + k, 'V')   # hem fraying into void
    c.span(7, 5, 17, 't')           # hat brim
    for y, x0, x1 in [(6, 8, 14), (5, 9, 13), (4, 9, 12), (3, 8, 11), (2, 7, 9), (1, 5, 7)]:
        c.span(y, x0, x1, 'T')      # hat, tip bent back
    c.put(4, 1, 't')
    c.put(10, 5, 'L')
    for y, x0, x1 in [(8, 10, 14), (9, 10, 14), (10, 11, 14)]:
        c.span(y, x0, x1, 'H')      # face in shadow
    c.put(12, 9, 'E')
    c.put(14, 9, 'E')
    c.span(14, 14, 17, 'T')         # arm forward
    c.span(15, 15, 17, 't')
    c.put(17, 16, 'FF')
    for y, x0, x1 in [(12, 19, 21), (13, 18, 22), (14, 18, 22), (15, 18, 22), (16, 19, 21)]:
        c.span(y, x0, x1, 'o')      # orb
        c.put(x0, y, 'V')
        c.put(x1, y, 'V')
    c.span(12, 19, 21, 'V')
    c.put(19, 13, 'X')


# Astral Familiar: a small floating owl of starlight - fast, and full of mischief.
@enemy('astral_familiar', None, {'E': 'e', 'w': 'x', 'S': 'I'}, {
    'S': (170, 206, 240), 'I': (200, 228, 252), 's': (100, 132, 190),
    'D': (60, 70, 130), 'E': (120, 240, 255), 'e': (210, 255, 255),
    'B': (240, 200, 90),
    'w': (150, 190, 240), 'x': (220, 240, 255),
})
def astral_familiar(c):
    for y, x0, x1 in [(9, 9, 15), (10, 8, 16), (11, 7, 17), (12, 7, 17), (13, 7, 17), (14, 7, 17),
                      (15, 7, 17), (16, 8, 16), (17, 8, 16), (18, 9, 15), (19, 10, 14)]:
        c.span(y, x0, x1, 'S')
        c.put(x0, y, 's')
    c.put(8, 8, 'S')            # ear tufts
    c.put(7, 7, 'S')
    c.put(16, 8, 'S')
    c.put(17, 7, 'S')
    c.put(9, 11, 'DDD')         # eye rings
    c.put(13, 11, 'DDD')
    c.put(9, 12, 'DED')
    c.put(13, 12, 'DED')
    c.put(9, 13, 'DDD')
    c.put(13, 13, 'DDD')
    c.put(12, 14, 'B')          # beak
    c.put(12, 15, 'B')
    for x, y in [(10, 16), (13, 17), (11, 18)]:
        c.put(x, y, 's')        # chest speckles
    for y, x0, x1 in [(11, 3, 6), (12, 2, 6), (13, 2, 6), (14, 3, 6), (15, 4, 6)]:
        c.span(y, x0, x1, 's')  # wings
    for y, x0, x1 in [(11, 18, 21), (12, 18, 22), (13, 18, 22), (14, 18, 21), (15, 18, 20)]:
        c.span(y, x0, x1, 's')
    c.put(2, 11, 'S')
    c.put(22, 11, 'S')
    for x, y in [(12, 21), (11, 23), (13, 24), (12, 26), (10, 27), (14, 28), (12, 29)]:
        c.put(x, y, 'w')        # sparkle tail
    for x, y in [(4, 5), (20, 4), (2, 20), (21, 19)]:
        c.put(x, y, 'w')


# Corrupted Scholar: a hunched old scholar with an open tome of silencing glyphs.
@enemy('corrupted_scholar', 20, {'V': 'X'}, dict(SKIN, **{
    'P': (124, 96, 66), 'p': (84, 62, 42),       # robe
    'h': (222, 218, 206),                        # hair tufts
    'G': (230, 236, 255),                        # spectacles glint
    'W': (232, 222, 196), 'w': (186, 172, 140),  # pages
    'b': (96, 40, 50),                           # tome cover
}))
def corrupted_scholar(c):
    for y in range(12, 29):
        x0 = 7 - (y - 12) // 6
        c.span(y, x0, 14, 'P')
        c.put(x0, y, 'p')
    c.span(11, 7, 12, 'P')      # hunched back
    c.span(10, 7, 10, 'P')
    c.span(29, 5, 9, 'p')       # slippers
    c.span(29, 11, 14, 'p')
    for y, x0, x1 in [(6, 11, 15), (7, 10, 16), (8, 10, 16), (9, 10, 16), (10, 11, 15), (11, 12, 15)]:
        c.span(y, x0, x1, 'F')  # head, thrust forward
        c.put(x0, y, 'f')
    c.put(10, 6, 'h')           # white tufts
    c.put(9, 7, 'hh')
    c.put(9, 8, 'h')
    c.put(13, 8, 'GfG')         # spectacles
    c.put(17, 9, 'f')           # long nose
    c.put(14, 10, 'ff')
    c.put(14, 9, 'V')           # the eye behind the glass
    # the open tome, held out
    c.span(14, 15, 21, 'W')
    c.span(15, 15, 21, 'W')
    c.span(16, 15, 21, 'w')
    c.put(18, 14, 'p')          # spine
    c.put(18, 15, 'p')
    c.span(17, 15, 21, 'b')
    c.put(16, 14, 'V')          # glyphs
    c.put(20, 15, 'V')
    c.put(19, 13, 'V')
    c.put(21, 12, 'X')
    c.span(16, 13, 15, 'F')     # hands under it
    c.span(17, 12, 14, 'f')


# =================================================================== Guild

# Shadow Thief: a hooded cutpurse, crouched, knife out, loot sack on the back.
@enemy('shadow_thief', 18, {'V': 'X'}, {
    'H': (64, 60, 78), 'h': (92, 86, 108), 'j': (34, 30, 42),
    'M': (54, 100, 72), 'f': (40, 32, 36), 'y': (220, 240, 255),
    'P': (164, 128, 80), 'p': (110, 82, 50), 'C': (228, 188, 86),
    'S': (206, 212, 226),
})
def shadow_thief(c):
    for y, x0, x1 in [(10, 3, 7), (11, 2, 8), (12, 2, 8), (13, 2, 8), (14, 2, 8), (15, 3, 7), (16, 4, 6)]:
        c.span(y, x0, x1, 'P')  # loot sack
        c.put(x0, y, 'p')
    c.put(4, 9, 'pp')
    c.put(6, 12, 'C')           # a coin poking out
    for y, x0, x1 in [(14, 8, 15), (15, 8, 15), (16, 8, 15), (17, 8, 15), (18, 8, 15), (19, 8, 16), (20, 8, 16), (21, 9, 16)]:
        c.span(y, x0, x1, 'H')
        c.put(x0, y, 'j')
    c.span(19, 8, 16, 'j')      # belt
    for y, x0, x1 in [(22, 7, 10), (23, 6, 9), (24, 5, 8), (25, 5, 8), (26, 5, 8), (27, 5, 8)]:
        c.span(y, x0, x1, 'j')  # back leg, crouched
    for y, x0, x1 in [(22, 13, 16), (23, 14, 17), (24, 15, 18), (25, 15, 18), (26, 15, 18), (27, 15, 18)]:
        c.span(y, x0, x1, 'H')
        c.put(x1, y, 'j')
    c.span(28, 4, 8, 'j')
    c.span(28, 15, 20, 'j')
    for y, x0, x1 in [(6, 10, 14), (7, 9, 15), (8, 9, 16), (9, 9, 16), (10, 9, 16), (11, 9, 16), (12, 10, 16), (13, 10, 15)]:
        c.span(y, x0, x1, 'H')  # hood
        c.put(x0, y, 'j')
    c.put(9, 5, 'H')
    c.span(9, 13, 16, 'f')
    c.put(14, 9, 'y')           # eye glint
    c.span(10, 12, 16, 'M')     # mask
    c.span(11, 12, 16, 'M')
    c.span(16, 15, 17, 'h')     # arm out
    c.span(17, 16, 18, 'H')
    c.put(19, 16, 'S')          # knife
    c.put(20, 16, 'SS')
    c.put(22, 15, 'S')
    c.put(12, 15, 'V')


# Venomous Cutthroat: lean, masked, a hooked blade in each hand dripping poison.
@enemy('venomous_cutthroat', 18, {'V': 'X', 'Z': 'z'}, {
    'F': (176, 168, 120), 'f': (124, 116, 80),   # sickly skin
    'A': (70, 60, 52), 'a': (46, 40, 36),        # leathers
    'R': (60, 92, 60), 'r': (40, 64, 42),        # bandana
    'Z': (150, 232, 92), 'z': (96, 168, 56),
    'S': (206, 212, 226), 's': (122, 130, 152), 'j': (34, 28, 30),
})
def venomous_cutthroat(c):
    for y, x0, x1 in [(21, 8, 10), (22, 7, 10), (23, 7, 9), (24, 6, 9), (25, 6, 9), (26, 6, 9), (27, 6, 9)]:
        c.span(y, x0, x1, 'a')
    for y, x0, x1 in [(21, 12, 14), (22, 12, 15), (23, 13, 15), (24, 13, 16), (25, 13, 16), (26, 13, 16), (27, 13, 16)]:
        c.span(y, x0, x1, 'A')
    c.span(28, 5, 9, 'j')
    c.span(28, 13, 18, 'j')
    for y, x0, x1 in [(11, 9, 14), (12, 8, 14), (13, 8, 14), (14, 8, 14), (15, 8, 14),
                      (16, 9, 14), (17, 9, 14), (18, 9, 14), (19, 8, 15), (20, 8, 15)]:
        c.span(y, x0, x1, 'A')
        c.put(x0, y, 'a')
    c.span(19, 8, 15, 'a')      # belt
    for k in range(5):
        c.put(10 + k, 12 + k, 'a')  # baldric
    for y, x0, x1 in [(5, 10, 14), (6, 9, 15), (7, 9, 15), (8, 9, 15), (9, 10, 14), (10, 11, 13)]:
        c.span(y, x0, x1, 'F')
        c.put(x0, y, 'f')
    c.span(5, 10, 14, 'R')      # bandana over the head
    c.span(6, 9, 15, 'R')
    c.put(8, 6, 'rr')
    c.put(7, 7, 'r')
    c.put(13, 7, 'Z')           # eye
    c.span(8, 12, 15, 'R')      # mask over the mouth
    c.span(9, 11, 15, 'r')
    # front arm: bare, hooked blade out front
    c.span(12, 14, 16, 'F')
    c.span(13, 15, 17, 'F')
    c.span(14, 16, 18, 'f')
    for x, y in [(19, 13), (20, 12), (21, 12), (22, 13), (22, 14)]:
        c.put(x, y, 'S')
    c.put(19, 14, 's')
    c.put(22, 15, 'Z')
    c.put(22, 17, 'z')
    # back arm: blade held low behind
    c.span(12, 6, 8, 'F')
    c.span(13, 5, 7, 'F')
    c.span(14, 4, 6, 'f')
    for x, y in [(3, 15), (2, 16), (2, 17), (3, 18)]:
        c.put(x, y, 'S')
    c.put(4, 19, 'Z')
    c.put(4, 21, 'z')


# Hired Muscle: a slab of a man with a club on his shoulder. Slow, hard to drop.
@enemy('hired_muscle', 21, {'V': 'X'}, {
    'F': (196, 146, 110), 'f': (140, 100, 76),
    'A': (96, 76, 60), 'a': (62, 50, 42),
    'U': (74, 70, 86), 'u': (50, 46, 60), 'j': (36, 30, 32),
    'n': (110, 80, 52), 'N': (74, 52, 34), 'g': (120, 120, 128),
})
def hired_muscle(c):
    for y in range(23, 28):
        c.span(y, 4, 9, 'U')
        c.span(y, 12, 17, 'U')
        c.put(9, y, 'u')
        c.put(17, y, 'u')
    c.span(28, 3, 9, 'j')
    c.span(29, 3, 10, 'j')
    c.span(28, 12, 18, 'j')
    c.span(29, 12, 19, 'j')
    for y, x0, x1 in [(9, 6, 16), (10, 4, 17), (11, 3, 18), (12, 2, 18), (13, 2, 18), (14, 2, 18),
                      (15, 2, 18), (16, 2, 18), (17, 3, 18), (18, 3, 18), (19, 3, 18), (20, 3, 18),
                      (21, 4, 17), (22, 4, 17)]:
        c.span(y, x0, x1, 'F')  # huge bare torso and arms
        c.put(x0, y, 'f')
    for y in range(10, 20):     # open leather vest, chest and gut bare between
        c.span(y, 5, 7, 'A')
        c.span(y, 14, 16, 'A')
        c.put(7, y, 'a')
        c.put(14, y, 'a')
    c.put(9, 13, 'ff')          # chest line
    c.put(12, 13, 'f')
    c.span(16, 9, 12, 'f')      # gut
    c.put(10, 18, 'f')          # navel
    c.span(20, 4, 17, 'a')      # belt
    c.put(10, 20, 'gg')
    c.put(5, 16, 'f')           # arm lines
    c.put(16, 16, 'f')
    c.put(15, 12, 'V')          # corruption vein
    c.put(5, 13, 'V')
    for y, x0, x1 in [(4, 9, 13), (5, 8, 14), (6, 8, 14), (7, 8, 14), (8, 9, 13)]:
        c.span(y, x0, x1, 'F')  # small head
        c.put(x0, y, 'f')
    c.put(12, 6, 'V')           # eye
    c.put(14, 6, 'f')
    c.put(10, 8, 'fff')         # stubble
    c.span(4, 9, 13, 'f')
    # club over the shoulder
    for k in range(10):
        c.put(16 + k // 2, 13 - k, 'n')
    c.put(15, 13, 'FFF')        # fist round the handle
    c.put(15, 14, 'fff')
    for y, x0, x1 in [(0, 19, 22), (1, 19, 22), (2, 18, 22), (3, 18, 22), (4, 19, 21)]:
        c.span(y, x0, x1, 'n')
        c.put(x1, y, 'N')
    c.put(20, 1, 'g')           # a nail driven through it
    c.put(21, 3, 'g')


if __name__ == '__main__':
    build(ENEMIES)
