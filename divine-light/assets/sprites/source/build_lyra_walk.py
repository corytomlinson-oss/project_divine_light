"""Lyra walk-cycle frames, hand-placed (see pixelgrid.py for the sheet layout).

The staff's orb is fire-orange since Lyra starts every battle in Fire stance.

Usage: python build_lyra_walk.py <sheet.png> [preview_x8.png]
"""
from pixelgrid import BASE, main

PAL = dict(BASE, **{
    'H': (168, 72, 40), 'h': (212, 112, 60), 'j': (112, 44, 28),  # auburn hair
    'C': (40, 138, 138), 'c': (24, 88, 96),      # teal robe
    'G': (232, 184, 48), 'g': (168, 116, 28),    # gold trim
    'N': (120, 80, 48), 'n': (80, 52, 30),       # staff / shoes
    'R': (255, 140, 40), 'Y': (255, 230, 140), 'r': (200, 72, 24),  # fire orb
})

# Staff in her right hand (viewer's left); robe hides the legs, so walking is
# shown by which shoe peeks out under the hem.
DOWN = [
    "................",
    "..KYK...........",
    ".KYRrK..KKKKK...",
    ".KRRrK.KhHHHjK..",
    "..KrK.KhHHHHHjK.",
    "..KNK.KhhHHHHjK.",
    "..KNK.KhHHHHHjK.",
    "..KNKKhHFFFFHHjK",
    "..KNKKHFKFFKFHjK",
    "..KNKKHFKFFKFHjK",
    "..KNKKHFFFFFfHjK",
    "..KNKKjHfFFfHjjK",
    "..KNKKjKGYGGKjjK",
    ".KFfKKCCCGGCCccK",
    ".KFfKCCCCCCCCccK",
    "..KNKCCCCCCCCcK.",
    "..KNKCCCCCCCCcK.",
    "..KNKGGGGGGGGgK.",
    "..KNKCCCCcCCCcK.",
    "..KNKCCCCcCCCcK.",
    "..KNKCCCCcCCCcK.",
    "..KNKCCCCcCCCccK",
    "..KNKCCCCcCCCccK",
    "..KNKCCCCcCCCccK",
    "..KNKCCCCcCCCccK",
]
DOWN_LEGS = {
    'idle': [
        "..KNKCCCCcCCCccK",
        "..KNKCCCCcCCCccK",
        "..KNKCCCCcCCCccK",
        "..KNKGGGGGGGGggK",
        "..KNKKnnKKKnnKKK",
        "..KKK.KKK.KKK...",
        "................",
    ],
    'stepA': [
        "..KNKCCCCcCCCccK",
        "..KNKCCCCcCCCccK",
        "..KNKCCCCcCCCccK",
        "..KNKGGGGGGGGggK",
        "..KNKKnnKKKKKKK.",
        "..KKKKnnK.......",
        ".....KKKK.......",
    ],
    'stepB': [
        "..KNKCCCCcCCCccK",
        "..KNKCCCCcCCCccK",
        "..KNKCCCCcCCCccK",
        "..KNKGGGGGGGGggK",
        "..KNKKKKKKKnnKKK",
        "..KKK.....KnnK..",
        "..........KKKK..",
    ],
}

