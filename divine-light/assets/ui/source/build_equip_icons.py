"""Equipment icons (2026-10-25/28, Cory: "create icons for the equipment that
will display next to the name"). One 12x12 cell per shape x material:
columns = what the item is (Equipment.ICON_SHAPES), rows = what it's made of
or which set it belongs to (Equipment.ICON_ROWS / ICON_MATERIALS). The game
picks the cell from the item's slot, class, name and set, so every piece gets
an icon without a per-item table.

Usage: python build_equip_icons.py <out.png> [preview.png]
"""
import sys

from PIL import Image

CELL = 12
OUTLINE = (26, 20, 32)

# 10x10 shapes; H = highlight, M = main, D = dark, A = accent. Outlined after.
SHAPES = [
    ('sword', [
        ".........H",
        "........HH",
        ".......HM.",
        "......HM..",
        ".....HM...",
        ".A..HM....",
        "..AHM.....",
        "...AA.....",
        "..D..A....",
        ".D........"]),
    ('claws', [
        "..H.H.H...",
        "..H.H.H...",
        "..M.M.M...",
        "..M.M.M...",
        ".DMMMMMD..",
        ".DDDDDDD..",
        "..DAAAD...",
        "...AAA....",
        "...AAA....",
        "....A....."]),
    ('staff', [
        "....AA....",
        "...AHHA...",
        "...AHMA...",
        "....AA....",
        "....D.....",
        "....M.....",
        "....D.....",
        "....M.....",
        "....D.....",
        "....D....."]),
    ('daggers', [
        "H........H",
        ".H......H.",
        "..H....H..",
        "...M..M...",
        "....MM....",
        "....MM....",
        "...AD.DA..",
        "..A....A..",
        ".A......A.",
        ".........."]),
    ('plate', [
        ".HHH..HHH.",
        "HMMMHHMMMH",
        "HMMMMMMMMH",
        ".MMMHMMMM.",
        ".MMMHMMMM.",
        ".MMMHMMMM.",
        "..MMHMMM..",
        "..DDDDDD..",
        "..MM..MM..",
        ".........."]),
    ('gi', [
        "..MM..MM..",
        ".MMMHHMMM.",
        "MMMMHAMMMM",
        "MM.MAMM.MM",
        "...MAMM...",
        "...AAAA...",
        "...MMMM...",
        "...MM.MM..",
        "...MD.DM..",
        ".........."]),
    ('robe', [
        "...MMMM...",
        "..MHHHHM..",
        ".MMMAAMMM.",
        ".M.MAAM.M.",
        "..MMAAMM..",
        "..MMAAMM..",
        ".MMMAAMMM.",
        ".MMMAAMMM.",
        "MMMDAADMMM",
        "DDDDDDDDDD"]),
    ('leathers', [
        ".DD....DD.",
        ".DMM..MMD.",
        ".DMMMMMMD.",
        ".DMMHMMMD.",
        ".DMMHMMMD.",
        ".AAAAAAAA.",
        ".DMMMMMMD.",
        ".DMM..MMD.",
        "..........",
        ".........."]),
    ('helm', [
        "...HHHH...",
        "..HMMMMH..",
        ".HMMMMMMM.",
        ".MMMMMMMM.",
        ".MDDDDDDM.",
        ".MMM..MMM.",
        ".MMM..MMM.",
        ".MMMMMMMM.",
        "..MMMMMM..",
        ".........."]),
    ('band', [
        "..........",
        "..........",
        ".HHHHHHH..",
        ".MMMAMMMM.",
        ".MMMAMMMMD",
        ".DDDDDDD.D",
        "........DD",
        ".........D",
        "..........",
        ".........."]),
    ('circlet', [
        "..........",
        "..........",
        ".H..A...H.",
        ".HH.A..HH.",
        ".HMHAHHMH.",
        ".MMMMMMMM.",
        ".DDDADDDD.",
        "..........",
        "..........",
        ".........."]),
    ('hood', [
        "...MMMM...",
        "..MMMMMM..",
        ".MMDDDDMM.",
        ".MD.DD.DM.",
        ".MDAD.ADM.",
        ".MDDDDDDM.",
        ".MMDDDDMM.",
        "..MMMMMM..",
        "...MMMM...",
        ".........."]),
    ('gauntlet', [
        "..H.H.H...",
        ".HMHMHMH..",
        ".HMMMMMMH.",
        ".MMMMMMMM.",
        ".MMMMMMMH.",
        "..MMMMMM..",
        "..AAAAAA..",
        "..MMMMMM..",
        "..DDDDDD..",
        ".........."]),
    ('fists', [
        "..........",
        "..HHHHH...",
        ".HMMMMMH..",
        ".MMMMMMMA.",
        ".MMMMMMMA.",
        "..MMMMMM..",
        "..AMAMAM..",
        "..MAMAMA..",
        "..AMAMAM..",
        ".........."]),
    ('gloves', [
        "...M.M....",
        "..MM.MM.M.",
        "..MMMMMMM.",
        "..MMMMMMM.",
        ".MMMAAMMM.",
        ".MMMAAMM..",
        "..MMMMM...",
        "..DDDDD...",
        "..DDDDD...",
        ".........."]),
    ('wraps', [
        "..........",
        "..MDMDMD..",
        "..DMDMDM..",
        "..MDMDMD..",
        "..DMDMDM..",
        "..MDMDMD..",
        "...AAAA...",
        "...DMDM...",
        "..........",
        ".........."]),
    ('ring', [
        "....AA....",
        "...AHHA...",
        "....AA....",
        "..MMMMMM..",
        ".MM....MM.",
        ".M......M.",
        ".M......M.",
        ".MM....MM.",
        "..MMMMMM..",
        ".........."]),
    ('amulet', [
        ".D......D.",
        "..D....D..",
        "...D..D...",
        "....DD....",
        "...MMMM...",
        "..MHAAHM..",
        "..MAAAAM..",
        "..MHAAHM..",
        "...MMMM...",
        ".........."]),
    ('orb', [
        "..........",
        "...MMMM...",
        "..MHHMMM..",
        ".MHHMMMMD.",
        ".MHMMMMMD.",
        ".MMMMMMMD.",
        ".MMMMMMDD.",
        "..MMMMDD..",
        "...DDDD...",
        ".........."]),
    ('beads', [
        "...AMAMA..",
        "..M.....M.",
        ".A.......A",
        ".M.......M",
        ".A.......A",
        "..M.....M.",
        "...AMAMA..",
        "....D.....",
        "....DD....",
        ".........."]),
]

