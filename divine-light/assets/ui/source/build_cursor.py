"""Menu cursor: a small FF-style pointing glove, hand-placed pixel by pixel.

8x7, sized to sit in the two-space indent (10px) in front of an m5x7 menu
label and to match its 7px capital height. Output: assets/ui/cursor.png.

Usage: python build_cursor.py [preview.png]   (preview = 8x zoom on a dark bg)
"""
import os
import sys

from PIL import Image

PAL = {
    '.': None,
    'K': (26, 20, 32),     # outline (same as the character sprites)
    'W': (244, 246, 250),  # glove
    'G': (170, 176, 196),  # glove shadow
}

ROWS = [
    '.KKKK...',
    'KWWWWKKK',
    'KWWWWWWK',
    'KWWWKKK.',
    'KGWWWWK.',
    'KGGGGK..',
    '.KKKK...',
]


def build():
    im = Image.new('RGBA', (len(ROWS[0]), len(ROWS)), (0, 0, 0, 0))
    for y, row in enumerate(ROWS):
        assert len(row) == len(ROWS[0]), (y, row)
        for x, ch in enumerate(row):
            if PAL[ch]:
                im.putpixel((x, y), PAL[ch] + (255,))
    return im


if __name__ == '__main__':
    here = os.path.dirname(os.path.abspath(__file__))
    cursor = build()
    cursor.save(os.path.join(here, '..', 'cursor.png'))
    if len(sys.argv) > 1:
        bg = Image.new('RGBA', (cursor.width + 4, cursor.height + 4), (18, 16, 36, 255))
        bg.alpha_composite(cursor, (2, 2))
        bg.resize((bg.width * 8, bg.height * 8), Image.NEAREST).save(sys.argv[1])
