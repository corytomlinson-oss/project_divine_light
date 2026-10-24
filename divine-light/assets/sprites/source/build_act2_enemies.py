"""Act II stand-in enemy sprites (Milestone 25b): recolors of existing
hand-placed enemies, so every new enemy has its own file and name until the
Act II art pass (Milestone 27) draws them properly.

Each recolor maps every color's lightness onto a new ramp (keeping the
outline black-violet and keeping glow pixels as glow), so the shading of
the original survives.

    python build_act2_enemies.py      (from this folder)
"""
import colorsys
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
ENEMIES = HERE.parent / "enemies"
OUTLINE = (26, 20, 32)
GLOWS = {(170, 80, 220), (220, 150, 255)}  # the Unraveling's violet glow, kept


def ramp_recolor(src, dst, dark, light, glow=None, sat_keep=0.25):
    """Every opaque pixel's lightness picks a color between `dark` and
    `light` (RGB); a little of the original saturation/hue survives."""
    im = Image.open(ENEMIES / f"{src}.png").convert("RGBA")
    out = []
    for r, g, b, a in im.getdata():
        if a == 0 or (r, g, b) == OUTLINE:
            out.append((r, g, b, a))
            continue
        if (r, g, b) in GLOWS or (r > 160 and b > 200 and g < 160):
            gc = glow or (r, g, b)
            out.append(gc + (a,))
            continue
        h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
        t = min(1.0, max(0.0, (l - 0.08) / 0.8))
        base = tuple(dark[i] + (light[i] - dark[i]) * t for i in range(3))
        orig = (r, g, b)
        mixed = tuple(int(base[i] * (1 - sat_keep * s) + orig[i] * sat_keep * s) for i in range(3))
        out.append(mixed + (a,))
    im.putdata(out)
    im.save(ENEMIES / f"{dst}.png")
    print("wrote", dst, im.size)


ICE_DARK, ICE_LIGHT = (36, 60, 104), (214, 236, 252)
# The Northern Tundra (README "Tundra Kingdom")
ramp_recolor("shade_wisp", "frost_wraith", (40, 72, 120), (230, 246, 255), glow=(150, 220, 255))
ramp_recolor("cursed_paladin", "corrupted_knight", (28, 26, 40), (150, 140, 170))
ramp_recolor("hired_muscle", "tundra_troll", (50, 64, 80), (170, 196, 206))
ramp_recolor("astral_familiar", "blizzard_hawk", (70, 84, 110), (245, 248, 255), glow=(120, 200, 255))
# The Frozen Citadel's guard, boss and the boss's summoned knights
ramp_recolor("cursed_paladin", "frost_warden", ICE_DARK, ICE_LIGHT, glow=(140, 220, 255))
ramp_recolor("iron_sentinel", "ice_knight", (44, 70, 110), (200, 228, 250), glow=(140, 220, 255))
ramp_recolor("fallen_guardian", "frozen_sovereign", (30, 46, 92), (226, 242, 255), glow=(120, 210, 255))

# The Duskara Wastes (25c; README "Desert Kingdom")
SAND_DARK, SAND_LIGHT = (92, 60, 34), (236, 204, 146)
ramp_recolor("iron_sentinel", "dust_golem", (96, 70, 44), (220, 186, 130))
ramp_recolor("void_mage", "scorched_mage", (90, 26, 20), (255, 178, 96), glow=(255, 150, 40))
ramp_recolor("shadow_thief", "dune_marauder", SAND_DARK, SAND_LIGHT)
# The Sunken Sanctum's guard and boss
ramp_recolor("hired_muscle", "blazing_sentinel", (110, 30, 16), (255, 196, 96), glow=(255, 120, 30))
ramp_recolor("void_archmage", "burning_tyrant", (80, 20, 16), (255, 170, 80), glow=(255, 210, 90))

# The Sand Viper: a coiled snake, hand-placed (no Act I enemy reads as one).
SNAKE = [
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "........................",
    "..............kkkk......",
    ".............kGGGGk.....",
    "............kGYGGYGk....",
    "............kGGGGGGk....",
    ".............kGGGGk.....",
    "..............kGGkr.....",
    "..............kGGk.r....",
    ".............kGGgk......",
    "............kGGgk.......",
    "......kkkkkkGGgk........",
    ".....kGGGGGGGGgkkkkk....",
    "....kGgggggGGGGGGGGGk...",
    "....kGkkkkkgggggggGGk...",
    "...kGgk....kkkkkkkgGk...",
    "...kGk..kkkkkkkk..kGk...",
    "...kGgkkGGGGGGGGkkgGk...",
    "....kGGGGggggggGGGGk....",
    ".....kkgggggggggggk.....",
    ".......kkkkkkkkkkk......",
    "........................",
    "........................",
    "........................",
]
PAL = {".": (0, 0, 0, 0), "k": (26, 20, 32, 255), "G": (176, 156, 70, 255), "g": (128, 104, 44, 255),
       "Y": (255, 230, 90, 255), "r": (200, 40, 50, 255)}
frames = []
for shift in (0, 1):
    im = Image.new("RGBA", (24, 32))
    for y, row in enumerate(SNAKE):
        for x, ch in enumerate(row):
            yy = y - shift if y < 19 else y  # the head bobs on frame 2
            if 0 <= yy < 32 and ch != ".":
                im.putpixel((x, yy), PAL[ch])
    frames.append(im)
sheet = Image.new("RGBA", (48, 32))
sheet.paste(frames[0], (0, 0))
sheet.paste(frames[1], (24, 0))
sheet.save(ENEMIES / "sand_viper.png")
print("wrote sand_viper", sheet.size)

# The Selavon Coast (25d; README "Coastal Kingdom")
ramp_recolor("shade_wisp", "sea_specter", (20, 70, 80), (170, 240, 230), glow=(140, 255, 220))
ramp_recolor("hired_muscle", "coral_brute", (110, 50, 60), (250, 160, 150))
ramp_recolor("void_mage", "tidal_witch", (20, 60, 80), (120, 220, 220), glow=(140, 255, 240))
ramp_recolor("astral_familiar", "storm_gull", (60, 66, 80), (236, 238, 244), glow=(255, 230, 90))
# The Drowned Fortress's guard and boss
ramp_recolor("corrupted_enforcer", "first_mate", (20, 30, 60), (140, 170, 210), glow=(255, 240, 120))
ramp_recolor("shadow_lord", "drowned_admiral", (14, 40, 50), (120, 200, 190), glow=(255, 240, 120))