# Rows: highlight, main, dark, accent. Must match Equipment.ICON_ROWS order.
MATERIALS = [
    ('iron', (190, 190, 196), (130, 130, 140), (80, 80, 92), (150, 104, 62)),
    ('steel', (226, 232, 242), (164, 172, 190), (96, 104, 124), (126, 92, 60)),
    ('frost', (214, 242, 255), (130, 190, 230), (70, 110, 170), (255, 255, 255)),
    ('sun', (255, 224, 130), (232, 164, 62), (160, 96, 30), (255, 110, 40)),
    ('storm', (204, 238, 242), (110, 172, 192), (50, 96, 120), (120, 222, 255)),
    ('star', (252, 248, 255), (204, 186, 255), (122, 102, 192), (255, 240, 150)),
    ('holy_guardian', (246, 240, 222), (204, 186, 124), (140, 110, 50), (232, 190, 70)),
    ('iron_monk', (178, 178, 188), (112, 112, 126), (64, 64, 76), (136, 84, 48)),
    ('arcane_scholar', (204, 156, 242), (132, 82, 192), (80, 46, 124), (228, 194, 98)),
    ('shadow_walker', (152, 132, 192), (92, 72, 132), (50, 40, 76), (176, 120, 230)),
    ('sacred_aegis', (222, 234, 252), (142, 162, 202), (74, 88, 128), (110, 220, 255)),
    ('storm_dragon', (124, 164, 242), (60, 104, 200), (34, 64, 140), (232, 188, 64)),
    ('elemental_weave', (242, 114, 112), (186, 50, 60), (120, 28, 40), (242, 142, 52)),
    ('venom_weave', (132, 202, 112), (60, 112, 62), (30, 52, 34), (150, 255, 90)),
    ('divine_champion', (255, 250, 234), (236, 210, 120), (170, 130, 60), (150, 236, 255)),
    ('rising_force', (255, 124, 92), (214, 52, 40), (140, 26, 24), (255, 214, 90)),
    ('cosmic_conduit', (124, 114, 222), (62, 52, 152), (30, 24, 80), (255, 255, 255)),
    ('deaths_hand', (96, 86, 102), (44, 38, 50), (20, 16, 24), (226, 42, 52)),
    ('relic', (255, 238, 164), (242, 192, 82), (172, 112, 40), (255, 255, 224)),
]


def cell(shape, mat):
    _, hi, mid, dark, acc = mat
    pal = {'H': hi, 'M': mid, 'D': dark, 'A': acc}
    g = [['.'] * CELL for _ in range(CELL)]
    for y, row in enumerate(shape):
        assert len(row) == 10, row
        for x, ch in enumerate(row):
            g[y + 1][x + 1] = ch
    src = [r[:] for r in g]
    for y in range(CELL):
        for x in range(CELL):
            if src[y][x] == '.' and any(0 <= x + dx < CELL and 0 <= y + dy < CELL and src[y + dy][x + dx] != '.'
                                        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                g[y][x] = 'K'
    im = Image.new('RGBA', (CELL, CELL), (0, 0, 0, 0))
    for y in range(CELL):
        for x in range(CELL):
            ch = g[y][x]
            if ch == 'K':
                im.putpixel((x, y), OUTLINE + (255,))
            elif ch != '.':
                im.putpixel((x, y), pal[ch] + (255,))
    return im


if __name__ == '__main__':
    atlas = Image.new('RGBA', (CELL * len(SHAPES), CELL * len(MATERIALS)), (0, 0, 0, 0))
    for r, mat in enumerate(MATERIALS):
        for c, (_, shape) in enumerate(SHAPES):
            atlas.paste(cell(shape, mat), (c * CELL, r * CELL))
    atlas.save(sys.argv[1])
    if len(sys.argv) > 2:
        prev = Image.new('RGBA', atlas.size, (40, 34, 52, 255))
        prev.alpha_composite(atlas)
        prev.resize((atlas.width * 5, atlas.height * 5), Image.NEAREST).save(sys.argv[2])
