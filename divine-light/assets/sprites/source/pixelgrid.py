"""Shared helpers for the hand-placed character sprite generators.

Every character sheet uses the same layout as Vael's (build_vael_walk.py):
16x32 frames, rows down / up / right, columns idle / stepA / stepB. Left is
the right row drawn with flip_h in Godot, so there's no left row.
"""
from PIL import Image

# Colors every character shares. Each generator adds its own on top.
BASE = {
    '.': None,
    'K': (26, 20, 32),     # outline
    'F': (236, 188, 148),  # skin
    'f': (196, 140, 104),  # skin shadow
    'D': (72, 80, 104),    # steel dark
    'S': (138, 147, 168),  # steel mid
    'L': (200, 208, 220),  # steel light
    'W': (244, 246, 250),  # highlight
}

POSES = ['idle', 'stepA', 'stepB']


def frame(rows, pal):
    assert len(rows) == 32, len(rows)
    im = Image.new('RGBA', (16, 32), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        assert len(row) == 16, (y, len(row), row)
        for x, ch in enumerate(row):
            if pal[ch]:
                im.putpixel((x, y), pal[ch] + (255,))
    return im


def sheet(views, pal):
    """views: [(name, top_rows, legs_by_pose)] where top_rows is rows 0-24."""
    out = Image.new('RGBA', (16 * len(POSES), 32 * len(views)), (0, 0, 0, 0))
    for r, (name, top, legs) in enumerate(views):
        for c, pose in enumerate(POSES):
            try:
                out.paste(frame(top + legs[pose], pal), (c * 16, r * 32))
            except AssertionError as e:
                raise SystemExit(f'{name}/{pose}: {e}')
    return out


def main(views, pal):
    import sys
    s = sheet(views, pal)
    s.save(sys.argv[1])
    if len(sys.argv) > 2:
        s.resize((s.width * 8, s.height * 8), Image.NEAREST).save(sys.argv[2])
