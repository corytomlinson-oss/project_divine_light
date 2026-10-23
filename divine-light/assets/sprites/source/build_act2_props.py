"""Milestone 25a props, hand-placed 16x16 like the chests:

    python build_act2_props.py      (from this folder)

Writes:
    ../blight.png   2 frames: violet brambles of the Unraveling, pulsing
    ../stairs.png   2 frames: stairs down, stairs up (dungeon floors)
"""
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent

PALETTE = {
    ".": (0, 0, 0, 0),
    "k": (26, 20, 32, 255),     # outline
    "d": (58, 30, 78, 255),     # bramble dark
    "m": (110, 52, 150, 255),   # bramble
    "p": (170, 80, 220, 255),   # glow
    "P": (220, 150, 255, 255),  # glow bright
    "w": (196, 190, 210, 255),  # thorn
    "s": (40, 36, 50, 255),     # stone dark
    "g": (92, 88, 106, 255),    # stone
    "G": (140, 136, 156, 255),  # stone light
    "h": (190, 186, 204, 255),  # step edge
}

BLIGHT_A = [
    "................",
    "....k.....k.....",
    "...kmk...kdk..k.",
    "..kmdmk.kmdk.kmk",
    ".kdmwmdkdmmkkdmk",
    ".kmdmdmkmwdmkmdk",
    "kdmpmdkmdmpdkdmk",
    "kmdmwdmdmdmdmwdk",
    ".kdmdmpmdwmdmdk.",
    "kmwdmdmdmdmpdmdk",
    "kdmdpmdkmdmdmwmk",
    ".kmdmdk.kdmdmdk.",
    "..kdmk...kdmdk..",
    "...kdk....kdk...",
    "....k......k....",
    "................",
]
BLIGHT_B = [row.replace("p", "P") for row in BLIGHT_A]

STAIRS_DOWN = [
    "kkkkkkkkkkkkkkkk",
    "khhhhhhhhhhhhhhk",
    "kGGGGGGGGGGGGGGk",
    "kkkkkkkkkkkkkkkk",
    "kshhhhhhhhhhhhsk",
    "ksggggggggggggsk",
    "kskkkkkkkkkkkksk",
    "kssshhhhhhhhsssk",
    "kssgggggggggsssk",
    "ksskkkkkkkkkkssk",
    "ksssshhhhhhssssk",
    "ksssgggggggssssk",
    "kssskkkkkkkksssk",
    "kssssssssssssssk",
    "kssssssssssssssk",
    "kkkkkkkkkkkkkkkk",
]
STAIRS_UP = [
    "kkkkkkkkkkkkkkkk",
    "kssssssssssssssk",
    "ksssshhhhhhssssk",
    "ksssGGGGGGGGsssk",
    "ksskkkkkkkkkkssk",
    "kssshhhhhhhhhssk",
    "ksgGGGGGGGGGGgsk",
    "kskkkkkkkkkkkksk",
    "kshhhhhhhhhhhhsk",
    "kgGGGGGGGGGGGGgk",
    "kkkkkkkkkkkkkkkk",
    "khhhhhhhhhhhhhhk",
    "kGGGGGGGGGGGGGGk",
    "kggggggggggggggk",
    "kggggggggggggggk",
    "kkkkkkkkkkkkkkkk",
]


def draw(grid):
    im = Image.new("RGBA", (16, 16))
    for y, row in enumerate(grid):
        assert len(row) == 16, (y, row)
        for x, ch in enumerate(row):
            im.putpixel((x, y), PALETTE[ch])
    return im


def sheet(name, grids):
    out = Image.new("RGBA", (16 * len(grids), 16))
    for i, g in enumerate(grids):
        out.paste(draw(g), (16 * i, 0))
    out.save(HERE.parent / name)
    print("wrote", name)


sheet("blight.png", [BLIGHT_A, BLIGHT_B])
sheet("stairs.png", [STAIRS_DOWN, STAIRS_UP])
