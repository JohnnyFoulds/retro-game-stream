import numpy as np
import sounddevice as sd
import sys
import argparse
import random
import os
from midiutil import MIDIFile

# --- CLI ARGUMENT PARSER ---
parser = argparse.ArgumentParser(description="🎵 Unified Generative Engine")
parser.add_argument('-g', '--genre', 
    choices=['chiptune', 'chillstep', 'dubstep', 'piano', 'lofi', 
             'synthwave', 'ambient', 'acid'], default='acid')
parser.add_argument('-r', '--rule', type=int, default=30, 
    help="Wolfram CA Rule")
parser.add_argument('-b', '--bpm', type=int, default=140, 
    help="Tempo in BPM")
parser.add_argument('-s', '--seed', type=str, default="center", 
    help="Text seed")
parser.add_argument('-m', '--mood', type=str, 
    choices=['epic', 'happy', 'spooky', 'cyberpunk', 'chill', 'lofi', 
             'synthwave', 'ambient'], default='cyberpunk')
parser.add_argument('--melody', type=str, choices=['ca', 'motif'], 
    default='ca', help="CA math (default), or catchy pop motifs")
parser.add_argument('-v', '--volume', type=float, default=0.15, 
    help="Volume")
parser.add_argument('--fade_in', type=int, default=0, 
    help="Fade in over N bars")
parser.add_argument('-o', '--out_midi', type=str, default=None, 
    help="MIDI save path")
parser.add_argument('--bars', type=int, default=0, 
    help="Auto-stop after N bars")
args = parser.parse_args()

# --- DYNAMIC DEFAULTS ---
if args.genre == 'lofi' and args.bpm == 140: args.bpm = 75
if args.genre == 'synthwave' and args.bpm == 140: args.bpm = 110
if args.genre == 'ambient' and args.bpm == 140: args.bpm = 40
if args.genre == 'acid' and args.bpm == 140: args.bpm = 135

# --- CONFIGURATION & TIME SCALING ---
WIDTH = 66  
BEAT_DURATION = 60.0 / args.bpm

step_beats = 0.5 if args.genre == 'ambient' else 0.25
STEP_DURATION = BEAT_DURATION * step_beats
steps_per_bar = int(4.0 / step_beats)
SAMPLE_RATE = 44100

# --- DYNAMIC PLAYHEADS ---
CENTER = WIDTH // 2
MELODY_POS = CENTER - 2
BASS_POS = CENTER // 2
KICK_POS = CENTER + 10
SNARE_POS = CENTER + 15
HAT_POS = CENTER + 20

# --- MUSIC THEORY ---
MOODS = {
    'epic': [([57, 60, 64], "Am  "), ([53, 57, 60], "F   "), 
             ([48, 52, 55], "C   "), ([55, 59, 62], "G   ")],
    'happy': [([60, 64, 67], "C   "), ([55, 59, 62], "G   "), 
              ([57, 60, 64], "Am  "), ([53, 57, 60], "F   ")],
    'spooky': [([50, 53, 57], "Dm  "), ([46, 50, 53], "Bb  "), 
               ([43, 46, 50], "Gm  "), ([45, 49, 52], "A   ")],
    'cyberpunk': [([48, 51, 55], "Cm  "), ([44, 48, 51], "Ab  "), 
                  ([41, 44, 48], "Fm  "), ([43, 47, 50], "G   ")],
    'chill': [([53, 57, 60], "F   "), ([57, 60, 64], "Am  "), 
              ([48, 52, 55], "C   "), ([55, 59, 62], "G   ")],
    'lofi': [([50, 53, 57, 60], "Dm9 "), ([43, 47, 50, 53], "G13 "), 
             ([48, 52, 55, 59], "Cmj7"), ([45, 48, 52, 55], "Am7 ")],
    'synthwave': [([53, 57, 60], "F   "), ([55, 59, 62], "G   "), 
                  ([57, 60, 64], "Am  "), ([57, 60, 64], "Am  ")],
    'ambient': [([53, 57, 60, 64], "Fma9"), ([48, 52, 55, 59], "Cma9"), 
                ([52, 55, 59, 62], "Em7 "), ([57, 60, 64, 67], "Am11")]
}
if args.genre == 'synthwave' and args.mood == 'chill': args.mood = 'synthwave'
if args.genre == 'lofi' and args.mood == 'chill': args.mood = 'lofi'
if args.genre == 'ambient' and args.mood == 'chill': args.mood = 'ambient'
ACTIVE_MOOD = MOODS[args.mood]
PENTATONIC = [0, 3, 5, 7, 10, 12, 15, 17, 19, 22, 24]

