"""Overworld battle background: a corrupted forest clearing at dusk, 320x180.

Too big to hand-place pixel by pixel like the sprites, so this builds it in
layers with a fixed seed (same output every run): dithered sky -> moon ->
far pine treeline -> mist -> clearing ground with moss, tufts and corruption
veins -> dead framing trees -> dark undergrowth. Every color comes from PAL.

The scene lives in the top 72px (the enemy panel band). Below that the battle
UI draws white text straight over the background (the panels have transparent
centers), so y >= 72 fades to near-black undergrowth to keep text readable.
Enemies stand on y=61, so the clearing floor is kept calm around that line.

Usage: python build_battle_bg.py <out.png>
"""
import math
import random
import sys

from PIL import Image

W, H = 320, 180
SEED = 1790

PAL = {
    # sky, top to horizon
    's0': (20, 15, 36), 's1': (29, 22, 49), 's2': (42, 28, 60), 's3': (58, 35, 70),
    's4': (78, 42, 76), 's5': (102, 52, 78), 's6': (126, 68, 80),
    'cloud': (66, 40, 78),
    # moon
    'moon': (216, 208, 192), 'moon2': (168, 156, 176), 'halo': (72, 46, 96),
    # trees
    'far': (35, 26, 51), 'far_rim': (48, 36, 66), 'mist': (74, 56, 96),
    'tree': (23, 17, 31), 'tree2': (34, 26, 44),
    # ground
    'g_hz': (58, 50, 58), 'g1': (46, 42, 46), 'g2': (38, 34, 40), 'g3': (30, 27, 34),
    'moss': (44, 54, 40), 'moss2': (62, 76, 50),
    # corruption
    'v': (106, 44, 148), 'V': (160, 80, 216), 'X': (216, 160, 255),
    # undergrowth
    'd0': (18, 14, 22), 'd1': (12, 10, 16),
}

BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]

img = Image.new('RGB', (W, H))
px = img.load()
rng = random.Random(SEED)


def put(x, y, key):
    if 0 <= x < W and 0 <= y < H:
        px[x, y] = PAL[key]


def dither(x, y, a, b, t):
    """Color a blending toward b by t (0..1) with 4x4 ordered dither."""
    return b if t * 16 > BAYER[y % 4][x % 4] + 0.5 else a


# ---------------------------------------------------------------- sky
HORIZON = 44
SKY = ['s0', 's1', 's2', 's3', 's4', 's5', 's6']
for y in range(HORIZON):
    f = (y / (HORIZON - 1)) ** 1.35 * (len(SKY) - 1)
    i = min(int(f), len(SKY) - 2)
    for x in range(W):
        put(x, y, dither(x, y, SKY[i], SKY[i + 1], f - i))

# thin cloud streaks
for _ in range(9):
    cy = rng.randint(14, 32)
    cx = rng.randint(-20, W)
    length = rng.randint(18, 50)
    for dx in range(length):
        edge = min(dx, length - dx) / 6
        if rng.random() < min(1, edge):
            put(cx + dx, cy, 'cloud')
            if rng.random() < 0.35 * min(1, edge):
                put(cx + dx + 2, cy + 1, 'cloud')

# ---------------------------------------------------------------- moon
MX, MY, MR = 287, 11, 6
for y in range(MY - 12, MY + 13):
    for x in range(MX - 12, MX + 13):
        d = math.hypot(x - MX, y - MY)
        if d <= MR:
            crater = (x - MX + 2) ** 2 + (y - MY + 1) ** 2 < 4 or (x - MX - 2) ** 2 + (y - MY - 3) ** 2 < 2
            put(x, y, 'moon2' if crater or x - MX > 3 else 'moon')
        elif d <= 11 and (BAYER[y % 4][x % 4] < (11 - d) * 3):
            put(x, y, 'halo')

