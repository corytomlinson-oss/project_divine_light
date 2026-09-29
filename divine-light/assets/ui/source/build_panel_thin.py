"""Thin window frame for the battle windows (Milestone 17b), 16x16 9-slice.

Same stone-and-gold palette as the heavier panel_frame.png (build_panel.py),
cut down to a 4px border so windows fit the 180px screen: outline, bevel
(light top/left, dark bottom/right), stone, inner outline, then an
opaque dark fill so text reads over anything behind it. Gold 2x2
studs sit in the corners. Used as the theme's default Panel/PanelContainer
style (assets/ui/theme.tres) with 4px texture margins.

Output: assets/ui/panel_thin.png
"""
import os

from PIL import Image

SIZE = 16
OUTLINE = (15, 12, 22, 255)
BASE = (52, 46, 72, 255)
HIGHLIGHT = (158, 146, 190, 255)
SHADOW = (22, 18, 32, 255)
GOLD = (196, 162, 88, 255)
FILL = (16, 14, 30, 255)

img = Image.new('RGBA', (SIZE, SIZE))
px = img.load()
for y in range(SIZE):
    for x in range(SIZE):
        e = min(x, y, SIZE - 1 - x, SIZE - 1 - y)
        if e == 0:
            px[x, y] = OUTLINE
        elif e == 1:
            px[x, y] = HIGHLIGHT if (x == e or y == e) else SHADOW
        elif e == 2:
            px[x, y] = BASE
        elif e == 3:
            px[x, y] = OUTLINE
        else:
            px[x, y] = FILL
for cx, cy in [(1, 1), (SIZE - 3, 1), (1, SIZE - 3), (SIZE - 3, SIZE - 3)]:
    for dx in range(2):
        for dy in range(2):
            px[cx + dx, cy + dy] = GOLD

img.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'panel_thin.png'))