# --- SYNTHESIZERS ---
def midi_to_freq(midi_note):
    return 440.0 * (2.0 ** ((midi_note - 69) / 12.0))

def apply_swing(wave):
    if len(wave) == 0 or isinstance(wave, int): return wave
    shift = int(SAMPLE_RATE * STEP_DURATION * 0.25)
    swung = np.zeros_like(wave)
    swung[shift:] = wave[:-shift]
    return swung

def apply_fade(wave, ratio=0.005):
    fade = int(SAMPLE_RATE * ratio)
    if len(wave) > fade * 2:
        wave[:fade] *= np.linspace(0, 1, fade)
        wave[-fade:] *= np.linspace(1, 0, fade)
    return wave

def generate_square_wave(freq, dur, vol, pw=0.5, pluck=False):
    samples = int(SAMPLE_RATE * dur)
    if freq == 0: return np.zeros(samples)
    t = np.linspace(0, dur, samples, False)
    wave = vol * np.where(np.sin(2 * np.pi * freq * t) > (pw * 2 - 1), 1, -1)
    if pluck: wave *= np.linspace(1, 0, samples) ** 2
    else: wave = apply_fade(wave)
    return wave

def generate_sawtooth_wave(freq, dur, vol, pluck=False):
    samples = int(SAMPLE_RATE * dur)
    if freq == 0: return np.zeros(samples)
    t = np.linspace(0, dur, samples, False)
    wave = vol * 2 * (freq * t - np.floor(freq * t + 0.5))
    if pluck: wave *= np.linspace(1, 0, samples) ** 2
    else: wave = apply_fade(wave)
    return wave

def generate_tb303_bass(freq, p_freq, dur, vol, slide=False, accent=False):
    samples = int(SAMPLE_RATE * dur)
    if freq == 0: return np.zeros(samples)
    t = np.linspace(0, dur, samples, False)
    
    if slide and p_freq > 0:
        freqs = np.linspace(p_freq, freq, samples)
        phases = np.cumsum(freqs) * 2 * np.pi / SAMPLE_RATE
    else:
        phases = 2 * np.pi * freq * t
        
    e_start = 6.0 if accent else 2.5
    decay = 12.0 if accent else 6.0
    env = np.exp(-decay * t) * e_start
    
    wave = np.sin(phases + env * np.sin(phases))
    wave = np.tanh(wave * 4.0) 
    
    vca = np.ones(samples) if slide else np.exp(-3.0 * t)
    return apply_fade(wave * vca * vol, 0.005)

def generate_sine_bell(freq, dur, vol):
    samples = int(SAMPLE_RATE * dur)
    if freq == 0: return np.zeros(samples)
    t = np.linspace(0, dur, samples, False)
    wave = vol * np.sin(2 * np.pi * freq * t)
    attack = int(SAMPLE_RATE * 0.05)
    if len(wave) > attack * 2:
        wave[:attack] *= np.linspace(0, 1, attack)
        wave[-attack:] *= np.linspace(1, 0, attack)
    return wave

def generate_ethereal_harp(freq, dur, vol):
    samples = int(SAMPLE_RATE * dur)
    if freq == 0: return np.zeros(samples)
    t = np.linspace(0, dur, samples, False)
    mod = np.sin(2 * np.pi * (freq * 2.0) * t) * 1.5
    wave = np.sin(2 * np.pi * freq * t + mod)
    return wave * np.exp(-3.0 * t / dur) * vol

