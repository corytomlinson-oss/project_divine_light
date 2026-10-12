"""Battle backgrounds for Act I's four dungeons (Milestone 21), 320x180 each.

Same frame as the forest (build_battle_bg.py): the scene fills the top 112px
- a back wall down to the horizon at y=58, then a floor in perspective that
enemies and party stand on - and fades to near-black underneath, where the
battle windows sit. Built in layers with fixed seeds (same output every
run), dithered with a 4x4 Bayer matrix like the forest. Kept dark and muted
so the sprites read; the Observatory is a touch lighter so its dark boss
still stands out.

  battle_bg_cathedral.png    ruined nave, cracked stained glass, violet light
  battle_bg_monastery.png    training hall, paper screens, banners, cold brazier
  battle_bg_observatory.png  under the dome: ribs, cracks of starlight, the lens
  battle_bg_guild.png        brick tunnel, warm lamps, crates and barrels

Usage: python build_dungeon_battle_bgs.py <out_dir>
"""
import math
import os
import random
import sys

from PIL import Image

W, H = 320, 180
HORIZON = 58
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


class Scene:
    def __init__(self, seed):
        self.im = Image.new('RGB', (W, H))
        self.px = self.im.load()
        self.rng = random.Random(seed)

    def put(self, x, y, c):
        if 0 <= x < W and 0 <= y < H:
            self.px[x, y] = c

    def get(self, x, y):
        return self.px[x, y]

    def rect(self, x0, y0, x1, y1, c):
        for y in range(max(0, y0), min(H, y1 + 1)):
            for x in range(max(0, x0), min(W, x1 + 1)):
                self.px[x, y] = c

    def blend(self, x, y, a, b, t):
        """a toward b by t (0..1), ordered-dithered."""
        self.put(x, y, b if t * 16 > BAYER[y % 4][x % 4] + 0.5 else a)

    def vgrad(self, y0, y1, stops, x0=0, x1=W - 1):
        """Vertical gradient through a list of colors, dithered between them."""
        n = len(stops) - 1
        for y in range(y0, y1 + 1):
            t = (y - y0) / max(1, y1 - y0) * n
            i = min(int(t), n - 1)
            for x in range(x0, x1 + 1):
                self.blend(x, y, stops[i], stops[i + 1], t - i)

    def floor(self, y0, y1, base, line, rows=7, vlines=12, vx=160):
        """A floor in perspective: rows get taller toward the viewer, and
        joint lines run back to a vanishing point above the horizon."""
        self.vgrad(y0, y1, base)
        ys = [y0 + int((y1 - y0) * (k / rows) ** 1.7) for k in range(1, rows + 1)]
        for y in ys:
            for x in range(W):
                self.put(x, y, line)
        vy = y0 - 70
        for k in range(-vlines, vlines + 1):
            bx = vx + k * 46
            for y in range(y0, y1 + 1):
                t = (y - vy) / (y1 - vy)
                x = int(vx + (bx - vx) * t)
                self.put(x, y, line)

    def fade_out(self, y0=96, y1=118, dark=(10, 8, 14)):
        """Darken toward the bottom; solid below y1 (under the windows)."""
        for y in range(y0, H):
            t = min(1.0, (y - y0) / (y1 - y0))
            for x in range(W):
                if y >= y1:
                    self.px[x, y] = dark
                else:
                    self.blend(x, y, self.px[x, y], dark, t)

    def glow(self, cx, cy, r, color, strength=0.6):
        """A soft dithered pool of light."""
        for y in range(int(cy - r), int(cy + r) + 1):
            for x in range(int(cx - r), int(cx + r) + 1):
                d = math.hypot(x - cx, (y - cy) * 1.3)
                if d < r and 0 <= x < W and 0 <= y < H:
                    t = (1 - d / r) * strength
                    if t * 16 > BAYER[y % 4][x % 4] + 0.5:
                        self.px[x, y] = color

    def save(self, path):
        self.im.save(path)


