"""Intro movie artwork (Milestone 19b), built in code like the battle background:
seeded, layered, ordered-dither gradients, every color from a small palette.

Writes to assets/movie/:
  intro_cosmos.png   320x180  the Light and the four pure souls orbiting it
  intro_valdris.png  480x180  Valdris at dawn (wide, panned left to right)
  intro_vorath.png   320x300  cracked violet sky above Vorath (tall, panned down)
  intro_four.png     320x180  the four heroes on a hill at sunset
  intro_title.png    320x180  quiet starfield behind the title card

The Unraveling shot reuses assets/ui/battle_bg_forest.png.

Usage: python build_intro.py [preview_dir]   (preview_dir: 2x copies to look at)
"""
import math
import os
import random
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..')
SPRITES = os.path.join(HERE, '..', '..', 'sprites')
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


class Canvas:
    def __init__(self, w, h, seed):
        self.w, self.h = w, h
        self.img = Image.new('RGB', (w, h))
        self.px = self.img.load()
        self.rng = random.Random(seed)

    def put(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.px[x, y] = c

    def get(self, x, y):
        return self.px[x, y]

    def dither(self, x, y, a, b, t):
        """a blending toward b by t (0..1), 4x4 ordered dither."""
        return b if t * 16 > BAYER[y % 4][x % 4] + 0.5 else a

    def gradient(self, y0, y1, stops):
        """Vertical gradient across `stops` (list of colors) from y0 to y1."""
        n = len(stops) - 1
        for y in range(y0, y1):
            f = (y - y0) / max(1, y1 - y0 - 1) * n
            i = min(int(f), n - 1)
            for x in range(self.w):
                self.put(x, y, self.dither(x, y, stops[i], stops[i + 1], f - i))

    def glow(self, cx, cy, radius, color, strength=1.0):
        """Soft dithered halo: blends toward `color`, strongest at the center."""
        for y in range(int(cy - radius), int(cy + radius) + 1):
            for x in range(int(cx - radius), int(cx + radius) + 1):
                if not (0 <= x < self.w and 0 <= y < self.h):
                    continue
                d = math.hypot(x - cx, y - cy) / radius
                if d >= 1:
                    continue
                t = (1 - d) ** 2 * strength
                self.put(x, y, self.dither(x, y, self.get(x, y), color, t))

    def disc(self, cx, cy, r, color):
        for y in range(int(cy - r), int(cy + r) + 1):
            for x in range(int(cx - r), int(cx + r) + 1):
                if math.hypot(x - cx, y - cy) <= r:
                    self.put(x, y, color)

    def stars(self, count, y_max=None, colors=((255, 255, 255), (190, 205, 255), (255, 230, 190))):
        y_max = y_max or self.h
        for _ in range(count):
            x, y = self.rng.randrange(self.w), self.rng.randrange(y_max)
            c = self.rng.choice(colors)
            dim = self.rng.uniform(0.35, 1.0)
            self.put(x, y, tuple(int(v * dim) for v in c))
        for _ in range(count // 14):
            x, y = self.rng.randrange(2, self.w - 2), self.rng.randrange(2, y_max - 2)
            c = self.rng.choice(colors)
            self.put(x, y, c)
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                self.put(x + dx, y + dy, tuple(v // 2 for v in c))

    def save(self, name, preview):
        self.img.save(os.path.join(OUT, name))
        if preview:
            self.img.resize((self.w * 2, self.h * 2), Image.NEAREST).save(os.path.join(preview, name))


# ------------------------------------------------------------------ cosmos
def cosmos(preview):
    c = Canvas(320, 180, 1901)
    c.gradient(0, 180, [(5, 4, 16), (14, 9, 34), (26, 12, 48)])
    # faint nebula clouds
    for _ in range(5):
        c.glow(c.rng.randrange(320), c.rng.randrange(180), c.rng.randrange(30, 60),
               c.rng.choice([(48, 26, 84), (26, 34, 78)]), 0.55)
    c.stars(150)
    cx, cy = 160, 84
    # dotted orbit of the four souls
    for i in range(160):
        a = 2 * math.pi * i / 160
        if i % 3:
            c.put(round(cx + 72 * math.cos(a)), round(cy + 24 * math.sin(a)), (70, 64, 110))
    # the Light
    c.glow(cx, cy, 40, (120, 100, 60), 0.9)
    c.glow(cx, cy, 20, (255, 236, 170), 0.9)
    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        for k in range(6, 18):
            c.put(cx + dx * k, cy + dy * k, c.dither(cx + dx * k, cy + dy * k, c.get(cx + dx * k, cy + dy * k), (255, 245, 210), 1 - k / 18))
    c.disc(cx, cy, 5, (255, 244, 214))
    c.disc(cx, cy, 3, (255, 255, 255))
    # the four souls: holy gold, ki blue, arcane violet, shadow emerald
    souls = [(255, 205, 90), (120, 200, 255), (175, 130, 255), (90, 220, 160)]
    for k, col in enumerate(souls):
        a = math.pi / 4 + k * math.pi / 2
        x, y = round(cx + 72 * math.cos(a)), round(cy + 24 * math.sin(a))
        c.glow(x, y, 9, col, 0.8)
        c.disc(x, y, 2, col)
        c.put(x, y, (255, 255, 255))
    c.save('intro_cosmos.png', preview)


# ------------------------------------------------------------------ valdris
def valdris(preview):
    W, H = 480, 180
    c = Canvas(W, H, 1902)
    HORIZON = 108
    c.gradient(0, HORIZON, [(22, 28, 66), (58, 52, 112), (150, 84, 124), (240, 150, 110), (252, 196, 128)])
    # the sun just clearing the peaks, so they stand in silhouette against it
    sun_x, sun_y = 330, 66
    c.glow(sun_x, sun_y, 64, (255, 214, 150), 0.75)
    c.disc(sun_x, sun_y, 14, (255, 236, 180))
    c.stars(40, y_max=40, colors=((220, 220, 255),))
    # thin pink cloud streaks
    for _ in range(14):
        y, x, ln = c.rng.randrange(30, 90), c.rng.randrange(-40, W), c.rng.randrange(30, 90)
        for dx in range(ln):
            if c.rng.random() < min(1, min(dx, ln - dx) / 8):
                c.put(x + dx, y, (230, 140, 150) if y > 60 else (140, 90, 140))
    # far mountains to the north, snow on the peaks
    h = 30.0
    peaks = []
    for x in range(W):
        h += c.rng.uniform(-2.2, 2.2)
        h = max(12, min(46, h))
        peaks.append(h)
    for x in range(W):
        top = HORIZON - int(peaks[x])
        for y in range(top, HORIZON + 24):  # runs on under the hills: no gap
            snow = y < top + max(0, (peaks[x] - 26) * 0.6)
            c.put(x, y, (236, 236, 250) if snow else c.dither(x, y, (86, 82, 132), (64, 60, 104), (y - top) / 40))
    # rolling green hills with a pine treeline
    for layer, (base, amp, col, tree) in enumerate([
            (120, 8, (58, 96, 82), (36, 66, 56)), (136, 10, (48, 110, 70), (28, 74, 48))]):
        phase = c.rng.uniform(0, 6)
        for x in range(W):
            top = int(base - amp * (0.6 * math.sin(x / 37 + phase) + 0.4 * math.sin(x / 13 + phase * 2)))
            for y in range(top, H):
                c.put(x, y, col)
            if (x + layer * 3) % 5 < 3:
                th = c.rng.randrange(3, 8)
                for k in range(th):
                    w = (th - k) // 3
                    for dx in range(-w, w + 1):
                        c.put(x + dx, top - k, tree)
    # the sea along the coast (right side), catching the sunrise
    for x in range(360, W):
        edge = 126 + int(4 * math.sin(x / 9))
        for y in range(HORIZON + 2, edge):
            col = c.dither(x, y, (70, 96, 158), (104, 132, 190), (y - HORIZON) / 20)
            if abs(x - sun_x) < 26 and (x * 7 + y * 3) % 11 == 0:
                col = (255, 214, 150)
            c.put(x, y, col)
    # a small castle town on a hill (Verdance) with lit windows
    tx, ty = 150, 124
    for bx, bw, bh in ((tx, 10, 14), (tx + 12, 7, 20), (tx + 21, 12, 12), (tx + 35, 6, 17)):
        for y in range(ty - bh, ty):
            for x in range(bx, bx + bw):
                c.put(x, y, (46, 40, 60))
        for k in range(bw // 2 + 1):
            for x in range(bx + k, bx + bw - k):
                c.put(x, ty - bh - k, (70, 44, 58))
        for y in range(ty - bh + 3, ty - 2, 4):
            c.put(bx + bw // 2, y, (255, 214, 120))
    # foreground meadow with tufts
    for x in range(W):
        top = 158 + int(3 * math.sin(x / 21))
        for y in range(top, H):
            c.put(x, y, c.dither(x, y, (44, 92, 52), (30, 64, 40), (y - top) / 22))
        if c.rng.random() < 0.35:
            c.put(x, top - 1, (70, 130, 70))
            if c.rng.random() < 0.4:
                c.put(x, top - 2, (70, 130, 70))
    c.save('intro_valdris.png', preview)


# ------------------------------------------------------------------ vorath
def vorath(preview):
    W, H = 320, 300
    c = Canvas(W, H, 1903)
    c.gradient(0, H, [(6, 3, 12), (18, 6, 28), (36, 10, 48), (20, 6, 30)])
    c.stars(30, y_max=120, colors=((150, 120, 190),))

    # cracks tearing across the sky, glowing violet
    def crack(x, y, angle, length, depth):
        for _ in range(length):
            c.glow(x, y, 4, (90, 36, 130), 0.5)
            c.put(round(x), round(y), (214, 120, 255))
            c.put(round(x) + 1, round(y), (150, 70, 210))
            # mostly straight runs with sharp kinks: fractures, not tendrils
            if c.rng.random() < 0.18:
                angle += c.rng.uniform(-0.7, 0.7)
            x += math.cos(angle) * 1.5
            y += math.sin(angle) * 1.5
            if depth > 0 and c.rng.random() < 0.04:
                crack(x, y, angle + c.rng.choice([-0.9, 0.9]), length // 2, depth - 1)
    for sx in (40, 130, 210, 290):
        crack(sx, 0, math.pi / 2 + c.rng.uniform(-0.6, 0.6), 60, 2)

    # Vorath: a towering hooded figure with a spiked crown, rim-lit violet
    cx = 160
    body = set()
    for y in range(176, H):
        # neck under the hood, then broad shoulders, then the robe flaring out
        half = 20 + (y - 176) * 0.25
        if y >= 204:
            half = max(half, 44 + (y - 204) * 0.4)
        elif y >= 196:
            half = max(half, 20 + (y - 196) * 3.0)
        for x in range(int(cx - half), int(cx + half) + 1):
            body.add((x, y))
    for y in range(150, 200):  # hood
        for x in range(cx - 26, cx + 27):
            if math.hypot((x - cx) / 26, (y - 184) / 34) < 1:
                body.add((x, y))
    for k, (ox, h) in enumerate(((-18, 14), (-9, 22), (0, 30), (9, 22), (18, 14))):  # crown
        for dy in range(h):
            w = max(0, (h - dy) // 5)
            for dx in range(-w, w + 1):
                body.add((cx + ox + dx, 156 - dy))
    for (x, y) in body:
        c.put(x, y, (10, 6, 16))
    for fx in (-30, -14, 12, 28):  # drapery folds down the robe
        for y in range(212, H):
            x = cx + fx + int((y - 212) * fx / 90)
            if (x, y) in body:
                c.put(x, y, (24, 12, 34))
    for (x, y) in body:  # rim light where the shape meets the sky
        if any((x + dx, y + dy) not in body for dx, dy in ((1, 0), (-1, 0), (0, -1))):
            c.put(x, y, (120, 56, 170) if y < 230 else (70, 32, 100))
    # the face: a void with two burning eyes
    for y in range(176, 200):
        for x in range(cx - 14, cx + 15):
            if math.hypot((x - cx) / 14, (y - 190) / 14) < 1:
                c.put(x, y, (4, 2, 8))
    for ex in (cx - 7, cx + 5):
        c.glow(ex + 1, 188, 7, (200, 60, 200), 0.8)
        for dx in range(3):
            c.put(ex + dx, 188, (255, 150, 235))
        c.put(ex + 1, 187, (255, 210, 245))
    # motes of the Unraveling drifting around him
    for _ in range(90):
        x, y = c.rng.randrange(W), c.rng.randrange(150, H)
        if (x, y) not in body:
            c.put(x, y, c.rng.choice([(160, 80, 216), (106, 44, 148), (216, 160, 255)]))
    c.save('intro_vorath.png', preview)


# ------------------------------------------------------------------ the four
def four(preview):
    c = Canvas(320, 180, 1905)
    HORIZON = 128
    c.gradient(0, HORIZON, [(34, 24, 64), (96, 46, 92), (196, 90, 88), (246, 150, 84)])
    c.glow(160, HORIZON, 90, (255, 170, 100), 0.6)
    c.disc(160, HORIZON - 2, 28, (255, 208, 128))
    for y in range(HORIZON - 16, HORIZON, 5):  # retro bands across the sun
        for x in range(128, 193):
            if c.get(x, y) == (255, 208, 128):
                c.put(x, y, (246, 150, 84))
    c.stars(25, y_max=40, colors=((230, 210, 255),))
    # distant land fading to grey on the right (the Unraveling spreading)
    for x in range(320):
        top = HORIZON - 6 - int(4 * math.sin(x / 17))
        grey = min(1.0, max(0.0, (x - 180) / 140))
        for y in range(top, 180):
            base = (70, 58, 86)
            col = tuple(int(b * (1 - grey) + g * grey) for b, g in zip(base, (70, 68, 74)))
            c.put(x, y, col)
    # the hill they stand on
    for x in range(320):
        top = int(134 + 30 * ((x - 160) / 170) ** 2)
        for y in range(top, 180):
            c.put(x, y, c.dither(x, y, (30, 20, 38), (16, 10, 22), (y - top) / 40))
        c.put(x, top, (80, 50, 70))
    # the four heroes (idle frames at 2x), rim-lit by the sunset
    for i, name in enumerate(['vael', 'ryn', 'lyra', 'silas']):
        sheet = Image.open(os.path.join(SPRITES, name + '_walk.png')).convert('RGBA')
        frame = sheet.crop((0, 0, 16, 32)).resize((32, 64), Image.NEAREST)
        x0 = 92 + i * 36
        c.img.paste(frame, (x0, 136 - 64), frame)
    c.px = c.img.load()
    c.save('intro_four.png', preview)


# ------------------------------------------------------------------ title
def title(preview):
    c = Canvas(320, 180, 1906)
    c.gradient(0, 180, [(4, 3, 10), (8, 6, 20), (20, 10, 38)])
    c.stars(110)
    for x in range(320):  # a faint band of light along the bottom
        for y in range(150, 180):
            t = (y - 150) / 30 * (0.5 + 0.5 * math.sin(x / 40))
            c.put(x, y, c.dither(x, y, c.get(x, y), (60, 30, 90), t * 0.8))
    c.save('intro_title.png', preview)


if __name__ == '__main__':
    preview = sys.argv[1] if len(sys.argv) > 1 else None
    if preview:
        os.makedirs(preview, exist_ok=True)
    for fn in (cosmos, valdris, vorath, four, title):
        fn(preview)
        print(fn.__name__, 'done')
