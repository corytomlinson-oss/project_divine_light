"""Silas walk-cycle frames, hand-placed (see pixelgrid.py for the sheet layout).

Usage: python build_silas_walk.py <sheet.png> [preview_x8.png]
"""
from pixelgrid import BASE, main

PAL = dict(BASE, **{
    'H': (58, 52, 72), 'h': (88, 80, 106), 'j': (34, 30, 44),  # hood / cloak
    'f': (40, 32, 36),                           # face in hood shadow
    'y': (220, 240, 255),                        # eye glint
    'M': (52, 104, 72), 'm': (32, 68, 48),       # scarf
    'A': (104, 78, 62), 'a': (66, 50, 44),       # leathers
    'N': (140, 96, 58),                          # strap / belt
})

# A dagger in each hand, points down.
DOWN = [
    "................",
    "......KKKK......",
    "....KKhhHHKK....",
    "...KhhHHHHHjK...",
    "..KhhHHHHHHHjK..",
    "..KhHHHHHHHjjK..",
    "..KhHKKKKKKjjK..",
    "..KhKfffffffKK..",
    "..KhKfyKKyfKjK..",
    "..KhKMMMMMMMKjK.",
    "..KhHMMMMMmmHjK.",
    "..KhHHKMMmKHjjK.",
    ".KhhHKAAAAKHjjjK",
    ".KhAAKNAAAKAAjjK",
    "KhAAKANAAAAKAajK",
    "KhAAKAANNAAKAajK",
    "KhAAKAAAANAKAajK",
    "KhAAKAAAAANKAajK",
    "KhFfKNNSNNNKfFjK",
    "KhSLKAAAAAAKLSjK",
    ".KLSKAAAAaaKSLK.",
    ".KWKKAAKAaaKKWK.",
    ".KWK.KAAKaaK.WK.",
    ".KK..KAAKAaK.KK.",
    ".....KAAKAaK....",
]
DOWN_LEGS = {
    'idle': [
        ".....KAAKAaK....",
        ".....KAAKAaK....",
        ".....KaaKaaK....",
        ".....KDDKDDK....",
        "....KDDDKDDDK...",
        "....KKKKKKKKK...",
        "................",
    ],
    'stepA': [
        ".....KAAKAaK....",
        ".....KAAKaaK....",
        ".....KaaKDDK....",
        ".....KaaKDDDK...",
        ".....KDDKKKKK...",
        "....KDDDK.......",
        "....KKKKK.......",
    ],
    'stepB': [
        ".....KAAKAaK....",
        ".....KaaKAaK....",
        ".....KDDKaaK....",
        "....KDDDKaaK....",
        "....KKKKKDDK....",
        "........KDDDK...",
        "........KKKKK...",
    ],
}

# Hood from behind, cloak hanging down his back to a point.
UP = [
    "................",
    "......KKKK......",
    "....KKhhHHKK....",
    "...KhhHHHHHjK...",
    "..KhhHHHHHHHjK..",
    "..KhHHHHHHHjjK..",
    "..KhHHHHHHHjjK..",
    "..KhHHHHHHHjjK..",
    "..KhHHHHHHHjjK..",
    "..KhHHHHHHHjjK..",
    "..KhHHHHHHHjjK..",
    "..KjjjjjjjjjjK..",
    ".KhhHHHHHHHHjjjK",
    ".KhAAKhHHHKAAjjK",
    "KhAAKhHHHHjKAajK",
    "KhAAKhHHHHjKAajK",
    "KhAAKhHHHHjKAajK",
    "KhAAKhHHHHjKAajK",
    "KhFfKhHHHHjKfFjK",
    "KhSLKhHHHHjKLSjK",
    ".KLSKKhHHjKKSLK.",
    ".KWKKAKhjKaKKWK.",
    ".KWK.KAKKaaK.WK.",
    ".KK..KAAKAaK.KK.",
    ".....KAAKAaK....",
]

# Facing right: cloak trails behind, near hand holds a dagger point-down.
RIGHT = [
    "................",
    ".....KKKK.......",
    "...KKhHHHKK.....",
    "..KhHHHHHHHK....",
    ".KhHHHHHHHHjK...",
    ".KhHHHHHHHHjK...",
    ".KhHHHHHKKKKK...",
    ".KhHHHHKfffK....",
    ".KhHHHHKfyfK....",
    ".KhHHHHKMMMK....",
    ".KhHHHHHMMmK....",
    ".KhHHHHKMmKK....",
    "..KhHKAAAAAK....",
    ".KhHKAKAAKAK....",
    ".KhHKAKAAKAK....",
    ".KhHKAKAaKaK....",
    ".KhHKAKAaKaK....",
    ".KhHKAKAaKaK....",
    ".KhHKNKFfKNK....",
    ".KhHKAKLSKAK....",
    ".KhHKAKWSKaK....",
    ".KhhKAKWKAaK....",
    "..KhKAAKAAaK....",
    "..KhKAAKAAaK....",
    "...KKAAKAAaK....",
]
RIGHT_LEGS = {
    'idle': [
        "....KaKAAK......",
        "....KaKAAK......",
        "....KaKAaK......",
        "....KDKDDK......",
        "....KDKDDDDK....",
        "....KKKKKKKK....",
        "................",
    ],
    'stepA': [
        "....KaKAaK......",
        "...KaaKKAaK.....",
        "...KaaK.KAaK....",
        "..KDDK..KDDK....",
        "..KDDK..KDDDDK..",
        "..KKKK..KKKKKK..",
        "................",
    ],
    'stepB': [
        "....KAaKaK......",
        "...KAaKKaaK.....",
        "...KAaK.KaaK....",
        "..KDDK...KDDK...",
        "..KDDDK..KDDDK..",
        "..KKKKK..KKKKK..",
        "................",
    ],
}

VIEWS = [('down', DOWN, DOWN_LEGS), ('up', UP, DOWN_LEGS), ('right', RIGHT, RIGHT_LEGS)]

if __name__ == '__main__':
    main(VIEWS, PAL)
