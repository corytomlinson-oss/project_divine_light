"""Vael walk-cycle frames, hand-placed. 16x32 each, one char per pixel.

Writes a 48x96 sheet: rows = down / up / right, columns = idle / stepA / stepB.
Walk loop is stepA -> idle -> stepB -> idle. Left-facing = the right row with
flip_h, so there's no left row.

Usage: python build_vael_walk.py <sheet.png> <preview_x8.png>
"""
from PIL import Image

PAL = {
    '.': None,
    'K': (26, 20, 32),     # outline
    'V': (14, 10, 20),     # visor slit
    'D': (72, 80, 104),    # steel dark
    'S': (138, 147, 168),  # steel mid
    'L': (200, 208, 220),  # steel light
    'W': (244, 246, 250),  # steel highlight
    'T': (236, 228, 208),  # tabard cloth
    't': (184, 172, 146),  # tabard shadow
    'G': (232, 184, 48),   # gold
    'g': (168, 116, 28),   # gold dark
    'Y': (255, 240, 160),  # gold highlight
    'N': (96, 64, 40),     # leather / wood
    'n': (64, 42, 26),     # leather / wood dark
    'O': (140, 96, 58),    # wood light
    'P': (96, 132, 204),   # shield blue light
    'B': (52, 84, 156),    # shield blue
    'b': (30, 46, 100),    # shield blue dark
}

# ---------------------------------------------------------------- facing down
HELM_FRONT = [
    "................",
    "....KKKKKKKK....",
    "...KLWWWLLLSK...",
    "..KDSSSSSSSSDK..",
    "..KSLWLLSSSDDK..",
    "..KLWWWLLLSSDK..",
    "..KVVVVVVVVVVK..",
    "..KDSSSSSSSDDK..",
    "..KSLWLLSSKDDK..",
    "..KSLWLLSKSKDK..",
    "..KDSSSSSSSDDK..",
    "..KKKKKKKKKKKK..",
]
BODY_FRONT = [
    ".KWLLSKYGKWLSDK.",
    "KWLLSDKTTKLSSDDK",
    "KLSKTTTGgKKKKKKK",
    "KLSKTTTGgKPBGBbK",
    "KLSKGGGGgKPBGBbK",
    "KLSKTTTGgKGGGGgK",
    "KLSKTTTGgKPBGBbK",
    "KLSKNNNYGKPBGBbK",
    "KDDKTTTGgKPBGBbK",
    "GYGKTTTGgtKBgbK.",
    "KWSKTTtGgTtKgK..",
    "KWSKTTtKtTttK...",
    "KWSKgGGKGGggK...",
]
LEGS_FRONT = {
    'idle': [
        "KWSKLSKKLSDK....",
        "KWSKLSKKSDDK....",
        ".KKKLSKKSDDK....",
        "...KDDKKDDDK....",
        "..KDDDKKDDDDK...",
        "..KKKKKKKKKKK...",
        "................",
    ],
    # viewer-left leg planted and reaching down, viewer-right leg lifted
    'stepA': [
        "KWSKLSKKLSDK....",
        "KWSKLSKKDDDK....",
        ".KKKLSKKDDDDK...",
        "...KLSKKKKKKK...",
        "...KDDK.........",
        "..KDDDK.........",
        "..KKKKK.........",
    ],
    'stepB': [
        "KWSKLSKKLSDK....",
        "KWSKDDKKSDDK....",
        ".KKDDDKKSDDK....",
        "..KKKKKKSDDK....",
        ".......KDDDK....",
        ".......KDDDDK...",
        ".......KKKKKK...",
    ],
}

# ------------------------------------------------------------------ facing up
HELM_BACK = [
    "................",
    "....KKKKKKKK....",
    "...KLWWWLLLSK...",
    "..KDSSSSSSSSDK..",
    "..KSLWLLSSSDDK..",
    "..KSLWLLSSSDDK..",
    "..KSLWLLSSSDDK..",
    "..KSLWLLSSSDDK..",
    "..KSLWLLSSSDDK..",
    "..KDDDDDDDDDDK..",
    "..KDSSSSSSSDDK..",
    "..KKKKKKKKKKKK..",
]
# Mirror of the front body: shield now on the viewer's left, showing its
# wooden back and straps; sword arm on the viewer's right.
BODY_BACK = [
    ".KWLLSKSSKWLLDK.",
    "KWLLSDKTTKLSSDDK",
    "KKKKKKKGgTTTKLSK",
    "KOONNnKGgTTTKLSK",
    "KOnnnnKGgGGGKLSK",
    "KOONNnKGgTTTKLSK",
    "KOONNnKGgTTTKLSK",
    "KOONNnKNNNNNKLSK",
    "KOONNnKGgTTtKDDK",
    ".KONnKtGgTTtKGYG",
    "..KNKtTGgtTTKSWK",
    "...KtTTtKtTTKSWK",
    "...KgGGKGGggKSWK",
]
LEGS_BACK = {
    'idle': [
        "....KLSKKLSDKSWK",
        "....KLSKKSDDKSWK",
        "....KLSKKSDDKKK.",
        "....KDDKKDDDK...",
        "...KDDDKKDDDDK..",
        "...KKKKKKKKKKK..",
        "................",
    ],
    'stepA': [
        "....KLSKKLSDKSWK",
        "....KLSKKDDDKSWK",
        "....KLSKKDDDDKK.",
        "....KLSKKKKKKK..",
        "....KDDK........",
        "...KDDDK........",
        "...KKKKK........",
    ],
    'stepB': [
        "....KLSKKLSDKSWK",
        "....KDDKKSDDKSWK",
        "...KDDDKKSDDKKK.",
        "...KKKKKKSDDK...",
        "........KDDDK...",
        "........KDDDDK..",
        "........KKKKKK..",
    ],
}

