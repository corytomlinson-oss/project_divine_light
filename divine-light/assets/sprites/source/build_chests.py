"""Treasure chests (Milestone 23a), hand-placed like the character sheets.

One 16x16 frame per state, left to right:
  0 wooden closed   1 wooden open    (plain chests: random loot)
  2 gilded closed   3 gilded open    (set pieces: navy lacquer, gold bands)
  4 mimic closed     (a wooden chest, but two teeth poke out of the seam -
                      a tell for sharp eyes; opened, it's frame 1)
  5 locked closed    (a heavy padlock only Silas can pick; opened, frame 1)

Usage: python build_chests.py <out.png> [preview.png]
"""
import sys
from PIL import Image

PAL = {
    '.': None,
    'K': (26, 20, 32, 255),     # outline
    's': (0, 0, 0, 70),         # ground shadow
    'k': (34, 22, 18, 255),     # dark interior
    'Y': (255, 232, 140, 255),  # lock highlight
    'g': (170, 120, 40, 255),   # lock shadow
    'T': (240, 236, 220, 255),  # mimic tooth
}
WOOD = {
    'l': (190, 132, 76, 255),   # lid top / front highlight
    'o': (146, 94, 52, 255),    # body
    'w': (96, 58, 34, 255),     # shade
    'S': (150, 158, 178, 255),  # iron band
    'D': (78, 84, 104, 255),    # iron band in shade
    'L': (176, 184, 200, 255),  # padlock
}
GILDED = {
    'l': (98, 122, 204, 255),
    'o': (58, 76, 152, 255),
    'w': (34, 42, 94, 255),
    'S': (236, 192, 76, 255),   # gold band
    'D': (170, 120, 40, 255),
}


def body(i):
    """Front of the chest, rows 9-15 (same open or closed)."""
    return [
        '.K' + ('llSllYYllSll' if i == 0 else 'llSllllllSll') + 'K.',
        '.K' + ('ooSooggooSoo' if i == 0 else 'ooSooooooSoo') + 'K.',
        '.K' + 'ooSooooooSoo' + 'K.',
        '.K' + 'ooSooooooSoo' + 'K.',
        '.K' + 'wwDwwwwwwDww' + 'K.',
        '.KKKKKKKKKKKKKK.',
        '..ssssssssssss..',
    ]


CLOSED = [
    '................',
    '................',
    '................',
    '..KKKKKKKKKKKK..',
    '.K' + 'llSllllllSll' + 'K.',
    '.K' + 'ooSooooooSoo' + 'K.',
    '.K' + 'ooSooooooSoo' + 'K.',
    '.K' + 'wwDwwwwwwDww' + 'K.',
    '.KKKKKKYYKKKKKK.',
] + body(0)

OPEN = [
    '................',
    '..KKKKKKKKKKKK..',
    '.K' + 'wwDwwwwwwDww' + 'K.',
    '.K' + 'wwDwwwwwwDww' + 'K.',
    '.K' + 'wwDwwwwwwDww' + 'K.',
    '.KKKKKKKKKKKKKK.',
    '.K' + 'kkkkkkkkkkkk' + 'K.',
    '.K' + 'kkkkkkkkkkkk' + 'K.',
    '.KKKKKKKKKKKKKK.',
] + body(1)


MIMIC = CLOSED[:8] + ['.KKTKKKYYKKKTKK.'] + CLOSED[9:]

LOCKED = CLOSED[:6] + [
    '.K' + 'ooSooLLooSoo' + 'K.',
    '.K' + 'wwDwLwwLwDww' + 'K.',
    '.KKKKKLLLLKKKKK.',
    '.K' + 'llSlLLLLlSll' + 'K.',
    '.K' + 'ooSoLKKLoSoo' + 'K.',
    '.K' + 'ooSoDLLDoSoo' + 'K.',
] + CLOSED[12:]


def frame(rows, colors):
    pal = dict(PAL, **colors)
    assert len(rows) == 16, len(rows)
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        assert len(row) == 16, (y, len(row), row)
        for x, ch in enumerate(row):
            if pal[ch]:
                im.putpixel((x, y), pal[ch])
    return im


def main():
    frames = [(CLOSED, WOOD), (OPEN, WOOD), (CLOSED, GILDED), (OPEN, GILDED), (MIMIC, WOOD), (LOCKED, WOOD)]
    out = Image.new('RGBA', (16 * len(frames), 16), (0, 0, 0, 0))
    for i, (rows, colors) in enumerate(frames):
        out.paste(frame(rows, colors), (i * 16, 0))
    out.save(sys.argv[1])
    if len(sys.argv) > 2:
        out.resize((out.width * 8, out.height * 8), Image.NEAREST).save(sys.argv[2])


if __name__ == '__main__':
    main()
