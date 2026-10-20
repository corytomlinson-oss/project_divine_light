"""Milestone 24b quest art: the three hunt targets (recolors of existing Act I
enemies, so they read as a marked, nastier one of a kind) and two overworld
props, hand-placed like the other small sprites.

    python build_quest_art.py      (from this folder)

Writes:
    ../enemies/grey_fang.png    the farmer's field-blighter (Blighted Wolf, ash + red)
    ../enemies/wreck_ghoul.png  picks at the lost cart (Corrupted Farmer, moss + red)
    ../enemies/cutpurse.png     robbed Edenmere's shop (Shadow Thief, leather + scarf)
    ../quest_props.png          16x16 frames: silverleaf A, silverleaf B, cart wreck
"""
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
ENEMIES = HERE.parent / "enemies"


def hexc(s: str) -> tuple:
    s = s.lstrip("#")
    return tuple(int(s[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


def recolor(src: str, dst: str, swaps: dict) -> None:
    im = Image.open(ENEMIES / f"{src}.png").convert("RGBA")
    table = {hexc(k): hexc(v) for k, v in swaps.items()}
    im.putdata([table.get(p, p) if p[3] else p for p in im.getdata()])
    im.save(ENEMIES / f"{dst}.png")
    print("wrote", dst)


# Grey Fang: ash-pale fur, blood-red glow instead of the Unraveling's violet.
recolor("blighted_wolf", "grey_fang", {
    "#4c4846": "#5c6068", "#767064": "#8e949e", "#a49c8a": "#cdd1d8",
    "#aa50dc": "#c8303c", "#dc96ff": "#ff7a6e",
})
# Wreck Ghoul: moss-rotted clothes, sickly skin, red eyes.
recolor("corrupted_farmer", "wreck_ghoul", {
    "#526078": "#45603a", "#343e54": "#2c4027", "#969caa": "#8fa47a",
    "#967858": "#8a9a6a", "#c4a458": "#a8b47a",
    "#aa50dc": "#c8303c", "#dc96ff": "#ff7a6e",
})
# Cutpurse: a plain leather-clad thief with a red scarf, not a Guild shadow.
recolor("shadow_thief", "cutpurse", {
    "#403c4e": "#5e4632", "#221e2a": "#3a2a1e", "#5c566c": "#7c6248",
    "#366448": "#9a2e2e",
    "#aa50dc": "#e4bc56", "#dc96ff": "#fff0a8",
})

# ---------------------------------------------------------------- props
PALETTE = {
    ".": (0, 0, 0, 0),
    "k": hexc("#1a1420"),   # outline
    "g": hexc("#2f6b3a"),   # leaf dark
    "G": hexc("#4f9a52"),   # leaf
    "s": hexc("#b8d8c8"),   # silver vein
    "S": hexc("#f0fff8"),   # glint
    "w": hexc("#5a3e26"),   # wood dark
    "W": hexc("#8a6440"),   # wood
    "L": hexc("#b08a5a"),   # wood light
    "i": hexc("#5c6068"),   # iron
    "c": hexc("#c8b48a"),   # canvas
}

SILVER_A = [
    "................",
    "................",
    "......k...k.....",
    ".....kGk.kGk....",
    "....kGsGkGsGk...",
    "..k.kGsGkGsGk...",
    ".kGkkgGskGsgk.k.",
    ".kGsGkgGsGgk.kGk",
    "..kGsGkgsgk.kGsk",
    "..kgGsGkgk.kGsGk",
    "...kggGkgkkGsgk.",
    "....kkgkgkgggk..",
    "......kgkgkkk...",
    ".......kgk......",
    "................",
    "................",
]
# Frame B: the same patch with the veins catching the light.
SILVER_B = [row.replace("s", "S", 1) if i in (4, 7, 9) else row for i, row in enumerate(SILVER_A)]

# A cart tipped on its side: the bed (planks) standing on end at left, one
# big spoked wheel up in the air, a broken shaft and a spilled crate.
CART = [
    "................",
    ".kkkk...........",
    ".kLWk....kkkk...",
    ".kLWk...kiWWik..",
    ".kLWk..kiWkkWik.",
    ".kLWk..kWkWWkWk.",
    ".kLWk..kWWkkWWk.",
    ".kLWk..kWkWWkWk.",
    ".kLWk..kiWkkWik.",
    ".kLWkk..kiWWik..",
    ".kLWkWk..kkkk...",
    ".kLWk.kWk.......",
    ".kLWk..kWk.kkkk.",
    ".kkkk...kk.kcck.",
    "...........kcwk.",
    "...........kkkk.",
]


def draw(grid: list) -> Image.Image:
    im = Image.new("RGBA", (16, 16))
    for y, row in enumerate(grid):
        assert len(row) == 16, (y, row)
        for x, ch in enumerate(row):
            im.putpixel((x, y), PALETTE[ch])
    return im


sheet = Image.new("RGBA", (48, 16))
for i, grid in enumerate([SILVER_A, SILVER_B, CART]):
    sheet.paste(draw(grid), (i * 16, 0))
sheet.save(HERE.parent / "quest_props.png")
print("wrote quest_props")