# ================================================================ Cathedral

def cathedral():
    s = Scene(110)
    s.vgrad(0, HORIZON, [(18, 14, 26), (30, 26, 40), (44, 40, 56)])
    # ashlar back wall
    for y in range(0, HORIZON):
        if y % 10 == 0:
            for x in range(W):
                s.put(x, y, (24, 20, 32))
        for x in range((y // 10 % 2) * 12, W, 24):
            s.put(x, y, (24, 20, 32))
    # tall pointed windows of cracked stained glass
    glass = [(70, 40, 110), (110, 50, 70), (60, 70, 120), (130, 90, 150)]
    for wx in (52, 124, 196, 268):
        for y in range(6, 50):
            half = 9 if y > 18 else int(9 * math.sqrt(max(0.0, 1 - ((18 - y) / 12) ** 2)))
            for x in range(wx - half, wx + half + 1):
                cell = ((x - wx + 9) // 4 + (y // 5)) % len(glass)
                c = glass[cell]
                if (x - wx) % 4 == 0 or y % 5 == 0:
                    c = (20, 16, 26)                       # leading
                s.put(x, y, c)
        for k in range(14):                                # a crack across the glass
            s.put(wx - 6 + k, 22 + (k * 7) % 9, (210, 160, 250))
        s.glow(wx, 30, 22, (90, 60, 130), 0.35)
    # pillars between them
    for px_ in (16, 88, 160, 232, 304):
        s.rect(px_ - 7, 0, px_ + 7, HORIZON + 2, (52, 48, 64))
        s.rect(px_ - 7, 0, px_ - 5, HORIZON + 2, (74, 70, 88))
        s.rect(px_ + 5, 0, px_ + 7, HORIZON + 2, (34, 30, 44))
        s.rect(px_ - 9, HORIZON - 2, px_ + 9, HORIZON + 2, (40, 36, 52))
        for y in range(10, HORIZON, 13):                   # violet veins creeping up
            s.put(px_ + 2, y, (150, 80, 210))
            s.put(px_ + 3, y + 1, (110, 50, 160))
    s.floor(HORIZON, 112, [(54, 50, 64), (40, 36, 50), (28, 24, 36)], (22, 18, 30))
    for x, y in [(40, 80), (120, 96), (230, 74), (280, 102), (180, 88)]:
        for k in range(6):                                 # corruption seams in the flagstones
            s.put(x + k, y + (k % 2), (140, 70, 200))
    s.glow(160, 80, 70, (70, 40, 100), 0.25)
    s.fade_out()
    return s


# ================================================================ Monastery

def monastery():
    s = Scene(120)
    s.vgrad(0, HORIZON, [(40, 24, 18), (58, 36, 26), (70, 46, 32)])
    # paper screens between dark posts
    for x0 in range(0, W, 40):
        s.rect(x0 + 4, 8, x0 + 35, HORIZON - 6, (150, 132, 104))
        for gx in range(x0 + 4, x0 + 36, 8):
            s.rect(gx, 8, gx, HORIZON - 6, (70, 44, 30))
        for gy in range(8, HORIZON - 5, 10):
            s.rect(x0 + 4, gy, x0 + 35, gy, (70, 44, 30))
        s.rect(x0, 0, x0 + 3, HORIZON + 2, (52, 30, 22))   # post
    s.rect(0, 0, W - 1, 6, (52, 30, 22))                   # beam
    s.rect(0, 5, W - 1, 6, (84, 52, 34))
    for x, y in [(66, 20), (190, 34), (258, 16)]:          # torn screens, violet behind
        s.rect(x, y, x + 5, y + 4, (60, 28, 80))
        s.put(x + 2, y + 2, (170, 110, 230))
    # hanging red banners
    for bx in (44, 140, 236):
        s.rect(bx, 6, bx + 14, 44, (140, 40, 34))
        s.rect(bx, 6, bx + 1, 44, (170, 60, 46))
        s.rect(bx + 13, 6, bx + 14, 44, (100, 26, 24))
        for k in range(5):                                 # ragged hem
            s.rect(bx + k * 3, 45, bx + k * 3 + 1, 45 + (k % 2) * 2, (120, 32, 28))
        s.rect(bx + 4, 16, bx + 10, 22, (210, 170, 90))    # emblem
        s.rect(bx + 6, 18, bx + 8, 20, (140, 40, 34))
    s.floor(HORIZON, 112, [(86, 56, 36), (70, 44, 28), (52, 32, 22)], (40, 24, 16), rows=9, vlines=0)
    for y in range(HORIZON + 2, 112, 3):                   # board seams
        for x in range((y * 37) % 53, W, 53):
            s.put(x, y, (40, 24, 16))
    # a cold brazier on the right, ash and no fire
    s.rect(286, 42, 306, 46, (60, 56, 60))
    s.rect(290, 46, 302, 62, (44, 40, 46))
    s.rect(288, 40, 304, 41, (90, 86, 90))
    s.rect(291, 38, 301, 39, (120, 116, 118))
    s.glow(160, 70, 90, (90, 58, 36), 0.2)
    s.fade_out()
    return s


# ============================================================== Observatory

def observatory():
    s = Scene(130)
    s.vgrad(0, HORIZON, [(44, 52, 86), (56, 66, 104), (66, 78, 118)])
    # stone courses
    for y in range(0, HORIZON, 9):
        for x in range(W):
            s.put(x, y, (36, 42, 70))
    # three tall arched windows onto the night sky
    for wx, hw in ((56, 26), (160, 32), (264, 26)):
        top = 4
        for y in range(top, HORIZON - 4):
            r = hw
            half = hw if y > top + r else int(math.sqrt(max(0, r * r - (top + r - y) ** 2)))
            for x in range(wx - half, wx + half + 1):
                s.blend(x, y, (10, 10, 30), (22, 22, 52), (y - top) / (HORIZON - top))
            for x in (wx - half - 1, wx - half - 2, wx + half + 1, wx + half + 2):
                s.put(x, y, (200, 160, 80) if x in (wx - half - 1, wx + half + 1) else (120, 90, 44))
        for x in range(wx - hw - 2, wx + hw + 3):        # sill
            s.put(x, HORIZON - 4, (200, 160, 80))
            s.put(x, HORIZON - 3, (120, 90, 44))
        for k in range(18):                              # stars
            x = wx - hw + s.rng.randrange(2 * hw)
            y = top + 8 + s.rng.randrange(HORIZON - 20)
            s.put(x, y, (230, 232, 255) if k % 3 else (160, 180, 240))
        for y in range(top + 6, HORIZON - 4):            # mullion
            s.put(wx, y, (120, 90, 44))
    # a violet void crack spreading across the middle window
    for k in range(26):
        s.put(148 + k, 14 + (k * 5) % 7, (170, 100, 230))
    s.glow(170, 18, 10, (120, 80, 180), 0.5)
    # crescent moon in the left window
    for y in range(14, 24):
        for x in range(46, 58):
            if math.hypot(x - 52, y - 19) < 5 and math.hypot(x - 54, y - 18) >= 4:
                s.put(x, y, (226, 226, 240))
    # the great lens: a brass tube angled up to the right
    for k in range(80):
        cx = 200 + k
        cy = 54 - int(k * 0.55)
        for d in range(-6, 7):
            c = (180, 140, 70) if d > -4 else (226, 190, 110)
            if d > 3:
                c = (120, 90, 44)
            s.put(cx, cy + d, c)
    for k in (10, 40, 70):                                 # brass rings
        cx = 200 + k
        cy = 54 - int(k * 0.55)
        for d in range(-7, 8):
            s.put(cx, cy + d, (96, 70, 34))
    s.rect(196, 52, 216, 70, (60, 56, 80))                 # mount
    s.rect(198, 54, 214, 70, (80, 76, 104))
    s.glow(278, 12, 12, (200, 220, 255), 0.6)              # light caught in the lens
    s.floor(HORIZON, 112, [(58, 70, 110), (44, 54, 92), (32, 38, 70)], (26, 30, 56), rows=6, vlines=8)
    for k in range(120):                                   # a brass star-chart ring inlaid in the floor
        a = k / 120 * math.tau
        x = int(110 + math.cos(a) * 80)
        y = int(86 + math.sin(a) * 18)
        s.put(x, y, (190, 152, 80))
    for x, y in [(60, 80), (150, 92), (170, 76), (90, 100), (40, 94)]:
        s.put(x, y, (220, 190, 110))
    s.fade_out(dark=(12, 12, 26))
    return s


# ==================================================================== Guild

def guild():
    s = Scene(140)
    s.vgrad(0, HORIZON, [(16, 14, 14), (34, 26, 24), (48, 36, 32)])
    # brick vault
    for y in range(0, HORIZON):
        off = 5 if (y // 5) % 2 else 0
        for x in range(W):
            if y % 5 == 0 or (x + off) % 10 == 0:
                s.put(x, y, (22, 16, 16))
            elif (x * 7 + y * 13) % 29 == 0:
                s.put(x, y, (70, 46, 38))
    for x in range(W):                                     # the vault's curve, darker at the top
        top = int(18 - 18 * math.sin(math.pi * x / W))
        for y in range(0, top):
            s.put(x, y, (12, 10, 10))
    for x, y in [(30, 40), (90, 30), (210, 44), (290, 36), (150, 50)]:
        s.rect(x, y, x + 2, y + 1, (54, 96, 58))           # moss
    # wall lamps, warm light
    for lx in (70, 250):
        s.glow(lx, 26, 34, (110, 70, 34), 0.45)
        s.rect(lx - 2, 22, lx + 2, 30, (40, 34, 30))
        s.rect(lx - 1, 24, lx + 1, 28, (250, 190, 90))
        s.put(lx, 25, (255, 240, 180))
    # crates and barrels at the sides
    for x0, y0 in [(4, 34), (22, 42), (2, 48)]:
        s.rect(x0, y0, x0 + 16, y0 + 14, (96, 66, 40))
        s.rect(x0, y0, x0 + 16, y0, (130, 92, 56))
        s.rect(x0, y0 + 7, x0 + 16, y0 + 7, (66, 44, 28))
        s.rect(x0 + 8, y0, x0 + 8, y0 + 14, (66, 44, 28))
    for x0 in (284, 302):
        s.rect(x0, 38, x0 + 13, 60, (86, 58, 38))
        s.rect(x0, 42, x0 + 13, 43, (70, 72, 80))
        s.rect(x0, 54, x0 + 13, 55, (70, 72, 80))
        s.rect(x0 + 2, 38, x0 + 3, 60, (110, 76, 50))
    s.floor(HORIZON, 112, [(58, 62, 54), (44, 48, 42), (32, 34, 30)], (22, 24, 20), rows=8, vlines=14)
    for x, y in [(60, 76), (150, 96), (220, 82), (110, 70)]:   # puddles catching the lamps
        for k in range(12):
            s.put(x + k, y, (100, 96, 80) if k % 3 else (180, 150, 90))
    s.put(140, 88, (54, 96, 58))
    s.fade_out(dark=(10, 10, 10))
    return s


SCENES = {'cathedral': cathedral, 'monastery': monastery, 'observatory': observatory, 'guild': guild}

if __name__ == '__main__':
    out_dir = sys.argv[1]
    for name, build in SCENES.items():
        build().save(os.path.join(out_dir, 'battle_bg_%s.png' % name))
        print('battle_bg_%s.png' % name)