# ---------------------------------------------------------------- far treeline
far_top = [HORIZON + 2] * W
x = -4
while x < W + 4:
    h = rng.randint(7, 15)
    half = max(2, h // 2 - 1)
    for dy in range(h):
        # tiered pine: width grows downward, with a notch every 3 rows
        wdt = int((dy + 1) / h * half) - (1 if dy % 3 == 0 and dy > 2 else 0)
        for dx in range(-wdt, wdt + 1):
            xx, yy = x + dx, HORIZON + 2 - h + dy
            if 0 <= xx < W:
                far_top[xx] = min(far_top[xx], yy)
    x += rng.randint(4, 8)
for x in range(W):
    for y in range(far_top[x], HORIZON + 4):
        put(x, y, 'far')
    put(x, far_top[x], 'far_rim' if x % 3 else 'far')

# ---------------------------------------------------------------- ground
GROUND_END = 72
for y in range(HORIZON + 3, H):
    for x in range(W):
        if y < GROUND_END:
            t = (y - (HORIZON + 3)) / (GROUND_END - HORIZON - 3)
            if t < 0.25:
                c = dither(x, y, 'g_hz', 'g1', t / 0.25)
            elif t < 0.7:
                c = dither(x, y, 'g1', 'g2', (t - 0.25) / 0.45)
            else:
                c = dither(x, y, 'g2', 'g3', (t - 0.7) / 0.3)
        else:
            t = min(1, (y - GROUND_END) / 30)
            c = dither(x, y, 'g3', 'd0', t) if t < 1 else dither(x, y, 'd0', 'd1', min(1, (y - GROUND_END - 30) / 50))
        put(x, y, c)

# mist over the treeline foot
for y in range(HORIZON - 4, HORIZON + 6):
    strength = 1 - abs(y - (HORIZON + 1)) / 6
    for x in range(W):
        wave = 0.5 + 0.5 * math.sin(x / 23.0 + y * 0.7)
        if BAYER[y % 4][x % 4] < strength * wave * 9:
            put(x, y, 'mist')

# moss patches (blobby, denser toward the front)
for _ in range(38):
    cx, cy = rng.randint(0, W), rng.randint(HORIZON + 5, GROUND_END + 6)
    rx, ry = rng.randint(4, 14), rng.randint(1, 3)
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
            if d < 1 and BAYER[y % 4][x % 4] < (1 - d) * 22:
                put(x, y, 'moss')

# grass tufts
for _ in range(90):
    x, y = rng.randint(0, W - 1), rng.randint(HORIZON + 6, GROUND_END + 4)
    shade = 'moss2' if y < GROUND_END else 'moss'
    put(x, y, shade)
    put(x - 1, y + 1, shade)
    put(x + 1, y + 1, shade)
    if rng.random() < 0.5:
        put(x, y - 1, shade)

# corruption veins: glowing cracks wandering across the clearing
for _ in range(6):
    x, y = rng.randint(0, W), rng.randint(HORIZON + 8, GROUND_END + 8)
    for step in range(rng.randint(14, 34)):
        put(x, y, 'V' if step % 5 else 'X')
        put(x, y + 1, 'v')
        x += rng.choice([1, 1, 1, 2])
        y += rng.choice([-1, 0, 0, 1])

# ---------------------------------------------------------------- dead trees
def dead_tree(base_x, top_y, trunk_w, branches, cracks):
    """Twisted, tapering trunk from below the scene band up to top_y."""
    sway = 0.0
    ys = range(GROUND_END + 10, top_y - 1, -1)
    span = len(ys)
    centers = {}
    for i, y in enumerate(ys):
        sway += rng.uniform(-0.45, 0.45)
        sway = max(-3, min(3, sway))
        taper = 1 - i / span
        w = max(2, round(trunk_w * (0.45 + 0.55 * taper)))
        if y > GROUND_END - 5:
            w += (y - (GROUND_END - 5)) // 2 + 1  # root flare
        x0 = round(base_x + sway - w / 2)
        centers[y] = x0 + w // 2
        for x in range(x0, x0 + w):
            put(x, y, 'tree')
        put(x0, y, 'tree2')                       # bark catching the dusk light
        if w > 4 and (y * 7 + x0) % 9 == 0:
            put(x0 + 2, y, 'tree2')               # knots
    # a few glowing cracks, short vertical runs at irregular heights
    for _ in range(cracks):
        y = rng.randint(top_y + 8, GROUND_END - 4)
        cx = centers[y] + rng.choice([-1, 0, 1])
        for k in range(rng.randint(2, 4)):
            put(cx, y + k, 'V' if k else 'X')
            put(cx + 1, y + k, 'v')
    # branches: jagged, thinning lines reaching up and out
    for (by, direction, length) in branches:
        x, y = centers.get(by, base_x), by
        for i in range(length):
            x += direction
            if rng.random() < 0.45:
                y -= 1
            put(x, y, 'tree')
            if i < length // 3:
                put(x, y + 1, 'tree')
                put(x, y - 1, 'tree2')
            if rng.random() < 0.14:  # twig
                put(x, y - 1, 'tree')
                put(x + direction, y - 2, 'tree')


dead_tree(305, 0, 13, [(20, -1, 38), (36, -1, 24), (12, 1, 10), (50, -1, 14), (28, 1, 8)], 4)
dead_tree(112, 16, 6, [(30, -1, 12), (24, 1, 14), (40, 1, 8)], 2)
dead_tree(216, 26, 4, [(36, 1, 10), (42, -1, 8)], 1)

# hanging wisps of corruption drifting in the air (sparse motes)
for _ in range(26):
    x, y = rng.randint(0, W - 1), rng.randint(20, GROUND_END + 20)
    put(x, y, rng.choice(['V', 'X', 'v']))

# ---------------------------------------------------------------- undergrowth
# dark bush silhouettes along the bottom of the scene band, fading into the
# near-black under the UI
for _ in range(26):
    cx, cy = rng.randint(-10, W + 10), rng.randint(GROUND_END + 3, GROUND_END + 22)
    r = rng.randint(4, 9)
    # ragged top edge: each column gets its own leafy height
    for x in range(cx - r - 4, cx + r + 5):
        u = (x - cx) / (r + 4)
        if abs(u) >= 1:
            continue
        top = cy - int(r * math.sqrt(1 - u * u)) + rng.choice([0, 0, 1, -1, 2])
        for y in range(top, cy + r):
            put(x, y, 'tree')
        if rng.random() < 0.55:
            put(x, top, 'tree2')                  # leaf edges catching light
        if rng.random() < 0.2:
            put(x, top - 1, 'tree')               # stray leaves
# roots curling through the dark
for _ in range(12):
    x, y = rng.randint(0, W), rng.randint(GROUND_END + 20, H - 4)
    for _step in range(rng.randint(10, 26)):
        put(x, y, 'd0')
        put(x, y - 1, 'tree')
        x += rng.choice([-1, 1, 1, 2])
        y += rng.choice([0, 0, 1])

if __name__ == '__main__':
    img.save(sys.argv[1])
