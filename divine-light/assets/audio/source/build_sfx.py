"""Chiptune sound effects for Divine Light, synthesized from scratch.

Same idea as the pixel-art generators: everything is built in code, so a sound
is tweaked by editing numbers here and rerunning. Voices are the classic
16-bit-era set: pulse (square with a duty cycle), triangle, and LFSR noise,
shaped with envelopes, pitch slides and arpeggios. Pure Python (no numpy).

Writes 16-bit mono WAVs at 32 kHz to <out_dir>/<name>.wav.

Usage: python build_sfx.py <out_dir>
"""
import math
import os
import struct
import sys
import wave

RATE = 32000
NOTE_INDEX = {'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5, 'F#': 6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11}


def note(name):
    """'A4' -> 440.0"""
    pitch, octave = name[:-1], int(name[-1])
    semis = NOTE_INDEX[pitch] + 12 * (octave + 1) - 69
    return 440.0 * 2 ** (semis / 12)


# ------------------------------------------------------------------ voices
def tone(kind, freq, dur, vol=1.0, duty=0.5, env=None, vibrato=0.0):
    """freq: number, or a function of t (seconds) for slides.
    env: function of (t, dur) -> 0..1 amplitude."""
    n = int(dur * RATE)
    out = [0.0] * n
    phase = 0.0
    for i in range(n):
        t = i / RATE
        f = freq(t) if callable(freq) else freq
        if vibrato:
            f *= 1 + vibrato * math.sin(2 * math.pi * 7 * t)
        phase = (phase + f / RATE) % 1.0
        if kind == 'pulse':
            s = 1.0 if phase < duty else -1.0
        elif kind == 'tri':
            s = 4 * abs(phase - 0.5) - 1
        else:
            s = math.sin(2 * math.pi * phase)
        out[i] = s * vol * (env(t, dur) if env else 1.0)
    return out


def noise(dur, vol=1.0, rate_hz=8000, env=None, short=False):
    """NES-style 15-bit LFSR noise; rate_hz is how often it clocks (higher =
    brighter hiss), and may be a function of t for sweeps."""
    n = int(dur * RATE)
    out = [0.0] * n
    reg = 1
    acc = 0.0
    bit = 1.0
    for i in range(n):
        t = i / RATE
        r = rate_hz(t) if callable(rate_hz) else rate_hz
        acc += r / RATE
        while acc >= 1:
            acc -= 1
            fb = (reg ^ (reg >> (6 if short else 1))) & 1
            reg = (reg >> 1) | (fb << 14)
            bit = 1.0 if reg & 1 else -1.0
        out[i] = bit * vol * (env(t, dur) if env else 1.0)
    return out


# --------------------------------------------------------------- envelopes
def decay(rate):
    return lambda t, d: math.exp(-t * rate)


def adsr(a=0.005, d=0.05, s=0.6, r=0.05):
    def f(t, dur):
        if t < a:
            v = t / a
        elif t < a + d:
            v = 1 - (1 - s) * (t - a) / d
        else:
            v = s
        tail = dur - t
        return v * (tail / r if tail < r else 1)
    return f


def slide(f0, f1, dur, curve=1.0):
    return lambda t: f0 + (f1 - f0) * min(1, t / dur) ** curve


# ------------------------------------------------------------------ mixing
def mix(length, *parts):
    """parts: (start_seconds, samples)"""
    out = [0.0] * int(length * RATE)
    for start, samples in parts:
        o = int(start * RATE)
        for i, s in enumerate(samples):
            if o + i < len(out):
                out[o + i] += s
    return out


def seq(notes, kind='pulse', vol=0.5, duty=0.5, env=None, gap=0.0):
    """[(note_or_freq, seconds)] played back to back -> (samples, total)."""
    parts, t = [], 0.0
    for nm, dur in notes:
        f = note(nm) if isinstance(nm, str) else nm
        parts.append((t, tone(kind, f, dur, vol, duty, env or adsr(0.003, 0.03, 0.7, 0.02))))
        t += dur + gap
    return mix(t, *parts), t


def echo(samples, delay=0.09, feedback=0.35, taps=3):
    parts = [(0, samples)]
    for k in range(1, taps + 1):
        parts.append((delay * k, [s * feedback ** k for s in samples]))
    return mix(len(samples) / RATE + delay * taps, *parts)


def lowpass(samples, amount=0.35):
    """One-pole smoothing, takes the harsh edge off raw square waves."""
    out, y = [], 0.0
    for s in samples:
        y += amount * (s - y)
        out.append(y)
    return out


def finish(samples, peak=0.8):
    samples = lowpass(samples, 0.45)
    m = max(1e-9, max(abs(s) for s in samples))
    samples = [s * peak / m for s in samples]
    fade = int(0.004 * RATE)  # no clicks at the ends
    for i in range(min(fade, len(samples))):
        samples[i] *= i / fade
        samples[-1 - i] *= i / fade
    return samples


# ------------------------------------------------------------------- sounds
def attack():
    # blade whoosh (noise sweeping bright -> dull) into a low thump
    whoosh = noise(0.09, 0.5, rate_hz=slide(24000, 6000, 0.09), env=adsr(0.02, 0.03, 0.6, 0.04))
    thump = tone('pulse', slide(220, 55, 0.09, 0.6), 0.11, 0.9, 0.5, decay(28))
    crack = noise(0.05, 0.6, rate_hz=12000, env=decay(60))
    return mix(0.24, (0, whoosh), (0.07, thump), (0.07, crack))


def spell():
    # quick rising arpeggio with a shimmering echoed trail
    arp, t = seq([(n_, 0.035) for n_ in ['C5', 'E5', 'G5', 'C6', 'E6', 'G6']], 'pulse', 0.45, 0.25)
    shimmer = tone('tri', note('C7'), 0.3, 0.35, env=decay(9), vibrato=0.02)
    sparkle = noise(0.25, 0.12, rate_hz=30000, env=decay(14))
    return echo(mix(t + 0.3, (0, arp), (t - 0.02, shimmer), (t - 0.02, sparkle)), 0.08, 0.3, 2)


def hit():
    # punchy: bright noise crack plus a fast pitch drop
    crack = noise(0.06, 0.8, rate_hz=slide(16000, 3000, 0.06), env=decay(45))
    drop = tone('pulse', slide(420, 70, 0.12, 0.5), 0.14, 0.9, 0.5, decay(22))
    return mix(0.16, (0, drop), (0, crack))


def menu_move():
    return tone('pulse', note('A6'), 0.035, 0.6, 0.25, adsr(0.001, 0.01, 0.6, 0.012))


def menu_confirm():
    s, t = seq([('B5', 0.05), ('E6', 0.09)], 'pulse', 0.55, 0.25, adsr(0.002, 0.02, 0.7, 0.03))
    return s


def menu_cancel():
    s, t = seq([('E5', 0.045), ('A4', 0.07)], 'pulse', 0.55, 0.5, adsr(0.002, 0.02, 0.6, 0.03))
    return s


def victory():
    # original short fanfare: pickup arpeggio into a held chord, triangle bass
    lead_notes = [('G4', 0.09), ('C5', 0.09), ('E5', 0.09), ('G5', 0.18), ('E5', 0.09), ('G5', 0.09), ('C6', 0.62)]
    lead, t = seq(lead_notes, 'pulse', 0.45, 0.5, adsr(0.004, 0.05, 0.75, 0.08), gap=0.012)
    harm_notes = [('E4', 0.09), ('G4', 0.09), ('C5', 0.09), ('E5', 0.18), ('C5', 0.09), ('E5', 0.09), ('G5', 0.62)]
    harm, _ = seq(harm_notes, 'pulse', 0.25, 0.25, adsr(0.004, 0.05, 0.7, 0.08), gap=0.012)
    bass, _ = seq([('C3', 0.3), ('G2', 0.3), ('C3', 0.66)], 'tri', 0.6, env=adsr(0.004, 0.05, 0.8, 0.1), gap=0.012)
    roll = noise(0.28, 0.18, rate_hz=9000, env=lambda tt, d: 0.4 + 0.6 * ((tt * 22) % 1 < 0.35))
    return mix(t + 0.1, (0, lead), (0, harm), (0, bass), (0.36, roll))


def level_up():
    # bright rising run, then a trill that rings out
    run, t = seq([(n_, 0.05) for n_ in ['D5', 'F#5', 'A5', 'D6', 'F#6', 'A6']], 'pulse', 0.45, 0.25)
    trill, t2 = seq([('D7', 0.03), ('A6', 0.03)] * 5, 'pulse', 0.3, 0.125, adsr(0.001, 0.01, 0.8, 0.01))
    ring = tone('tri', note('D6'), 0.45, 0.45, env=decay(6))
    return echo(mix(t + t2 + 0.3, (0, run), (t, trill), (t, ring)), 0.1, 0.25, 2)


def item():
    # soft upward "bloop" then a two-note sparkle
    bloop = tone('tri', slide(300, 900, 0.1, 0.7), 0.12, 0.8, env=adsr(0.005, 0.04, 0.6, 0.04))
    chime, t = seq([('E6', 0.06), ('B6', 0.14)], 'pulse', 0.3, 0.125, adsr(0.002, 0.03, 0.6, 0.08))
    return mix(0.36, (0, bloop), (0.11, chime))


def equip():
    # metallic clink: inharmonic partials with a fast decay, twice
    def clink(v):
        return mix(0.2,
                   (0, tone('pulse', 2093, 0.2, 0.5 * v, 0.5, decay(30))),
                   (0, tone('sine', 3170, 0.2, 0.45 * v, env=decay(26))),
                   (0, tone('sine', 4410, 0.15, 0.3 * v, env=decay(40))),
                   (0, noise(0.02, 0.5 * v, rate_hz=20000, env=decay(120))))
    return mix(0.3, (0, clink(1.0)), (0.075, clink(0.55)))


def encounter():
    # battle start (Milestone 17d), timed to the screen effect: a rising pitch
    # sweep and whoosh that break into a crash as the screen goes dark
    rise = tone('pulse', slide(110, 880, 0.42, 1.4), 0.42, 0.5, 0.25, adsr(0.01, 0.1, 0.8, 0.02), vibrato=0.03)
    whoosh = noise(0.42, 0.35, rate_hz=slide(2500, 26000, 0.42), env=lambda tt, d: tt / d)
    crash = noise(0.32, 0.8, rate_hz=slide(14000, 2000, 0.32), env=decay(10))
    thump = tone('tri', slide(160, 40, 0.22, 0.5), 0.22, 0.8, env=decay(14))
    return mix(0.76, (0, rise), (0, whoosh), (0.42, crash), (0.42, thump))


# Peak level per sound. Menu blips play constantly, so they sit well below
# the one-off fanfares; the thin, high equip clink needs a push to be heard.
GAIN = {
    'attack': 0.8, 'spell': 0.7, 'hit': 0.8,
    'menu_move': 0.35, 'menu_confirm': 0.4, 'menu_cancel': 0.4,
    'victory': 0.75, 'level_up': 0.7, 'item': 0.65, 'equip': 0.9,
    'encounter': 0.75,
}

SOUNDS = {
    'attack': attack, 'spell': spell, 'hit': hit,
    'menu_move': menu_move, 'menu_confirm': menu_confirm, 'menu_cancel': menu_cancel,
    'victory': victory, 'level_up': level_up, 'item': item, 'equip': equip,
    'encounter': encounter,
}


def write(path, samples):
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, s)) * 32767)) for s in samples))


if __name__ == '__main__':
    out_dir = sys.argv[1]
    os.makedirs(out_dir, exist_ok=True)
    for name, fn in SOUNDS.items():
        samples = finish(fn(), GAIN[name])
        write(os.path.join(out_dir, name + '.wav'), samples)
        print('%-13s %.2fs' % (name, len(samples) / RATE))