def generate_chord_pad(f1, f2, f3, dur, vol, cur_time):
    samples = int(SAMPLE_RATE * dur)
    t = np.linspace(cur_time, cur_time + dur, samples, False)
    w1, w2, w3 = np.sin(2*np.pi*f1*t), np.sin(2*np.pi*f2*t), np.sin(2*np.pi*f3*t)
    lfo = np.sin(2 * np.pi * 0.2 * t) * 0.1 
    wave = (w1 + w2*0.8 + w3*0.6) * (0.9 + lfo) * vol
    return apply_fade(wave, 0.05)

def generate_fm_wobble_bass(freq, dur, vol, wub_hz, cur_time):
    samples = int(SAMPLE_RATE * dur)
    if freq == 0: return np.zeros(samples)
    t = np.linspace(cur_time, cur_time + dur, samples, False)
    lfo = (np.sin(2 * np.pi * wub_hz * t) + 1) / 2
    mod = np.sin(2 * np.pi * (freq * 2.0) * t)
    fm_wave = np.sin(2 * np.pi * freq * t + (lfo * 7.0) * mod)
    sub_wave = np.sin(2 * np.pi * (freq / 2) * t)
    return apply_fade((fm_wave * 0.5 + sub_wave * 0.9) * vol, 0.002)

def generate_piano_key(freq, dur, vol):
    samples = int(SAMPLE_RATE * dur)
    if freq == 0: return np.zeros(samples)
    t = np.linspace(0, dur, samples, False)
    w = np.sin(2*np.pi*freq*t) + 0.5*np.sin(2*np.pi*freq*2*t)
    w += 0.25*np.sin(2*np.pi*freq*3*t)
    return w * np.exp(-4 * t / dur) * vol

def generate_rhodes(freq, dur, vol):
    samples = int(SAMPLE_RATE * dur)
    if freq == 0: return np.zeros(samples)
    t = np.linspace(0, dur, samples, False)
    wave = np.sin(2 * np.pi * freq * t) + 0.3 * np.sin(2 * np.pi * freq * 2 * t)
    tremolo = 0.8 + 0.2 * np.sin(2 * np.pi * 4 * t) 
    return wave * tremolo * np.exp(-2.5 * t / dur) * vol

def generate_triangle_wave(freq, dur, vol):
    samples = int(SAMPLE_RATE * dur)
    if freq == 0: return np.zeros(samples)
    t = np.linspace(0, dur, samples, False)
    w = vol * 2 * np.abs(2 * (freq * t - np.floor(freq * t + 0.5))) - 1
    return apply_fade(w)

def generate_kick(dur, vol, style='standard'):
    samples = int(SAMPLE_RATE * dur)
    f_start = 90 if style == 'lofi' else 150
    freqs = np.linspace(f_start, 20, samples) 
    phases = np.cumsum(freqs) * 2 * np.pi / SAMPLE_RATE
    d_curve = 1.5 if style == 'lofi' else 3
    wave = np.sin(phases) * vol * (np.linspace(1, 0, samples) ** d_curve)
    if style in ['dubstep', 'acid']: wave = np.clip(wave * 2.0, -vol, vol) 
    if style == 'synthwave': wave = np.clip(wave * 1.5, -vol, vol) 
    return wave

def generate_snare(dur, vol, style='standard'):
    samples = int(SAMPLE_RATE * dur)
    f_start, f_end = (400, 300) if style == 'lofi' else (200, 100)
    t_vol, n_vol = (0.5, 0.2) if style == 'lofi' else (0.8, 1.0)
    freqs = np.linspace(f_start, f_end, samples)
    phases = np.cumsum(freqs) * 2 * np.pi / SAMPLE_RATE
    tone = np.sin(phases) * t_vol
    noise = np.random.uniform(-1, 1, samples) * n_vol
    wave = (tone + noise) * vol
    
    if style == 'synthwave':
        gate_p = int(samples * 0.7)
        env = np.ones(samples)
        env[gate_p:] = np.linspace(1, 0, samples - gate_p) ** 8
        return wave * env
    else:
        d_curve = 8 if style == 'lofi' else (2 if style == 'dubstep' else 4)
        return wave * (np.linspace(1, 0, samples) ** d_curve)

