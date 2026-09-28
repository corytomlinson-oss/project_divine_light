"""Chiptune background music for Divine Light, composed and synthesized in code.

Each track is written as note lists per voice (the classic 4-channel chip
setup: pulse lead, pulse arpeggio, triangle bass, noise drums), rendered to a
16-bit mono WAV with a `smpl` loop chunk so Godot loops it seamlessly from the
end of the intro. Anything ringing past the loop end is folded back onto the
loop start, so there's no click or gap at the seam.

Durations are in 16th notes. 'r' is a rest. Bass patterns are 8 eighth-note
steps per bar: R = root, O = root an octave up, F = fifth, '-' = hold the
previous note, '.' = rest.

Usage: python build_music.py <out_dir> [track ...]
"""
import math
import os
import struct
import sys
import wave

from build_sfx import RATE, note

# ----------------------------------------------------------------- voices


def render_note(buf, start, length, freq, kind, vol, duty=0.5, vibrato=0.0,
                attack=0.004, release=0.03, decay_to=0.75, decay_time=0.12):
    """Adds one note into buf (list of floats) starting at sample `start`."""
    n = int(length * RATE)
    rel = int(release * RATE)
    phase = 0.0
    for i in range(n + rel):
        t = i / RATE
        if t < attack:
            env = t / attack
        elif t < attack + decay_time:
            env = 1 - (1 - decay_to) * (t - attack) / decay_time
        else:
            env = decay_to
        if i >= n:
            env *= 1 - (i - n) / rel
        f = freq
        if vibrato and t > 0.12:  # vibrato only on held notes
            f *= 1 + vibrato * math.sin(2 * math.pi * 5.5 * (t - 0.12))
        phase = (phase + f / RATE) % 1.0
        if kind == 'pulse':
            s = 1.0 if phase < duty else -1.0
        else:  # triangle
            s = 4 * abs(phase - 0.5) - 1
        j = start + i
        if j < len(buf):
            buf[j] += s * vol * env


class Noise:
    def __init__(self):
        self.reg = 1

    def hit(self, buf, start, length, vol, rate_hz, decay_rate, short=False):
        acc, bit = 0.0, 1.0
        for i in range(int(length * RATE)):
            acc += rate_hz / RATE
            while acc >= 1:
                acc -= 1
                fb = (self.reg ^ (self.reg >> (6 if short else 1))) & 1
                self.reg = (self.reg >> 1) | (fb << 14)
                bit = 1.0 if self.reg & 1 else -1.0
            j = start + i
            if j < len(buf):
                buf[j] += bit * vol * math.exp(-i / RATE * decay_rate)


def kick(buf, start, vol):
    """Triangle pitch-drop kick."""
    n = int(0.12 * RATE)
    phase = 0.0
    for i in range(n):
        t = i / RATE
        f = 150 * math.exp(-t * 30) + 45
        phase = (phase + f / RATE) % 1.0
        j = start + i
        if j < len(buf):
            buf[j] += (4 * abs(phase - 0.5) - 1) * vol * math.exp(-t * 18)


# --------------------------------------------------------------- sequencing
CHORDS = {
    'Dm': ['D', 'F', 'A'], 'Gm': ['G', 'A#', 'D'], 'Bb': ['A#', 'D', 'F'],
    'C': ['C', 'E', 'G'], 'A': ['A', 'C#', 'E'], 'F': ['F', 'A', 'C'],
    'Am': ['A', 'C', 'E'], 'E': ['E', 'G#', 'B'], 'Em': ['E', 'G', 'B'],
    'G': ['G', 'B', 'D'], 'Cm': ['C', 'D#', 'G'], 'Eb': ['D#', 'G', 'A#'],
    'D': ['D', 'F#', 'A'], 'Bm': ['B', 'D', 'F#'], 'B': ['B', 'D#', 'F#'],
    'G#dim': ['G#', 'B', 'D'],
}


