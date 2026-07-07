# 🎵 Generative CA Music Engine & Stream DJ

An infinite, DMCA-free, Turing-complete procedural music generator written in pure Python. 

This project uses **Stephen Wolfram's 1D Cellular Automata (CA)** and **Algorithmic Motif Generation** to mathematically synthesize infinite, non-repeating music in real-time. It was designed specifically for live-coding streams and indie game developers. It does not use any pre-recorded audio files; every kick drum, synth pad, and lo-fi vinyl crackle is generated from pure math 44,100 times a second.

Includes a **Synthesizer Engine** (`ca_synth.py`) and a **Turing-Complete Radio DJ** (`stream_dj.py`) that uses fractal math to infinitely compose playlists and crossfade tracks.

## ✨ Features
*   **8 Distinct Genres:** Chiptune, Lo-Fi Hip Hop, Synthwave, Dubstep, Acid Techno, Chillstep, Ambient Drone, and Acoustic Piano.
*   **Live-Coding Ready:** The DJ script dynamically watches for code changes. If you edit the synthesizer code while the stream is running, the DJ will automatically crossfade into your new code!
*   **MIDI Export:** Instantly export the generative math into standard `.mid` files to drop into your DAW, Game Engine, or retro DOS project.
*   **Visual Metronome:** The terminal acts as a live visualizer, scrolling the Cellular Automata binary fractals and drum trackers in perfect sync with your sound card.
*   **100% DMCA-Safe:** Generated locally on your machine via math. You own it.

---

## 🛠️ Installation

You only need Python and three lightweight libraries. 

1. Install the audio math and MIDI dependencies:
```bash
pip install numpy sounddevice MIDIUtil
```
2. Download `ca_synth.py` and `stream_dj.py` into the same folder.

---

## 🎹 1. The Synthesizer (`ca_synth.py`)

This is the core audio engine. You can run it completely standalone to generate a single infinite track.

### Basic Usage
```bash
python ca_synth.py --genre lofi --mood lofi --seed "coffee_shop"
```

### CLI Arguments
| Argument | Short | Description | Default |
| :--- | :--- | :--- | :--- |
| `--genre` | `-g` | `chiptune`, `chillstep`, `dubstep`, `piano`, `lofi`, `synthwave`, `ambient`, `acid` | `acid` |
| `--mood` | `-m` | Changes chord progression: `epic`, `happy`, `spooky`, `cyberpunk`, `chill`, `lofi`, `synthwave`, `ambient` | `cyberpunk` |
| `--melody` | | `ca` (Wandering fractal math) or `motif` (Catchy pop hooks) | `ca` |
| `--rule` | `-r` | Wolfram CA Rule (0-255). Rule 30 is chaotic, 90 is fractal. | `30` |
| `--bpm` | `-b` | Tempo in Beats Per Minute. | Varies by genre |
| `--seed` | `-s` | Text string to deterministically seed the song. | `"center"` |
| `--volume`| `-v` | Master Volume (0.0 to 1.0) | `0.15` |
| `--out_midi`| `-o` | Filename to save MIDI sheet music (e.g., `track.mid`) | `None` |
| `--bars` | | Auto-stop and save after N bars (Great for exporting game loops) | `0` (Infinite) |
| `--fade_in`| | Number of bars to fade the volume in (Used by the DJ script) | `0` |

### Awesome Combinations to Try:
**The 1980s Hacker Vibe:**
```bash
python ca_synth.py -g synthwave -m cyberpunk --melody motif -s "neon_grid"
```
**Deep Space Focus (No Drums, Generative Delay Buffer):**
```bash
python ca_synth.py -g ambient -s "interstellar"
```
**Underground Acid Rave:**
```bash
python ca_synth.py -g acid -m spooky -s "vampire_club"
```

---

## 🎛️ 2. The Radio DJ (`stream_dj.py`)

If you want a 24/7 background radio for your stream, run the DJ script. 

```bash
python stream_dj.py
```

### How it Works:
1. **Rule 110 Playlist Generation:** Instead of randomly shuffling tracks, the DJ uses its own Turing-Complete Cellular Automaton (Rule 110) to mathematically select the genre, mood, and track duration. The playlist naturally evolves over time!
2. **Seamless Crossfading:** It runs one instance of the synth, waits a few minutes, spawns a second instance, and gracefully fades the volume between them so there is never dead air.
3. **Hot-Reloading:** The DJ automatically scans your folder for the newest file matching `ca_synth*.py`. You can actively program new synthesizers and math algorithms on your stream, hit save, and the DJ will seamlessly crossfade into your updated code on the next track.

---

## 💾 Exporting to MIDI (For Game Devs)

Because generating math in real-time takes CPU power, you might want to bake a track to use in a game engine (like Unity, Godot, or Turbo Pascal!). 

You can instruct the script to play for exactly 16 bars, generate the MIDI data, and save it to a file.

```bash
python ca_synth.py -g chiptune -m epic --melody motif --bars 16 -o level_1_theme.mid
```
* **Channel 0:** Melody / Lead Synth
* **Channel 1:** Bassline
* **Channel 9 (MIDI standard 10):** Drum Kit

You can now drop `level_1_theme.mid` into any DAW (Ableton, GarageBand) or Game Engine and assign whatever virtual instruments you like to the algorithmic sheet music!