def generate_hihat(dur, vol, is_open=False):
    samples = int(SAMPLE_RATE * dur)
    noise = np.random.uniform(-1, 1, samples)
    d_curve = 2.0 if is_open else 8.0 
    return noise * vol * (np.linspace(1, 0, samples) ** d_curve)

def generate_vinyl_crackle(dur, vol):
    samples = int(SAMPLE_RATE * dur)
    noise = np.random.uniform(-0.1, 0.1, samples) * 0.5
    pops = np.random.binomial(1, 0.0005, samples) 
    return (noise + pops * np.random.uniform(0.5, 1.0, samples)) * vol

# --- ENGINES ---
def get_next_state(state, rule):
    next_state = np.zeros_like(state)
    for i in range(len(state)):
        left = state[i-1] if i > 0 else state[-1]
        center = state[i]
        right = state[i+1] if i < len(state)-1 else state[0]
        idx = (left << 2) | (center << 1) | right
        next_state[i] = (rule >> idx) & 1
    return next_state

def initialize_state(seed_str):
    state = np.zeros(WIDTH, dtype=int)
    if seed_str == "center": state[CENTER] = 1
    else:
        random.seed(seed_str)
        for i in range(WIDTH): state[i] = random.randint(0, 1)
    return state

def generate_hook():
    pattern = [None] * 16
    grooves = [
        [1,0,0,1, 0,0,1,0, 1,0,0,1, 0,0,0,0],
        [1,0,1,0, 1,0,0,0, 1,0,1,0, 0,1,0,0],
        [0,1,0,1, 0,0,1,0, 0,1,0,1, 0,0,1,0],
        [1,0,0,0, 1,0,1,0, 1,0,0,0, 1,1,0,0] 
    ]
    groove = random.choice(grooves)
    scale_idx = 4 
    for i in range(16):
        if groove[i] == 1:
            scale_idx += random.choice([-2, -1, 0, 1, 2])
            scale_idx = max(0, min(scale_idx, len(PENTATONIC)-1))
            pattern[i] = PENTATONIC[scale_idx]
    return pattern

