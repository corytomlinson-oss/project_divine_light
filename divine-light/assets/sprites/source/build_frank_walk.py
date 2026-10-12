"""Frank walk-cycle frames, hand-placed (see pixelgrid.py for the sheet layout).

Frank is a traveling merchant (Milestone 21): a wide-brimmed hat with a red
band, a grey-brown beard, a green coat with a gold-buckled belt, and a big
pack with a red bedroll strapped on top - the pack shows from behind and
from the side.

Usage: python build_frank_walk.py <sheet.png> [preview_x8.png]
"""
from pixelgrid import BASE, main

PAL = dict(BASE, **{
    'T': (122, 84, 50), 't': (82, 56, 34),       # hat
    'b': (172, 58, 48),                          # hat band
    'B': (146, 128, 110),                        # beard / hair
    'G': (88, 124, 74), 'g': (56, 84, 50),       # coat
    'P': (154, 112, 70), 'p': (106, 76, 48),     # pack
    'R': (172, 60, 50), 'r': (118, 38, 34),      # bedroll
    'N': (98, 66, 42),                           # straps / belt
    'C': (226, 186, 84),                         # brass buckle
    'U': (92, 80, 70), 'u': (62, 54, 48),        # trousers
    'o': (64, 42, 30),                           # boots
})

DOWN = [
    "................",
    ".....KKKKKK.....",
    "....KTTTTTTK....",
    "....KTTTTTtK....",
    "....KbbbbbbK....",
    "..KKTTTTTTTtKK..",
    ".KtTTTTTTTTTTtK.",
    "...KFFFFFFFFK...",
    "...KFKFFFFKFK...",
    "...KfFFffFFfK...",
    "...KBFBBBBFBK...",
    "...KBBBBBBBBK...",
    "....KBBBBBBK....",
    "..KKGGKBBKGGKK..",
    ".KPGGNGGGGNGGPK.",
    ".KPGGNGGGGNGGPK.",
    "KPpGGNGGGGNGGpPK",
    "KPpGGNGGGGNGgpPK",
    "KPpGGNGGGGNGgpPK",
    "KPpGNNNNCNNNgpPK",
    "KKpFGGGGGGGGgFKK",
    ".KKfGGGGGGGGgfK.",
    "...KGGGGGGGGgK..",
    "...KGGGgKGGGgK..",
    ".....KUUKUUK....",
]
DOWN_LEGS = {
    'idle': [
        ".....KUUKUUK....",
        ".....KUUKUuK....",
        ".....KUuKuuK....",
        ".....KooKooK....",
        "....KoooKoooK...",
        "....KKKKKKKKK...",
        "................",
    ],
    'stepA': [
        ".....KUUKUuK....",
        ".....KUUKuuK....",
        ".....KuuKooK....",
        ".....KuuKoooK...",
        ".....KooKKKKK...",
        "....KoooK.......",
        "....KKKKK.......",
    ],
    'stepB': [
        ".....KUUKUuK....",
        ".....KuuKUuK....",
        ".....KooKuuK....",
        "....KoooKuuK....",
        "....KKKKKooK....",
        "........KoooK...",
        "........KKKKK...",
    ],
}

# From behind: the hat, then the pack with the bedroll on top fills his back.
UP = [
    "................",
    ".....KKKKKK.....",
    "....KTTTTTTK....",
    "....KTTTTTtK....",
    "....KbbbbbbK....",
    "..KKTTTTTTTtKK..",
    ".KtTTTTTTTTTTtK.",
    "...KKttttttKK...",
    "...KBBBBBBBBK...",
    "...KBBBBBBBBK...",
    "..KKRRRRRRRRKK..",
    ".KRRrRRRRRRrRRK.",
    "..KKRRRRRRRRKK..",
    ".KGKPPPPPPPPKGK.",
    ".KGKPppppppPKGK.",
    ".KGKPpPPPPpPKGK.",
    "KGGKPpPNNPpPKGgK",
    "KGGKPpPCCPpPKGgK",
    "KGGKPpPPPPpPKGgK",
    "KGGKPPPPPPPPKGgK",
    "KFfKppppppppKfFK",
    ".KKKKKKKKKKKKKK.",
    "...KGGGGGGGGgK..",
    "...KGGGgKGGGgK..",
    ".....KUUKUUK....",
]

# Facing right: the pack rides behind him, the hat brim reaches forward.
RIGHT = [
    "................",
    "......KKKKK.....",
    ".....KTTTTTK....",
    ".....KTTTTtK....",
    ".....KbbbbbK....",
    "...KKTTTTTTTKK..",
    "..KtTTTTTTTTTTK.",
    "....KBBFFFFFK...",
    "....KBBFFFKFK...",
    "....KBfFFFFFFK..",
    "....KBBBBBBBK...",
    ".....KBBBBBK....",
    ".KRRKKKBBKK.....",
    "KRrRKGGGGGK.....",
    "KPPPKGGNGGK.....",
    "KPpPKGGNGGK.....",
    "KPpPKGGNGGK.....",
    "KPpPKGGNGGK.....",
    "KPCPKGGGFfK.....",
    "KPpPKNNNCNK.....",
    "KPpPKGGGGgK.....",
    "KPPPKGGGGgK.....",
    ".KKKKGGGGgK.....",
    "....KGGGGgK.....",
    "....KUKUUK......",
]
RIGHT_LEGS = {
    'idle': [
        "....KuKUUK......",
        "....KuKUUK......",
        "....KuKUuK......",
        "....KoKooK......",
        "....KoKooooK....",
        "....KKKKKKKK....",
        "................",
    ],
    'stepA': [
        "....KuKUuK......",
        "...KuuKKUuK.....",
        "...KuuK.KUuK....",
        "..KooK..KooK....",
        "..KooK..KooooK..",
        "..KKKK..KKKKKK..",
        "................",
    ],
    'stepB': [
        "....KUuKuK......",
        "...KUuKKuuK.....",
        "...KUuK.KuuK....",
        "..KooK...KooK...",
        "..KoooK..KoooK..",
        "..KKKKK..KKKKK..",
        "................",
    ],
}

VIEWS = [('down', DOWN, DOWN_LEGS), ('up', UP, DOWN_LEGS), ('right', RIGHT, RIGHT_LEGS)]

if __name__ == '__main__':
    main(VIEWS, PAL)