# --------------------------------------------------------------- facing right
HELM_SIDE = [
    "................",
    "....KKKKKKKK....",
    "...KLWWWLLLSK...",
    "..KDSSSSSSSSDK..",
    "..KSLWLLSSSSDK..",
    "..KSLWLLSLLWLK..",
    "..KSLWLLSVVVVK..",
    "..KSLWLLSSSSDK..",
    "..KSLWLLSSSKDK..",
    "..KSLWLLSSKSKK..",
    "..KDSSSSSSSSDK..",
    "...KKKKKKKKKK...",
]
# Near arm hangs at the side with a gauntleted fist (the sword is left out in
# profile - it just muddies the legs at this size); shield held forward on the
# far arm, seen edge-on as a blue face with its gold rim.
BODY_SIDE = [
    "..KSSKWLLLSKKK..",
    "..KTTKLLLSSDKBGK",
    "..KTTKSLSSDDKBGK",
    "..KTTTKLSDKTKBGK",
    "..KTTTKLSDKTKBGK",
    "..KTTTKLSDKTKBGK",
    "..KtTTKLSDKTKBGK",
    "..KNNNKLSDKNKBGK",
    "..KtTTKDDDKTKbGK",
    "..KtTTTKKKTtKbK.",
    "..KtTTTTtTTtKK..",
    "..KtTTTTtTTtK...",
    "..KgGGGGgGGgK...",
]
LEGS_SIDE = {
    'idle': [
        "...KDDKLSK......",
        "...KDDKLSK......",
        "...KDDKLSK......",
        "...KDDKDDK......",
        "...KDDKDDDDK....",
        "...KKKKKKKKK....",
        "................",
    ],
    # near leg striding forward, far leg pushing off behind
    'stepA': [
        "....KDKLSK......",
        "...KDDKKLSK.....",
        "...KDDK.KLSK....",
        "..KDDK..KDDK....",
        "..KDDK..KDDDDK..",
        "..KKKK..KKKKKK..",
        "................",
    ],
    # near leg behind, far leg forward
    'stepB': [
        "....KLSKDK......",
        "...KLSKKDDK.....",
        "...KLSK.KDDK....",
        "..KLSK...KDDK...",
        "..KDDDK..KDDDDK.",
        "..KKKKK..KKKKKK.",
        "................",
    ],
}

VIEWS = [
    ('down', HELM_FRONT, BODY_FRONT, LEGS_FRONT),
    ('up', HELM_BACK, BODY_BACK, LEGS_BACK),
    ('right', HELM_SIDE, BODY_SIDE, LEGS_SIDE),
]
POSES = ['idle', 'stepA', 'stepB']


def frame(rows):
    assert len(rows) == 32, len(rows)
    im = Image.new('RGBA', (16, 32), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        assert len(row) == 16, (y, len(row), row)
        for x, ch in enumerate(row):
            if PAL[ch]:
                im.putpixel((x, y), PAL[ch] + (255,))
    return im


def sheet():
    out = Image.new('RGBA', (16 * len(POSES), 32 * len(VIEWS)), (0, 0, 0, 0))
    for r, (name, helm, body, legs) in enumerate(VIEWS):
        for c, pose in enumerate(POSES):
            try:
                out.paste(frame(helm + body + legs[pose]), (c * 16, r * 32))
            except AssertionError as e:
                raise SystemExit(f'{name}/{pose}: {e}')
    return out


if __name__ == '__main__':
    import sys
    s = sheet()
    s.save(sys.argv[1])
    s.resize((s.width * 8, s.height * 8), Image.NEAREST).save(sys.argv[2])