# Mirror of the front with the staff on the viewer's right; long hair
# falls down her back over the robe.
UP = [
    "................",
    "...........KYK..",
    "...KKKKK..KrRYK.",
    "..KjHHHhK.KrRRK.",
    ".KjHHHHHhK.KrK..",
    ".KjHHHHhhK.KNK..",
    ".KjHHHHHhK.KNK..",
    "KjHHHHHHHhKKNK..",
    "KjHHHhHHHHKKNK..",
    "KjHHHhHHHHKKNK..",
    "KjHHHhHHHHKKNK..",
    "KjjHHhHHHjKKNK..",
    "KjjHHhHHHjKKNK..",
    "KccKjHhHHjKKfFK.",
    "KccCKjHhHKCKfFK.",
    ".KcCCKjHKCCKNK..",
    ".KcCCCKKCCCKNK..",
    ".KgGGGGGGGGKNK..",
    ".KcCCCcCCCCKNK..",
    ".KcCCCcCCCCKNK..",
    ".KcCCCcCCCCKNK..",
    "KccCCCcCCCCKNK..",
    "KccCCCcCCCCKNK..",
    "KccCCCcCCCCKNK..",
    "KccCCCcCCCCKNK..",
]
UP_LEGS = {
    'idle': [
        "KccCCCcCCCCKNK..",
        "KccCCCcCCCCKNK..",
        "KccCCCcCCCCKNK..",
        "KggGGGGGGGGKNK..",
        "KKKnnKKKnnKKNK..",
        "...KKK.KKK.KKK..",
        "................",
    ],
    'stepA': [
        "KccCCCcCCCCKNK..",
        "KccCCCcCCCCKNK..",
        "KccCCCcCCCCKNK..",
        "KggGGGGGGGGKNK..",
        ".KKKKKKKnnKKNK..",
        ".......KnnKKKK..",
        ".......KKKK.....",
    ],
    'stepB': [
        "KccCCCcCCCCKNK..",
        "KccCCCcCCCCKNK..",
        "KccCCCcCCCCKNK..",
        "KggGGGGGGGGKNK..",
        "KKKnnKKKKKKKNK..",
        "..KnnK.....KKK..",
        "..KKKK..........",
    ],
}

# Facing right: hair falls behind her, staff held out in front.
RIGHT = [
    "................",
    "............KYK.",
    "....KKKKK..KYRrK",
    "...KhHHHHK.KRRrK",
    "..KhHHHHHHK.KrK.",
    "..KhHHHHHHHKKNK.",
    "..KhHHHHHHFKKNK.",
    "..KhHHHFFFFKKNK.",
    "..KhHHHFFKFKKNK.",
    "..KhHHHFFKFKKNK.",
    "..KhHHHfFFFKKNK.",
    "..KhHHKKfFKKKNK.",
    "..KhHHKGYGKKKNK.",
    "..KhHKCCKKKKKNK.",
    "..KhHKCKCCCCFfK.",
    "..KjHKCKcccCFfK.",
    "...KKCCKKKKKKNK.",
    "...KGGGGGGGgKNK.",
    "...KCCCCCCcKKNK.",
    "...KCCCCCCcKKNK.",
    "...KCCCCCCcKKNK.",
    "..KCCCCCCCcKKNK.",
    "..KCCCCCCCcKKNK.",
    "..KCCCCCCCcKKNK.",
    "..KCCCCCCCcKKNK.",
]
RIGHT_LEGS = {
    'idle': [
        "..KCCCCCCCcKKNK.",
        "..KCCCCCCCcKKNK.",
        "..KCCCCCCCcKKNK.",
        "..KGGGGGGGgKKNK.",
        "...KKKnnnnnKKNK.",
        "...KKKKKKKKKKKK.",
        "................",
    ],
    # hem swings forward, front shoe steps out, back heel shows
    'stepA': [
        "..KCCCCCCCcKKNK.",
        "..KCCCCCCCcKKNK.",
        ".KCCCCCCCCcKKNK.",
        ".KGGGGGGGGgKKNK.",
        ".KnnKKKKKnnnKNK.",
        ".KKK....KKKKKKK.",
        "................",
    ],
    'stepB': [
        "..KCCCCCCCcKKNK.",
        "..KCCCCCCCcKKNK.",
        "..KCCCCCCCccKNK.",
        "..KGGGGGGGggKNK.",
        "..KnnnKKnnnnKNK.",
        "..KKKKKKKKKKKKK.",
        "................",
    ],
}

VIEWS = [('down', DOWN, DOWN_LEGS), ('up', UP, UP_LEGS), ('right', RIGHT, RIGHT_LEGS)]

if __name__ == '__main__':
    main(VIEWS, PAL)