def chord_tones(chord, octave):
    """Root, third, fifth folded upward from the root in `octave` (Hz)."""
    root, third, fifth = CHORDS[chord]
    base = fnote(root + str(octave))
    tones = [base]
    for name in (third, fifth):
        f = fnote(name + str(octave))
        while f < base:
            f *= 2
        tones.append(f)
    return sorted(tones)


def fnote(name):
    return note(name.replace('Bb', 'A#').replace('Eb', 'D#'))


def melody_events(bars, step):
    """bars: list of [(note, sixteenths)] per bar -> [(start_s, dur_s, name)]"""
    out, t = [], 0.0
    for bar in bars:
        used = sum(d for _, d in bar)
        assert used == 16, (bar, used)
        for name, d in bar:
            if name != 'r':
                out.append((t, d * step, name))
            t += d * step
    return out


def render_track(tr):
    step = 60.0 / tr['bpm'] / 4
    bar_len = 16 * step
    total_bars = len(tr['chords'])
    total = total_bars * bar_len
    buf = [0.0] * (int(total * RATE) + int(1.0 * RATE))  # 1s spill for tails
    S = lambda sec: int(round(sec * RATE))

    # lead
    for t, d, name in melody_events(tr['lead'], step):
        render_note(buf, S(t), d - 0.012, fnote(name), 'pulse', tr['lead_vol'],
                    duty=tr.get('lead_duty', 0.5), vibrato=0.012 if d >= 4 * step else 0.0,
                    release=0.04)
    # optional second melody line (harmony / counterline)
    if 'counter' in tr:
        for t, d, name in melody_events(tr['counter'], step):
            render_note(buf, S(t), d - 0.012, fnote(name), 'pulse', tr['counter_vol'],
                        duty=0.25, release=0.04)

    noise = Noise()
    for b, chord in enumerate(tr['chords']):
        t0 = b * bar_len
        root, third, fifth = CHORDS[chord]
        # arpeggio: chord-tone cycle, the classic chip "fake chord"; 16ths by
        # default, arp_div=2 for gentler 8ths
        if tr.get('arp', True) and b >= tr.get('arp_from', 0):
            tones = chord_tones(chord, 4)
            seq = tones + [tones[0] * 2]
            div = tr.get('arp_div', 1)
            for k in range(16 // div):
                render_note(buf, S(t0 + k * div * step), div * step * 0.85, seq[k % 4], 'pulse', tr['arp_vol'],
                            duty=0.125, attack=0.002, release=0.01, decay_to=0.5, decay_time=0.05)
        # pad: sustained chord (the Cathedral's organ)
        if tr.get('pad') and b >= tr.get('pad_from', 0):
            for f in chord_tones(chord, 3):
                render_note(buf, S(t0), bar_len - 0.05, f, 'pulse', tr['pad_vol'], duty=0.5,
                            attack=0.25, release=0.3, decay_to=1.0, decay_time=0.01)
        # bass: eighth-note steps, root / octave / fifth, with holds
        pattern = tr['bass_pattern']
        low = fnote(root + '2')
        if low < 60:
            low *= 2
        fifth_f = fnote(fifth + '2')
        while fifth_f < low:
            fifth_f *= 2
        for k, which in enumerate(pattern):
            if which in '.-':
                continue
            f = {'R': low, 'O': low * 2, 'F': fifth_f}[which]
            steps = 1
            while k + steps < len(pattern) and pattern[k + steps] == '-':
                steps += 1
            render_note(buf, S(t0 + k * 2 * step), steps * 2 * step * 0.9, f, 'tri', tr['bass_vol'],
                        attack=0.003, release=0.02, decay_to=0.9, decay_time=0.05)
        # drums
        if b >= tr.get('drums_from', 0):
            fill = b in tr.get('fills', [])
            for k in range(16):
                pos = t0 + k * step
                if k in tr['kick']:
                    kick(buf, S(pos), tr['drum_vol'] * 1.3)
                if k in tr['snare'] or (fill and k >= 12):
                    noise.hit(buf, S(pos), 0.14, tr['drum_vol'] * (0.8 if fill and k > 12 else 1.0), 11000, 22)
                elif k % 2 == 0 and tr.get('hats', True):
                    noise.hit(buf, S(pos), 0.04, tr['drum_vol'] * 0.35, 26000, 90, short=True)

    # seamless loop: fold everything past the end back onto the loop start
    loop_start = S(tr['loop_from_bar'] * bar_len)
    end = S(total)
    for i in range(end, len(buf)):
        k = loop_start + (i - end)
        if k < end:
            buf[k] += buf[i]
    buf = buf[:end]
    # gentle smoothing, then normalize
    y, out = 0.0, []
    for s in buf:
        y += 0.5 * (s - y)
        out.append(y)
    m = max(abs(s) for s in out)
    out = [s * tr['peak'] / m for s in out]
    return out, loop_start, end


def write_looping_wav(path, samples, loop_start, loop_end):
    data = b''.join(struct.pack('<h', int(max(-1, min(1, s)) * 32767)) for s in samples)
    fmt = struct.pack('<HHIIHH', 1, 1, RATE, RATE * 2, 2, 16)
    # smpl chunk: one forward loop; Godot's WAV importer reads it
    # ("Detect From WAV" loop mode) and loops from the end of the intro.
    smpl = struct.pack('<9I', 0, 0, int(1e9 / RATE), 60, 0, 0, 0, 1, 0)
    smpl += struct.pack('<6I', 0, 0, loop_start, loop_end - 1, 0, 0)
    chunks = b'fmt ' + struct.pack('<I', len(fmt)) + fmt
    chunks += b'smpl' + struct.pack('<I', len(smpl)) + smpl
    chunks += b'data' + struct.pack('<I', len(data)) + data
    with open(path, 'wb') as f:
        f.write(b'RIFF' + struct.pack('<I', 4 + len(chunks)) + b'WAVE' + chunks)


# ------------------------------------------------------------------ tracks
# Standard battle theme: D minor, 152 BPM. Intro (2 bars, plays once) ->
# A (main theme) -> B (lifts toward the relative major, then builds tension
# on the A chord) -> A' (varied return whose last bar runs back down into A).
BATTLE = dict(
    bpm=152, peak=0.85, loop_from_bar=2,
    lead_vol=0.30, arp_vol=0.09, bass_vol=0.42, drum_vol=0.22, lead_duty=0.5,
    bass_pattern=['R', 'R', 'O', 'R', 'R', 'O', 'R', 'O'],
    kick=[0, 6, 8, 10], snare=[4, 12],
    fills=[1, 9, 17, 25],
    chords=(
        ['Dm', 'Dm'] +                                          # intro
        ['Dm', 'Dm', 'Bb', 'C', 'Dm', 'Dm', 'Bb', 'A'] +        # A
        ['Gm', 'Gm', 'Dm', 'Dm', 'Bb', 'C', 'A', 'A'] +         # B
        ['Dm', 'Dm', 'Bb', 'C', 'Dm', 'Dm', 'Bb', 'A']          # A'
    ),
    lead=[
        # intro: silence, then a rising pickup
        [('r', 16)],
        [('A4', 2), ('D5', 2), ('F5', 2), ('A5', 2), ('D6', 6), ('r', 2)],
        # A
        [('D5', 4), ('A4', 2), ('D5', 2), ('F5', 4), ('E5', 2), ('D5', 2)],
        [('E5', 4), ('F5', 2), ('G5', 2), ('A5', 8)],
        [('Bb5', 4), ('A5', 2), ('G5', 2), ('F5', 4), ('D5', 4)],
        [('G5', 6), ('F5', 2), ('E5', 4), ('C5', 4)],
        [('D5', 2), ('D5', 2), ('A5', 4), ('F5', 2), ('G5', 2), ('A5', 4)],
        [('D6', 6), ('C6', 2), ('A5', 4), ('F5', 4)],
        [('G5', 4), ('F5', 2), ('G5', 2), ('Bb5', 4), ('A5', 2), ('G5', 2)],
        [('A5', 8), ('C#6', 4), ('E6', 4)],
        # B
        [('D6', 6), ('Bb5', 2), ('G5', 8)],
        [('A5', 2), ('Bb5', 2), ('C6', 4), ('Bb5', 4), ('A5', 4)],
        [('F5', 6), ('E5', 2), ('D5', 8)],
        [('E5', 2), ('F5', 2), ('A5', 4), ('D6', 8)],
        [('F6', 6), ('E6', 2), ('D6', 4), ('Bb5', 4)],
        [('E6', 6), ('D6', 2), ('C6', 4), ('G5', 4)],
        [('A5', 4), ('C#6', 4), ('E6', 4), ('G6', 4)],
        [('A6', 12), ('r', 4)],
        # A' - same shape, answered an octave up in the middle
        [('D5', 4), ('A4', 2), ('D5', 2), ('F5', 4), ('E5', 2), ('D5', 2)],
        [('E5', 4), ('F5', 2), ('G5', 2), ('A5', 8)],
        [('Bb5', 4), ('A5', 2), ('G5', 2), ('F5', 4), ('D5', 4)],
        [('G5', 6), ('F5', 2), ('E5', 4), ('C5', 4)],
        [('D6', 2), ('D6', 2), ('A6', 4), ('F6', 2), ('G6', 2), ('A6', 4)],
        [('D6', 6), ('E6', 2), ('F6', 4), ('D6', 4)],
        [('E6', 4), ('D6', 2), ('C6', 2), ('Bb5', 4), ('G5', 4)],
        # turnaround: runs down to the low A, straight back into A
        [('A5', 2), ('G5', 2), ('F5', 2), ('E5', 2), ('D5', 2), ('C#5', 2), ('E5', 2), ('A4', 2)],
    ],
)

# Overworld: the Forest Heartlands. G major, 120 BPM - hopeful and wandering,
# with a reflective E minor middle. Gentler than battle: 8th-note arpeggio,
# root-fifth bass in quarter notes, lighter drums.
OVERWORLD = dict(
    bpm=120, peak=0.8, loop_from_bar=2,
    lead_vol=0.30, arp_vol=0.08, arp_div=2, bass_vol=0.40, drum_vol=0.15, lead_duty=0.5,
    bass_pattern=['R', '-', 'F', '-', 'R', '-', 'F', 'O'],
    kick=[0, 8], snare=[4, 12],
    fills=[9, 17, 25],
    chords=(
        ['G', 'D'] +                                            # intro
        ['G', 'D', 'Em', 'C', 'G', 'D', 'C', 'D'] +             # A
        ['Em', 'C', 'G', 'D', 'Em', 'C', 'Am', 'D'] +           # B
        ['G', 'D', 'Em', 'C', 'G', 'Bm', 'C', 'D']              # A'
    ),
    lead=[
        [('r', 16)],
        [('r', 8), ('D5', 2), ('E5', 2), ('F#5', 2), ('A5', 2)],
        # A
        [('B4', 4), ('D5', 4), ('G5', 6), ('F#5', 2)],
        [('A5', 8), ('F#5', 4), ('D5', 4)],
        [('E5', 4), ('G5', 4), ('B5', 6), ('A5', 2)],
        [('G5', 8), ('E5', 4), ('C5', 4)],
        [('D5', 4), ('G5', 4), ('B5', 4), ('D6', 4)],
        [('C6', 4), ('B5', 2), ('A5', 2), ('F#5', 8)],
        [('E5', 4), ('G5', 2), ('A5', 2), ('C6', 4), ('B5', 2), ('A5', 2)],
        [('A5', 12), ('r', 4)],
        # B
        [('B5', 6), ('A5', 2), ('G5', 4), ('E5', 4)],
        [('E5', 4), ('G5', 4), ('C6', 8)],
        [('B5', 6), ('A5', 2), ('G5', 4), ('D5', 4)],
        [('F#5', 4), ('A5', 4), ('D6', 8)],
        [('E6', 6), ('D6', 2), ('B5', 4), ('G5', 4)],
        [('C6', 6), ('B5', 2), ('G5', 4), ('E5', 4)],
        [('A5', 4), ('C6', 4), ('E6', 4), ('C6', 4)],
        [('D6', 8), ('F#5', 4), ('A5', 4)],
        # A'
        [('B4', 4), ('D5', 4), ('G5', 6), ('F#5', 2)],
        [('A5', 8), ('F#5', 4), ('D5', 4)],
        [('E5', 4), ('G5', 4), ('B5', 6), ('A5', 2)],
        [('G5', 8), ('E5', 4), ('C5', 4)],
        [('D5', 4), ('G5', 4), ('B5', 4), ('D6', 4)],
        [('D6', 4), ('B5', 4), ('F#5', 8)],
        [('E5', 4), ('G5', 4), ('C6', 4), ('E6', 4)],
        # walks down to D, back into the B4 that opens A
        [('D6', 4), ('C6', 2), ('B5', 2), ('A5', 4), ('F#5', 2), ('D5', 2)],
    ],
)

# Cathedral dungeon: A minor, 80 BPM - slow and uneasy. An organ-like chord
# pad carries it, the melody is sparse, and the harmony leans on the dark
# half-step (Bb over A minor) and a diminished chord. No hi-hat; a soft kick
# only on the downbeat, like a distant toll.
DUNGEON = dict(
    bpm=80, peak=0.75, loop_from_bar=2,
    lead_vol=0.26, lead_duty=0.25, arp_vol=0.045, arp_div=2, arp_from=2,
    pad=True, pad_vol=0.06, bass_vol=0.38, drum_vol=0.16, drums_from=2, hats=False,
    bass_pattern=['R', '-', '-', '-', '-', '-', '-', '-'],
    kick=[0], snare=[],
    chords=(
        ['Am', 'Am'] +                                           # intro: organ alone
        ['Am', 'Am', 'Bb', 'Am', 'Dm', 'Dm', 'E', 'E'] +         # A
        ['F', 'E', 'Am', 'G#dim', 'Dm', 'Bb', 'E', 'E']          # B
    ),
    lead=[
        [('r', 16)],
        [('r', 16)],
        # A
        [('E5', 8), ('C5', 4), ('B4', 4)],
        [('A4', 12), ('r', 4)],
        [('D5', 8), ('F5', 4), ('E5', 4)],
        [('E5', 12), ('r', 4)],
        [('F5', 8), ('A5', 4), ('G5', 4)],
        [('F5', 4), ('E5', 4), ('D5', 8)],
        [('G#5', 8), ('B5', 4), ('G#5', 4)],
        [('E5', 12), ('r', 4)],
        # B
        [('A5', 8), ('C6', 4), ('A5', 4)],
        [('G#5', 8), ('E5', 8)],
        [('C6', 8), ('B5', 4), ('A5', 4)],
        [('B5', 8), ('D6', 4), ('B5', 4)],
        [('A5', 8), ('F5', 4), ('D5', 4)],
        [('F5', 8), ('D5', 4), ('Bb4', 4)],
        [('E5', 4), ('F5', 4), ('G#5', 4), ('B5', 4)],
        [('G#5', 12), ('r', 4)],
    ],
)

# Boss: E minor, 168 BPM - relentless. Syncopated kick, chromatic lead,
# the menacing flat-two chord (F in E minor) before each B-chord climax, and a
# turnaround run that drops straight back into the main riff.
BOSS = dict(
    bpm=168, peak=0.88, loop_from_bar=2,
    lead_vol=0.30, arp_vol=0.085, bass_vol=0.44, drum_vol=0.24, lead_duty=0.5,
    bass_pattern=['R', 'R', 'O', 'R', 'R', 'O', 'R', 'R'],
    kick=[0, 6, 8, 11, 14], snare=[4, 12],
    fills=[1, 9, 17, 25],
    chords=(
        ['Em', 'Em'] +                                          # intro
        ['Em', 'Em', 'C', 'D', 'Em', 'Em', 'F', 'B'] +          # A
        ['Am', 'Am', 'Em', 'Em', 'C', 'D', 'B', 'B'] +          # B
        ['Em', 'Em', 'C', 'D', 'Em', 'Em', 'F', 'B']            # A'
    ),
    lead=[
        [('r', 16)],
        # chromatic stabs climbing into the riff
        [('E5', 2), ('r', 2), ('E5', 2), ('r', 2), ('F5', 2), ('r', 2), ('F#5', 2), ('G5', 2)],
        # A
        [('B5', 4), ('E5', 2), ('G5', 2), ('B5', 2), ('C6', 2), ('B5', 4)],
        [('A5', 2), ('G5', 2), ('F#5', 4), ('E5', 8)],
        [('G5', 4), ('C6', 4), ('E6', 4), ('D6', 2), ('C6', 2)],
        [('D6', 6), ('C6', 2), ('A5', 4), ('F#5', 4)],
        [('E6', 4), ('B5', 2), ('G5', 2), ('E6', 2), ('F6', 2), ('E6', 4)],
        [('D6', 2), ('B5', 2), ('G5', 2), ('B5', 2), ('E5', 8)],
        [('F5', 4), ('A5', 4), ('C6', 4), ('F6', 4)],
        [('D#6', 8), ('F#6', 4), ('B5', 4)],
        # B
        [('C6', 6), ('B5', 2), ('A5', 8)],
        [('E6', 4), ('D6', 2), ('C6', 2), ('B5', 4), ('A5', 4)],
        [('G5', 6), ('F#5', 2), ('E5', 8)],
        [('B5', 2), ('C6', 2), ('B5', 2), ('A5', 2), ('G5', 4), ('B5', 4)],
        [('E6', 6), ('D6', 2), ('C6', 4), ('G5', 4)],
        [('F#6', 6), ('E6', 2), ('D6', 4), ('A5', 4)],
        [('B5', 2), ('C6', 2), ('B5', 2), ('A#5', 2), ('B5', 2), ('D#6', 2), ('F#6', 4)],
        [('B6', 12), ('r', 4)],
        # A'
        [('B5', 4), ('E5', 2), ('G5', 2), ('B5', 2), ('C6', 2), ('B5', 4)],
        [('A5', 2), ('G5', 2), ('F#5', 4), ('E5', 8)],
        [('G5', 4), ('C6', 4), ('E6', 4), ('D6', 2), ('C6', 2)],
        [('D6', 6), ('C6', 2), ('A5', 4), ('F#5', 4)],
        [('E6', 4), ('B5', 2), ('G5', 2), ('E6', 2), ('F6', 2), ('E6', 4)],
        [('D6', 2), ('B5', 2), ('G5', 2), ('B5', 2), ('E5', 8)],
        [('C6', 2), ('A5', 2), ('F5', 2), ('A5', 2), ('C6', 4), ('F6', 4)],
        # turnaround: tumbles down the B chord, back into the riff's B5
        [('F#6', 2), ('D#6', 2), ('B5', 2), ('A5', 2), ('F#5', 2), ('D#5', 2), ('B4', 2), ('D#5', 2)],
    ],
)

TRACKS = {'battle': BATTLE, 'overworld': OVERWORLD, 'dungeon': DUNGEON, 'boss': BOSS}


if __name__ == '__main__':
    out_dir = sys.argv[1]
    names = sys.argv[2:] or list(TRACKS)
    os.makedirs(out_dir, exist_ok=True)
    for name in names:
        tr = TRACKS[name]
        assert len(tr['lead']) == len(tr['chords']), (len(tr['lead']), len(tr['chords']))
        samples, ls, le = render_track(tr)
        write_looping_wav(os.path.join(out_dir, name + '.wav'), samples, ls, le)
        print('%-8s %.1fs total, loops %.1fs -> %.1fs' % (name, len(samples) / RATE, ls / RATE, le / RATE))