# --- MAIN LOOP ---
def main():
    state = initialize_state(args.seed)
    stream = sd.OutputStream(samplerate=SAMPLE_RATE, channels=1, 
                             dtype='float32')
    stream.start()
    
    midi = MIDIFile(1)
    midi.addTempo(0, 0, args.bpm)
    
    melody_history = [np.zeros(int(SAMPLE_RATE * STEP_DURATION))] * 16
    step_counter = 0
    current_hook = generate_hook()
    prev_bass_freq = 0.0 
    
    # --- CROSSFADE MATH ---
    master_vol = 0.0 if args.fade_in > 0 else 1.0
    fade_in_step = 1.0 / (args.fade_in * steps_per_bar) if args.fade_in>0 else 0
    fade_out_step = 1.0 / (4 * steps_per_bar) # 4-bar fade out
    fade_out_triggered = False
    
    try:
        while True:
            # Catch file flag from the DJ Script!
            if os.path.exists(f"fade_{os.getpid()}.flag"):
                fade_out_triggered = True
                os.remove(f"fade_{os.getpid()}.flag")

            if args.bars > 0 and step_counter >= (args.bars * steps_per_bar):
                fade_out_triggered = True

            bar = (step_counter // steps_per_bar)
            chord_idx = bar % len(ACTIVE_MOOD)
            current_chord_notes, chord_name = ACTIVE_MOOD[chord_idx]
            
            state = get_next_state(state, args.rule)
            step_in_bar = step_counter % steps_per_bar
            
            if args.melody == 'motif' and step_in_bar == 0 and chord_idx == 0:
                current_hook = generate_hook()
            
            is_swung = args.genre == 'lofi' and step_in_bar % 2 != 0
            c_beat = (step_counter * step_beats) + (0.0625 if is_swung else 0)
            
            # --- 1. MELODY LOGIC ---
            arp_play = False
            cur_arp = np.zeros(int(SAMPLE_RATE * STEP_DURATION))
            
            if args.melody == 'motif':
                i_mod = step_in_bar if args.genre != 'ambient' else \
                        (step_in_bar * 2) % 16
                hook_val = current_hook[i_mod]
                if hook_val is not None:
                    arp_play = True
                    note_midi = current_chord_notes[0] + hook_val
                    note_freq = midi_to_freq(note_midi + 12)
            else:
                arp_pool = []
                for n in current_chord_notes: arp_pool.append(n)
                for n in current_chord_notes: arp_pool.append(n + 12)
                while len(arp_pool) < 8: arp_pool.append(arp_pool[-1])
                
                a_idx = (state[MELODY_POS]<<2) | (state[MELODY_POS+1]<<1) | \
                        state[MELODY_POS+2]
                high_g = args.genre in ['chillstep', 'dubstep', 'lofi', 
                                        'synthwave', 'ambient', 'acid']
                note_midi = arp_pool[a_idx] + (12 if high_g else 0)
                note_freq = midi_to_freq(note_midi)
                
                if args.genre == 'ambient':
                    arp_play = state[MELODY_POS+3] == 1 
                elif args.genre == 'acid':
                    arp_play = state[MELODY_POS+3] == 1 and step_in_bar in [2, 10]
                elif args.genre == 'dubstep':
                    arp_play = state[MELODY_POS+3] == 1 and state[MELODY_POS+4] == 1
                elif args.genre == 'chillstep':
                    arp_play = state[MELODY_POS+3] == 1 and step_in_bar % 2 == 0
                elif args.genre == 'lofi':
                    arp_play = state[MELODY_POS+3] == 1 and \
                               (step_in_bar % 2 == 0 or state[MELODY_POS+4] == 1)
                else:
                    arp_play = state[MELODY_POS+3] == 1 

            if arp_play:
                if args.genre == 'ambient':
                    cur_arp = generate_ethereal_harp(note_freq, STEP_DURATION, 
                                                     args.volume * 1.5)
                elif args.genre == 'acid':
                    cur_arp = generate_square_wave(note_freq, STEP_DURATION, 
                                                   args.volume * 0.4, 0.2)
                elif args.genre == 'chillstep':
                    cur_arp = generate_sine_bell(note_freq, STEP_DURATION, 
                                                 args.volume * 1.2)
                elif args.genre == 'dubstep':
                    cur_arp = generate_square_wave(note_freq, STEP_DURATION, 
                                                   args.volume * 0.8, 0.8)
                elif args.genre == 'piano':
                    cur_arp = generate_piano_key(note_freq, STEP_DURATION, 
                                                 args.volume * 2.0)
                elif args.genre == 'lofi':
                    cur_arp = generate_rhodes(note_freq, STEP_DURATION, 
                                              args.volume * 2.5)
                elif args.genre == 'synthwave':
                    cur_arp = generate_sawtooth_wave(note_freq, STEP_DURATION, 
                                                     args.volume * 0.7, True)
                else:
                    cur_arp = generate_square_wave(note_freq, STEP_DURATION, 
                                                   args.volume)
            
            arp_wave = cur_arp.copy()
            if args.genre == 'ambient':
                arp_wave += (melody_history[-3] * 0.5) + (melody_history[-6]*0.25)
            elif args.genre in ['chillstep', 'synthwave']:
                arp_wave += (melody_history[-3] * 0.4)
            elif args.genre in ['dubstep', 'acid']:
                arp_wave += (melody_history[-3] * 0.3)
            elif args.genre == 'piano':
                arp_wave += (melody_history[-4] * 0.3)

            if arp_play: 
                midi.addNote(0, 0, note_midi, c_beat, step_beats, 100)
            melody_history.append(cur_arp)
            melody_history.pop(0)
            
            # --- 2. BASS LOGIC ---
            bass_midi = current_chord_notes[0] - 24
            bass_wave = np.zeros(int(SAMPLE_RATE * STEP_DURATION))
            play_bass = False
            
            if args.genre == 'ambient':
                play_bass = True
                f1 = midi_to_freq(current_chord_notes[0] - 12)
                f2 = midi_to_freq(current_chord_notes[1] - 12)
                f3 = midi_to_freq(current_chord_notes[2] - 12)
                bass_wave = generate_chord_pad(f1, f2, f3, STEP_DURATION, 
                                args.volume * 1.5, step_counter * STEP_DURATION)
            elif args.genre == 'acid':
                play_bass = state[BASS_POS] == 1 or step_in_bar % 4 == 0
                bass_midi += 12 if state[BASS_POS+1] == 1 else 0
                is_slide = state[BASS_POS+2] == 1
                is_acc = state[BASS_POS+3] == 1
                if play_bass:
                    target_f = midi_to_freq(bass_midi)
                    bass_wave = generate_tb303_bass(target_f, prev_bass_freq, 
                                    STEP_DURATION, args.volume * 2.0, 
                                    slide=is_slide, accent=is_acc)
                    prev_bass_freq = target_f if is_slide else 0.0
                else:
                    prev_bass_freq = 0.0
            elif args.genre in ['chillstep', 'lofi']:
                play_bass = True if args.genre == 'chillstep' else \
                            (step_in_bar in [0, 8, 10])
                if play_bass: 
                    bass_wave = generate_triangle_wave(midi_to_freq(bass_midi), 
                                    STEP_DURATION, args.volume * 2.5)
            elif args.genre == 'dubstep':
                play_bass = not (state[BASS_POS+1] == 1 and step_in_bar % 4 == 3) 
                bass_midi += 12 
                wub_hz = (args.bpm / 60.0) * (2 if state[BASS_POS] == 1 else 1)
                if play_bass: 
                    bass_wave = generate_fm_wobble_bass(midi_to_freq(bass_midi), 
                                    STEP_DURATION, args.volume * 2.5, wub_hz, 
                                    step_counter * STEP_DURATION)
            elif args.genre == 'piano':
                play_bass = (step_in_bar % 4 == 0 or 
                             (state[BASS_POS] == 1 and step_in_bar % 2 == 0))
                bass_midi += 12
                if play_bass: 
                    bass_wave = generate_piano_key(midi_to_freq(bass_midi), 
                                    STEP_DURATION, args.volume * 3.0)
            elif args.genre == 'synthwave':
                play_bass = step_in_bar % 2 == 0 
                bass_midi += 12 if (state[BASS_POS]==1 and state[BASS_POS+1]==1) else 0
                if play_bass: 
                    bass_wave = generate_sawtooth_wave(midi_to_freq(bass_midi), 
                                    STEP_DURATION, args.volume * 1.5, True)
            else:
                tr_rhythm = [1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0]
                play_bass = (tr_rhythm[step_in_bar] == 1 or 
                             (state[BASS_POS] == 1 and state[BASS_POS+1] == 1))
                bass_midi += 12 if state[BASS_POS] == 1 else 0 
                if play_bass: 
                    bass_wave = generate_square_wave(midi_to_freq(bass_midi), 
                                    STEP_DURATION, args.volume * 1.5, 0.25, True)

            if play_bass: 
                dur = 1.0 if args.genre in ['chillstep', 'ambient'] else step_beats
                midi.addNote(0, 1, bass_midi, c_beat, dur, 100)

            # --- 3. DRUM LOGIC ---
            play_kick = play_snare = play_hat = is_open_hat = False
            
            if args.genre in ['piano', 'ambient']:
                pass 
            elif args.genre == 'acid':
                play_kick = step_in_bar % 4 == 0
                play_snare = step_in_bar in [4, 12]
                play_hat = step_in_bar % 2 != 0 or state[HAT_POS] == 1
                is_open_hat = step_in_bar % 2 != 0
            elif args.genre == 'lofi':
                play_kick = (step_in_bar == 0 or 
                             (state[KICK_POS] == 1 and step_in_bar in [7, 10]))
                play_snare = step_in_bar in [4, 12] 
                play_hat = step_in_bar % 2 == 0 or state[HAT_POS] == 1
            elif args.genre in ['chillstep', 'dubstep']:
                play_kick = (step_in_bar == 0 or 
                             (state[KICK_POS] == 1 and step_in_bar in [10, 14]))
                play_snare = step_in_bar == 8 
                play_hat = step_in_bar % 2 == 0 or state[HAT_POS] == 1 
            elif args.genre == 'synthwave':
                play_kick = step_in_bar % 4 == 0
                play_snare = step_in_bar in [4, 12]
                play_hat = step_in_bar % 2 != 0 or state[HAT_POS] == 1
            else:
                shift_k = 9 if state[KICK_POS] == 1 else 8
                play_kick = step_in_bar == 0 or step_in_bar == shift_k
                play_snare = (step_in_bar in [4, 12] or 
                              (state[SNARE_POS] == 1 and state[SNARE_POS+1] == 1 
                               and step_in_bar not in [0, 8]))
                play_hat = step_in_bar % 2 == 0 or state[HAT_POS] == 1

            if play_kick: midi.addNote(0, 9, 36, c_beat, step_beats, 120)
            if play_snare: 
                v = 100 if step_in_bar in [4, 8, 12] else 50
                midi.addNote(0, 9, 38, c_beat, step_beats, v)
            if play_hat: 
                h_note = 46 if is_open_hat else 42
                midi.addNote(0, 9, h_note, c_beat, step_beats, 80)

            kick_wave = np.zeros(int(SAMPLE_RATE * STEP_DURATION))
            snare_wave = np.zeros(int(SAMPLE_RATE * STEP_DURATION))
            hat_wave = np.zeros(int(SAMPLE_RATE * STEP_DURATION))
            
            if play_kick:
                k_vol = 3.5 if args.genre=='lofi' else 4.0
                kick_wave = generate_kick(STEP_DURATION, args.volume * k_vol, 
                                          args.genre)
            if play_snare:
                s_vol = 2.0 if args.genre=='lofi' else 2.5
                snare_wave = generate_snare(STEP_DURATION, args.volume * s_vol, 
                                            args.genre)
                if step_in_bar not in [4, 8, 12] and args.genre != 'synthwave': 
                    snare_wave *= 0.4 
            if play_hat:
                hat_wave = generate_hihat(STEP_DURATION, args.volume * 0.8, 
                                          is_open=is_open_hat)

            if is_swung:
                arp_wave = apply_swing(arp_wave)
                bass_wave = apply_swing(bass_wave)
                kick_wave = apply_swing(kick_wave)
                snare_wave = apply_swing(snare_wave)
                hat_wave = apply_swing(hat_wave)

            crackle = np.zeros(int(SAMPLE_RATE * STEP_DURATION))
            if args.genre == 'lofi':
                crackle = generate_vinyl_crackle(STEP_DURATION, args.volume * 0.7)

            mixed_step = arp_wave + bass_wave + kick_wave + \
                         snare_wave + hat_wave + crackle
                         
            # --- CROSSFADE VOLUME LOGIC ---
            if fade_out_triggered:
                master_vol -= fade_out_step
                if master_vol <= 0: break # Gracefully exit the script!
            elif master_vol < 1.0:
                master_vol += fade_in_step
                if master_vol > 1.0: master_vol = 1.0
                
            mixed_step *= master_vol
            
            # --- PRINT VISUALS ---
            k_str = "K" if play_kick else "-"
            s_str = "S" if play_snare else "-"
            h_str = "H" if play_hat else "-"
            b_str = "B" if play_bass else "-"
            
            if args.melody == 'motif' and args.genre != 'ambient':
                visual = "🎵" if arp_play else "  "
            else:
                visual = "".join(['█' if cell else ' ' for cell in state])
            
            sys.stdout.write(f"\r[{chord_name}] [{k_str}{s_str}{h_str}{b_str}] {visual}".ljust(70))
            sys.stdout.flush()
            
            if args.melody == 'motif' and step_in_bar == 15 and args.genre != 'ambient': 
                print("") 
            elif args.melody == 'ca' or args.genre == 'ambient':
                print("")
            
            audio_out = mixed_step.astype(np.float32).reshape(-1, 1)
            stream.write(audio_out)
            step_counter += 1
            
        # Exited loop naturally (faded out completely)
        stream.stop()
        stream.close()

    except KeyboardInterrupt:
        stream.stop()
        stream.close()
        if args.out_midi:
            with open(args.out_midi, "wb") as output_file:
                midi.writeFile(output_file)

if __name__ == "__main__":
    main()
