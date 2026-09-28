"""Ryn walk-cycle frames, hand-placed (see pixelgrid.py for the sheet layout).

Usage: python build_ryn_walk.py <sheet.png> [preview_x8.png]
"""
from pixelgrid import BASE, main

PAL = dict(BASE, **{
    'H': (44, 32, 30), 'h': (86, 62, 50),        # hair
    'R': (196, 48, 48), 'r': (128, 28, 36),      # headband
    'O': (236, 150, 52), 'o': (184, 100, 36),    # saffron gi
    'N': (96, 64, 40), 'n': (64, 42, 26),        # sash / pants
    'T': (236, 228, 208), 't': (184, 172, 146),  # wraps
})

DOWN = [
    "................",
    ".......KK.......",
    "......KhHK......",
    "....KKKHHKKK....",
    "...KHhhHHHHHK...",
    "..KHhHHHHHHHHK..",
    "..KRRRRRRRRrrK..",
    "..KHFFFFFFFFHK..",
    "..KFFKFFFFKFfK..",
    "..KFFKFFFFKFfK..",
    "..KfFFFFFFFFfK..",
    "...KKfFFFFfKK...",
    "..KOOOKFfKOOoK..",
    ".KOOOOOKKOOOooK.",
    ".KOKOOOOOOOOKoK.",
    "KOOKOOOOOOOOKooK",
    "KOOKOOOOOOOoKooK",
    "KTTKOOOOOOOoKtTK",
    "KTtKNNNNNNNNKtTK",
    "KTtKOOONnOOoKtTK",
    "KFfKOOONnOOoKfFK",
    ".KK.KOOOOOOoK.KK",
    "....KnnnKnnnK...",
    "....KnNnKnNnK...",
    "....KnNnKnNnK...",
]
DOWN_LEGS = {
    'idle': [
        "....KTTtKTTtK...",
        "....KTTtKTTtK...",
        "....KtTtKtTtK...",
        "....KFFfKFFfK...",
        "...KFFFfKFFFfK..",
        "...KKKKKKKKKKK..",
        "................",
    ],
    'stepA': [
        "....KTTtKTTtK...",
        "....KTTtKTTtK...",
        "....KtTtKFFfK...",
        "....KtTtKFFFfK..",
        "....KFFfKKKKKK..",
        "...KFFFfK.......",
        "...KKKKKK.......",
    ],
    'stepB': [
        "....KTTtKTTtK...",
        "....KTTtKTTtK...",
        "....KFFfKtTtK...",
        "...KFFFfKtTtK...",
        "...KKKKKKFFfK...",
        "........KFFFfK..",
        "........KKKKKK..",
    ],
}

# Back of the head: headband knot tied off to one side, tails hanging.
UP = [
    "................",
    ".......KK.......",
    "......KhHK......",
    "....KKKHHKKK....",
    "...KHhhHHHHHK...",
    "..KHhHHHHHHHHK..",
    "..KRRRRRRRRrrK..",
    "..KHhHHHHHHHHrRK",
    "..KHhHHHHHHHHKRK",
    "..KHhHHHHHHHHKrK",
    "..KHhHHHHHHHHK..",
    "...KKfFFFFfKK...",
    "..KOOOOOOOOOoK..",
    ".KOOOOOOOOOOooK.",
    ".KOKOOOOOOOOKoK.",
    "KOOKOOOOOOOOKooK",
    "KOOKOOOOOOOoKooK",
    "KTTKOOOOOOOoKtTK",
    "KTtKNNNNNNNNKtTK",
    "KTtKOOOOOOOoKtTK",
    "KFfKOOOOOOOoKfFK",
    ".KK.KOOOOOOoK.KK",
    "....KnnnKnnnK...",
    "....KnNnKnNnK...",
    "....KnNnKnNnK...",
]

# Facing right: headband tails trail behind, near arm hangs over the torso.
RIGHT = [
    "................",
    "......KK........",
    ".....KhHK.......",
    "....KKHHKKK.....",
    "...KHhHHHHHK....",
    "..KHhHHHHHHHK...",
    ".KrRRRRRRRRRK...",
    "KrKHHHHFFFFFK...",
    ".KKHHHFFFKFfK...",
    "..KHHHFFFKFFK...",
    "..KHHHfFFFFFK...",
    "...KKKfFFFfK....",
    "...KOOKFfKOK....",
    "..KOOKOOOKOoK...",
    "..KOOKOOOKOoK...",
    "..KOOKOOoKOoK...",
    "..KOOKTTtKOoK...",
    "..KNNKTTtKNNK...",
    "..KOOKTTtKOoK...",
    "..KOOKFFfKOoK...",
    "..KOOOKKKOOoK...",
    "...KOOOOOOoK....",
    "....KnnnnnK.....",
    "....KnNnnnK.....",
    "....KnNnnnK.....",
]
RIGHT_LEGS = {
    'idle': [
        "...KttKTTtK.....",
        "...KttKTTtK.....",
        "...KttKTtK......",
        "...KffKFfK......",
        "...KffKFFFfK....",
        "...KKKKKKKKK....",
        "................",
    ],
    'stepA': [
        "....KtKTtK......",
        "...KttKKTtK.....",
        "...KttK.KTtK....",
        "..KffK..KFfK....",
        "..KffK..KFFFfK..",
        "..KKKK..KKKKKK..",
        "................",
    ],
    'stepB': [
        "....KTtKtK......",
        "...KTtKKttK.....",
        "...KTtK.KttK....",
        "..KFfK...KffK...",
        "..KFFfK..KfffK..",
        "..KKKKK..KKKKK..",
        "................",
    ],
}

VIEWS = [('down', DOWN, DOWN_LEGS), ('up', UP, DOWN_LEGS), ('right', RIGHT, RIGHT_LEGS)]

if __name__ == '__main__':
    main(VIEWS, PAL)
