# PianoStream

## Changelog

| Date | Change | Triggered by |
| --- | --- | --- |
| 2026-07-07 | Initial draft | Session 1 |

---

## 1. Requirements

### 1.1 Business / Product Requirements

| ID | Requirement |
| --- | --- |
| BR-1 | The script must produce music that sounds like a grand piano playing well-composed music — not a synthesiser approximation — to a listener who does not know it is procedurally generated. |
| BR-2 | The music must be DMCA-safe: generated entirely from mathematics with no sampled or pre-recorded audio. |
| BR-3 | The music must be suitable as stream background music for a live-coding session: non-irritating, continuously evolving, and listenable for at least 30 minutes without fatigue. |
| BR-4 | The script must export standard MIDI files usable in a Turbo Pascal 7 DOS game without post-processing. |
| BR-5 | The script must be compatible with `stream_dj.py` crossfade infrastructure so it can participate in a multi-genre DJ playlist alongside `ca_synth.py`. |

### 1.2 Functional Requirements

| ID | Requirement |
| --- | --- |
| FR-1 | The script SHALL synthesise piano audio in real time and stream it to the default audio output device. |
| FR-2 | The script SHALL generate music that never exactly repeats, driven by a deterministic seed so the same seed always produces the same output. |
| FR-3 | The script SHALL support a `--mood` parameter selecting the harmonic character of the music from a fixed set of named moods, each defining a chord progression. |
| FR-4 | The script SHALL support a `--bpm` parameter controlling the tempo in beats per minute. |
| FR-5 | The script SHALL support a `--seed` parameter accepting a text string that deterministically initialises the generative engine. |
| FR-6 | The script SHALL support a `--volume` parameter controlling the master output level (0.0 to 1.0). |
| FR-7 | The script SHALL support a `--bars` parameter that stops the script after exactly N bars and saves the MIDI file if `--out_midi` is set. When `--bars` is 0 the script runs indefinitely. |
| FR-8 | The script SHALL support a `--out_midi` parameter specifying a file path to which a MIDI file is written on exit. |
| FR-9 | The script SHALL support a `--fade_in` parameter specifying the number of bars over which the master volume fades from 0 to full on startup, for use by the DJ crossfade system. |
| FR-10 | The script SHALL respond to a `fade_<pid>.flag` file written by the DJ script by triggering a graceful fade-out and clean exit, compatible with `stream_dj.py` IPC protocol. |
| FR-11 | The script SHALL display a terminal visualiser each step showing the current chord, active voices, and a representation of the generative state. |
| FR-12 | The script SHALL generate a left-hand accompaniment part and a right-hand melody part, kept in separate pitch registers, mixed into a single mono or stereo audio stream. |
| FR-13 | The melody voice SHALL move predominantly by stepwise motion (intervals of a second or third), with occasional larger leaps resolved by contrary motion. |
| FR-14 | The bass / accompaniment voice SHALL place at least one note per bar on the downbeat, in a register at least one octave below the melody. |
| FR-15 | The script SHALL apply dynamic variation: individual notes SHALL vary in velocity (loudness) to avoid a mechanical, uniform sound. |
| FR-16 | The MIDI export SHALL assign General MIDI program 0 (Acoustic Grand Piano) to all melodic and bass channels via a program-change message at the start of each channel. |
| FR-17 | The MIDI export SHALL use note velocity values derived from the musical engine (not a fixed constant) on every note event. |
| FR-18 | The MIDI export SHALL emit clean note-off messages so notes do not hang when imported into a DAW or DOS playback library. |

### 1.3 Non-Functional Requirements

| ID | Requirement |
| --- | --- |
| NFR-1 | The script must run on Python 3.10 or later with no dependencies beyond `numpy`, `sounddevice`, and `midiutil`. |
| NFR-2 | Audio output latency must not cause audible glitches on a modern laptop under normal load. The per-step audio buffer must be written to the output stream synchronously (blocking write), matching the approach in `ca_synth.py`. |
| NFR-3 | The script must accept the same `--fade_in` / flag-file IPC protocol as `ca_synth.py` so that `stream_dj.py` can manage it without modification. |
| NFR-4 | CPU usage during normal playback must not prevent the host machine from running a coding session and screen-capture simultaneously. |
| NFR-5 | The MIDI export must be importable into GarageBand, Ableton Live, and standard MIDI sequencers without errors. |
| NFR-6 | The script must produce a terminal visualiser output that is legible at 80 columns, consistent with the project's 80-character line-length standard. |
| NFR-7 | The piano synthesis must produce a recognisable piano timbre: a percussive attack transient, harmonic overtone content, and an exponential decay — not a sustained tone. |

### 1.4 Constraints & Assumptions

- The script targets a single output file: `utils/piano-stream/piano_stream.py`.
- The script is a utility, not part of the game source. Pascal coding standards do not apply. Python 3.10+ conventions apply.
- The DJ compatibility constraint (NFR-3) is non-negotiable: the flag-file IPC and `--fade_in` argument must work exactly as in `ca_synth.py`.
- **MIDI target hardware:** *(TBD — ADR-U-0001)* The MIDI export format and feature set (velocity resolution, pitch bend, program change) will be finalised once the target DOS playback hardware is decided. Until then, the export targets General MIDI as the broadest compatible baseline.
- **Piano synthesis approach:** *(TBD — ADR-U-0002)* The synthesis method — physical modelling (Karplus-Strong) vs. additive harmonic synthesis — has not been decided. This decision determines the implementation of FR-1 and NFR-7 entirely. Both approaches satisfy the requirements as stated; the ADR will record which is chosen and why.
- **Composition model:** *(TBD — ADR-U-0003)* The generative mechanism driving note selection — CA-based (as in `ca_synth.py`), Markov chain, rule-based voice leading, or a hybrid — has not been decided. This decision determines how FR-2, FR-13, and FR-15 are implemented. The requirements are written to be model-agnostic; the ADR will record the choice.
- **Mood set:** The named moods and their chord progressions are not yet defined. They will be listed in §2.3 once the composition model (ADR-U-0003) is settled, as the chord voicings depend on the voice-leading approach.
- **Stereo vs mono:** The `ca_synth.py` baseline is mono. Whether the piano output is mono or stereo is an open question. Stereo panning of melody vs. accompaniment is a significant quality improvement but adds output channel complexity. This will be decided during Phase 1 requirements authoring and reflected in §3.
- **Python standards:** No formal Python coding standard has been defined for this utility. The script should follow PEP 8, use type hints on all function signatures, and carry docstrings on all public functions. A formal standard may be defined later.
- The script must not import any game-specific Pascal utilities or depend on any file in `games/`.
- The `stream_dj.py` script discovers synth scripts by globbing `ca_synth*.py`. This script is named `piano_stream.py` and will therefore not be auto-discovered by the DJ unless the DJ is extended. DJ integration details are deferred to FR-10 and §2.7.

---

## 2. Functional Specification

### 2.1 Overview

`piano_stream.py` is a self-contained procedural piano music generator. It runs
indefinitely (or for a fixed number of bars) generating music that sounds like
a grand piano playing composed music, streaming audio to the system output device
in real time and optionally writing a MIDI file on exit.

```text
piano_stream.py
├── Generative engine                ← drives all musical decisions each step
│     ├── Harmonic framework         ← chord progression, bar/beat/step clock
│     ├── Melody voice               ← right-hand: stepwise melodic line
│     └── Accompaniment voice        ← left-hand: bass + inner voices
│
├── Synthesis engine                 ← converts note events to audio waveforms
│     ├── Piano synthesiser          ← attack transient + harmonic decay
│     └── Mixer / limiter            ← sums voices, applies master volume, soft-clips
│
├── MIDI recorder                    ← records note events in parallel with audio
│
└── Output layer
      ├── Audio stream               ← sounddevice.OutputStream, blocking writes
      ├── MIDI file                  ← midiutil.MIDIFile, written on exit
      └── Terminal visualiser        ← chord / voice / state display each step
```

The generative engine produces musical events (note-on, note-off, velocity) each
step. The synthesis engine converts those events to audio. The MIDI recorder
captures the same events independently. The two output paths share the same
musical decisions but are otherwise decoupled — synthesis quality improvements
do not affect MIDI output, and MIDI feature additions do not affect audio quality.

The script is intentionally scoped to **piano only**. It does not inherit the
multi-genre architecture of `ca_synth.py`. There are no drum voices, no bass
synthesisers other than the piano bass register, and no non-piano timbres.

### 2.2 Time Model

The time model follows `ca_synth.py` exactly to ensure DJ compatibility.

```
Bar
└── beats_per_bar (4 for 4/4 time)
      └── steps_per_beat (4 — 16th note resolution)
            └── STEP_DURATION = (60.0 / bpm) * 0.25  seconds
                └── samples_per_step = int(44100 * STEP_DURATION)
```

One step is one 16th note. One bar is 16 steps. The main loop advances one step
per iteration, generating exactly `samples_per_step` audio samples per iteration
and writing them to the output stream.

The harmonic rhythm (chord change frequency) is independent of the step clock.
Chords change every `CHORD_DURATION_BARS` bars, which is a configurable constant.
*(TBD — exact value depends on ADR-U-0003 composition model.)*

### 2.3 Harmonic Framework

The harmonic framework defines the chord progressions available via `--mood`.
Each mood is a list of chords; each chord is a list of MIDI note numbers giving
the root voicing. The progression cycles repeatedly. The melody and accompaniment
voices both derive their note choices from the current chord.

**Mood definitions:** *(TBD — ADR-U-0003)*
The exact chord progressions for each mood will be defined once the composition
model is decided. The moods will cover at minimum:

| Mood | Character | Example progression |
| --- | --- | --- |
| `classical` | Formal, resolved | I → IV → V → I in major |
| `romantic` | Expressive, chromatic | i → VI → III → VII in minor |
| `nocturne` | Quiet, introspective | i → iv → V → i (Chopin-style minor) |
| `waltz` | Light, dancing | I → V → V → I (3/4 feel within 4/4) |
| `ragtime` | Syncopated, bright | I → IV → I → V in major |
| `ambient` | Slow, open | Extended chords, slow harmonic rhythm |

The `--mood` default is `nocturne`.

All chord voicings use MIDI note numbers. The root note of the progression is
derived from the seed (deterministic) or from a fixed tonic. *(TBD — tonic
selection strategy depends on ADR-U-0003.)*

### 2.4 Voice Architecture

The piano texture is divided into two voices. This maps to the physical layout
of piano music on the grand staff.

#### Right hand — Melody voice

- Register: MIDI notes 60–84 (middle C to C6)
- Role: the primary melodic line, one note per step (with rests)
- Motion constraint: consecutive notes must be within 7 semitones (a perfect
  fifth) of each other, except at phrase boundaries where a leap of up to 12
  semitones (one octave) is permitted
- Phrase length: 4 or 8 bars; at each phrase boundary the melody may leap and
  then resolve by stepwise motion in the opposite direction
- Rest probability: configurable; default produces rests on approximately 20%
  of steps, preventing a continuous stream of notes

#### Left hand — Accompaniment voice

- Register: MIDI notes 36–60 (C2 to middle C)
- Role: harmonic support; bass note on beat 1 of each bar plus inner voices
  on subsequent beats
- Pattern: *(TBD — ADR-U-0003)* options include:
  - **Alberti bass** — root, fifth, third, fifth repeated (classical)
  - **Broken chord** — root then upper chord tones arpeggiated
  - **Sustained bass** — root on beat 1, chord on beats 2–4
  - **Stride** — bass note alternating with mid-register chord (jazz/ragtime)
- The accompaniment pattern is selected per mood, not per step

The two voices are synthesised independently and summed. They must not overlap
in register: the highest accompaniment note must be at least 2 semitones below
the lowest melody note at every step.

### 2.5 Piano Synthesis

*(TBD — ADR-U-0002 will determine which approach is implemented)*

The synthesis engine must produce a waveform with the following observable
properties for any given note, regardless of approach:

1. **Attack transient** — a sharp amplitude peak within the first 10ms of the
   note, simulating hammer strike. The peak amplitude must be at least 2× the
   sustain amplitude.
2. **Harmonic content** — the waveform must contain at minimum the fundamental
   frequency and the 2nd, 3rd, and 4th harmonics, with amplitudes decreasing
   with harmonic number.
3. **Exponential decay** — amplitude must decay to ≤10% of peak within
   `NOTE_DECAY_MS` milliseconds. `NOTE_DECAY_MS` varies by register: lower
   notes decay more slowly than higher notes, consistent with piano physics.
4. **No sustained tone** — unlike a sine bell or organ, the note must reach
   near-silence before the next note in the same voice begins (unless a
   sustain/pedal effect is explicitly modelled).
5. **No audible aliasing** — the waveform must not produce clearly audible
   high-frequency artefacts above the intended harmonic content.

Two candidate approaches will be evaluated in ADR-U-0002:

**Option A — Additive synthesis**
Sum the fundamental and harmonics as sine waves with individually decaying
envelopes. Each partial has its own amplitude and decay rate. Computationally
cheap, predictable, but can sound thin without careful harmonic weighting.

**Option B — Physical modelling (Karplus-Strong)**
Initialise a delay line with noise or an impulse, then apply a low-pass
averaging filter each sample. The resonant decay naturally produces harmonic
content. More physically realistic. Slightly more complex to implement.

### 2.6 Mixer and Output

All active voice waveforms are summed each step to produce a single mixed
buffer. A soft-clip limiter is applied before writing to the output stream
to prevent hard clipping when multiple voices overlap.

Soft-clip formula:
```python
mixed = np.tanh(mixed * drive) / drive
```
where `drive` is a constant controlling the headroom before clipping onset.
*(TBD — exact `drive` value to be determined during implementation.)*

The master volume scalar (`--volume`, 0.0–1.0) is applied after the limiter.
The fade-in and fade-out crossfade envelope is applied after master volume.

Output is written to `sounddevice.OutputStream` at 44100 Hz, 1 channel
(mono), `float32`. *(Stereo is deferred — see §1.4 constraints.)*

### 2.7 MIDI Export

The MIDI file records all note events generated by the musical engine in
parallel with audio synthesis. The MIDI and audio paths share note decisions
but are otherwise independent.

#### Channel assignments

| Channel | Content | GM Program |
| --- | --- | --- |
| 0 | Melody (right hand) | 0 — Acoustic Grand Piano |
| 1 | Accompaniment (left hand) | 0 — Acoustic Grand Piano |

#### Note events

Every note that fires in the audio engine is also written to the MIDI file:
- `midi.addNote(channel, 0, midi_note, beat_time, duration, velocity)`
- `beat_time` is the current beat position as a float (step × step_beats)
- `duration` is `step_beats` for melody notes; accompaniment notes may be
  longer if the pattern holds a note across multiple steps
- `velocity` is derived from the musical engine (FR-17), not hardcoded

#### Program change

A `midi.addProgramChange(channel, 0, 0, program=0)` call is emitted at beat 0
for both channels before any note events, assigning GM patch 0 (Acoustic Grand
Piano) to both channels (FR-16).

#### Note-off behaviour

`midiutil.MIDIFile` generates note-off messages automatically from note
duration. The implementation must ensure note durations do not overlap within
a channel — a new note on a channel must not start before the previous note's
duration has elapsed, or the note-off for the previous note will arrive after
the note-on for the new note, causing the new note to be cut short on some
playback devices.

#### MIDI file write

The MIDI file is written on:
- Clean exit after `--bars` bars (FR-7)
- Ctrl+C interrupt
- Completion of fade-out triggered by flag file (FR-10)

It is not written on abnormal exit (crash).

### 2.8 DJ Compatibility and IPC

`piano_stream.py` must participate in the `stream_dj.py` crossfade system.
The IPC protocol is flag-file based, inherited from `ca_synth.py`.

#### Fade-in on startup

When `--fade_in N` is passed, the master volume starts at 0.0 and increments
by `1.0 / (N * steps_per_bar)` each step until it reaches 1.0. This creates
a smooth volume fade-in over N bars.

#### Fade-out on DJ request

Each step, the script checks for the existence of `fade_<os.getpid()>.flag`.
If the file exists, it is deleted and a fade-out is triggered: the master
volume decrements by `1.0 / (4 * steps_per_bar)` each step (4-bar fade out).
When master volume reaches 0 or below, the main loop exits and the MIDI file
is written.

This protocol is identical to `ca_synth.py` and requires no changes to
`stream_dj.py` to support this script as a drop-in synth.

**Note:** `stream_dj.py` auto-discovers synth scripts by globbing `ca_synth*.py`.
`piano_stream.py` does not match this pattern. To use this script with the DJ,
either: (a) rename or symlink to `ca_synth_piano.py`, or (b) pass
`--synth piano_stream.py` to a future extended DJ. *(Resolution deferred.)*

### 2.9 Terminal Visualiser

One line is printed per bar (not per step) to avoid terminal flooding.
The line format:

```
[<mood>] [Bar <N>] [<chord_name>] M:<melody_note> A:<accomp_pattern> vol=<master_vol>
```

Example:
```
[nocturne] [Bar  12] [Cm  ] M:D4  A:alberti   vol=1.00
```

Fields:
- `mood` — the active mood name, fixed width 10
- `Bar N` — current bar number, right-aligned in 4 digits
- `chord_name` — current chord name, fixed width 6
- `M:` — the melody note name at beat 1 of this bar (or `--` if a rest)
- `A:` — the accompaniment pattern name
- `vol=` — current master volume (reflects fade-in / fade-out)

The visualiser must fit within 80 columns (NFR-6).

### 2.10 Error Behaviour

| Condition | Behaviour |
| --- | --- |
| `--volume` outside [0.0, 1.0] | Exits immediately with `ValueError: volume must be between 0.0 and 1.0` |
| `--bpm` ≤ 0 | Exits immediately with `ValueError: bpm must be greater than 0` |
| `--bars` < 0 | Exits immediately with `ValueError: bars must be 0 (infinite) or a positive integer` |
| `--mood` not in known mood list | Exits immediately with `ValueError: unknown mood '<value>'. Choose from: <list>` |
| `sounddevice.OutputStream` fails to open | Prints error message to stderr and exits with code 1 |
| `--out_midi` path is not writable | Prints warning to stderr; continues playing; MIDI file is not written on exit |
| Ctrl+C | Stops audio stream cleanly; writes MIDI file if `--out_midi` is set; exits with code 0 |
| Synthesis produces NaN or Inf samples | Replaces affected buffer with silence; prints one-line warning to stderr |

### 2.11 Velocity Model

Velocity (MIDI 0–127, audio amplitude scalar) varies per note to create
musical dynamics. The velocity model has three layers:

1. **Structural accents** — beat 1 of each bar is louder than other beats;
   beat 3 is louder than beats 2 and 4. This is a fixed pattern independent
   of the generative state.
2. **Phrase shape** — velocity rises toward the phrase climax (typically bar
   3 of a 4-bar phrase) and falls away afterward. The climax is the highest
   note in the phrase.
3. **Generative variation** — a small random perturbation (±10 MIDI velocity
   units) is applied per note to prevent mechanical uniformity.

The three layers are combined multiplicatively. The result is clamped to
[20, 110] to prevent inaudible notes and distortion.

*(The exact weights for each layer are TBD pending ADR-U-0003 — the
composition model determines which layer is most musically significant.)*

---

## 3. Technical Specification

### 3.1 File and Directory Layout

```text
utils/piano-stream/
├── piano_stream.py          ← the complete script (single file)
├── docs/
│   ├── feature-spec.md      ← this document
│   ├── requirements.md      ← requirement list (cross-reference to §1)
│   ├── technical-design.md  ← I/P/Q/N contracts per requirement
│   ├── traceability-matrix.md
│   └── decisions/
│       ├── ADR-U-0001-midi-target.md
│       ├── ADR-U-0002-synthesis-approach.md
│       └── ADR-U-0003-composition-model.md
└── tests/
    └── manual-acceptance-tests.md
```

The entire utility is self-contained within `utils/piano-stream/`. Nothing
outside this directory depends on it. It does not import from `games/` or
`docs/standards/`.

### 3.2 CLI Interface

```python
parser = argparse.ArgumentParser(description="🎹 Procedural Grand Piano Stream")
parser.add_argument('-m', '--mood',    type=str,   default='nocturne',
    choices=[...],       help="Chord mood / harmonic character")
parser.add_argument('-b', '--bpm',     type=int,   default=72,
    help="Tempo in beats per minute")
parser.add_argument('-s', '--seed',    type=str,   default='center',
    help="Text seed for deterministic generation")
parser.add_argument('-v', '--volume',  type=float, default=0.15,
    help="Master volume (0.0–1.0)")
parser.add_argument('--fade_in',       type=int,   default=0,
    help="Fade in over N bars (used by DJ script)")
parser.add_argument('-o', '--out_midi', type=str,  default=None,
    help="MIDI output file path")
parser.add_argument('--bars',          type=int,   default=0,
    help="Stop after N bars (0 = infinite)")
```

No `--genre` argument exists — this script is piano only. No `--rule`
argument exists — the CA rule (if used) is an internal constant, not
exposed to the user. No `--melody` argument exists — the composition
model is fixed, not user-selectable.

### 3.3 Module Structure

The script is a single file. Internally it is organised into named sections
with `# ---` dividers, in this order:

```
# --- CLI ARGUMENT PARSER ---
# --- CONFIGURATION & TIME SCALING ---
# --- MUSIC THEORY: MOODS & CHORDS ---
# --- GENERATIVE ENGINE ---          (TBD: CA / Markov / rule-based per ADR-U-0003)
# --- PIANO SYNTHESISER ---          (TBD: additive / Karplus-Strong per ADR-U-0002)
# --- MIXER ---
# --- VELOCITY MODEL ---
# --- MIDI RECORDER ---
# --- TERMINAL VISUALISER ---
# --- MAIN LOOP ---
```

### 3.4 Key Constants

| Constant | Value | Notes |
| --- | --- | --- |
| `SAMPLE_RATE` | `44100` | Hz; matches `ca_synth.py` |
| `STEP_BEATS` | `0.25` | One 16th note = 0.25 beats |
| `STEPS_PER_BAR` | `16` | 4/4 time at 16th note resolution |
| `MIDI_MELODY_CHANNEL` | `0` | Right-hand voice |
| `MIDI_ACCOMP_CHANNEL` | `1` | Left-hand voice |
| `MELODY_LOW` | `60` | C4 — lowest melody note (MIDI) |
| `MELODY_HIGH` | `84` | C6 — highest melody note (MIDI) |
| `ACCOMP_LOW` | `36` | C2 — lowest accompaniment note (MIDI) |
| `ACCOMP_HIGH` | `60` | C4 — highest accompaniment note (MIDI, exclusive) |
| `MAX_MELODY_INTERVAL` | `7` | Semitones; max step-to-step interval in melody |
| `VELOCITY_MIN` | `20` | MIDI velocity floor |
| `VELOCITY_MAX` | `110` | MIDI velocity ceiling |
| `NOTE_DECAY_FACTOR` | TBD | Decay rate per register — ADR-U-0002 |
| `FADE_OUT_BARS` | `4` | Fixed fade-out duration for DJ crossfade |

### 3.5 Function Signatures

The following signatures define the public interface of the script's internal
functions. All functions are module-level (no class).

```python
# --- GENERATIVE ENGINE ---

def initialise_engine(seed: str) -> EngineState:
    """
    Initialise the generative engine state from a text seed.
    Returns an opaque EngineState object used by all subsequent calls.
    The internal representation depends on ADR-U-0003.
    """

def advance_engine(state: EngineState) -> EngineState:
    """
    Advance the engine by one step and return the new state.
    Called once per step in the main loop.
    """

def select_melody_note(
    state: EngineState,
    chord: list[int],
    prev_note: int | None,
    step_in_bar: int,
) -> int | None:
    """
    Select the melody note for the current step.
    Returns a MIDI note number, or None for a rest.
    Enforces MAX_MELODY_INTERVAL constraint against prev_note.
    """

def select_accomp_notes(
    state: EngineState,
    chord: list[int],
    step_in_bar: int,
    pattern: str,
) -> list[int]:
    """
    Select accompaniment notes for the current step.
    Returns a list of MIDI note numbers (may be empty for rests within pattern).
    """

# --- PIANO SYNTHESISER ---

def synthesise_note(
    midi_note: int,
    duration: float,
    velocity: float,
) -> np.ndarray:
    """
    Synthesise a single piano note.
    Returns a float32 numpy array of length int(SAMPLE_RATE * duration).
    Implementation determined by ADR-U-0002.
    """

# --- VELOCITY MODEL ---

def compute_velocity(
    step_in_bar: int,
    step_in_phrase: int,
    phrase_length: int,
    midi_note: int,
    phrase_high_note: int,
) -> int:
    """
    Compute MIDI velocity (20–110) for a note event.
    Combines structural accent, phrase shape, and generative variation.
    """

# --- MIXER ---

def mix_and_limit(buffers: list[np.ndarray], master_vol: float) -> np.ndarray:
    """
    Sum audio buffers, apply soft-clip limiter, apply master volume.
    Returns a float32 array suitable for writing to the output stream.
    """
```

**Note on `EngineState`:** The type and structure of `EngineState` is
intentionally left abstract here. It will be defined concretely once
ADR-U-0003 decides the composition model. If CA-based, it is a numpy
integer array. If Markov-based, it is a dictionary of transition state.
If rule-based, it may be a dataclass. The function signatures above are
stable regardless of this choice.

### 3.6 Dependency Constraints

`piano_stream.py` may import only:

| Import | Purpose |
| --- | --- |
| `numpy` | Audio buffer arithmetic, waveform generation |
| `sounddevice` | Audio output stream |
| `midiutil` | MIDI file construction and writing |
| `argparse` | CLI argument parsing |
| `os` | Flag file detection (`os.path.exists`, `os.getpid`, `os.remove`) |
| `sys` | `sys.stdout`, `sys.stderr`, `sys.exit` |
| `random` | Seeded pseudo-random number generation |
| `math` | `math.floor`, `math.exp`, `math.pi` |

No other dependencies. The script must be runnable with:
```bash
pip install numpy sounddevice MIDIUtil
python piano_stream.py
```

### 3.7 Acceptance Test Summary

Full acceptance tests are in `tests/manual-acceptance-tests.md`. The
following are the primary observable criteria referenced in §1:

| Test ID | Requirement | Observable criterion |
| --- | --- | --- |
| T-001 | FR-1, NFR-7 | Script starts and produces audio within 2 seconds |
| T-002 | BR-1, NFR-7 | A listener identifies the output as piano music within 10 seconds |
| T-003 | FR-2, FR-5 | Same `--seed` value produces identical output on two separate runs |
| T-004 | FR-13 | Inspecting MIDI export shows no consecutive melody notes more than 7 semitones apart (except at bar boundaries) |
| T-005 | FR-14 | Every bar in the MIDI export contains at least one note below MIDI 60 on channel 1 |
| T-006 | FR-15, FR-17 | MIDI export shows at least 3 distinct velocity values across any 16-bar passage |
| T-007 | FR-16 | MIDI export contains program-change 0 on channel 0 and channel 1 at beat 0 |
| T-008 | FR-9, FR-10 | Writing `fade_<pid>.flag` causes the script to fade out and exit within 4 bars |
| T-009 | NFR-3 | `stream_dj.py` can launch and crossfade `piano_stream.py` without modification |
| T-010 | BR-3 | Script runs for 30 minutes without crash, audio glitch, or terminal freeze |
| T-011 | FR-8, FR-7 | `--bars 16 --out_midi test.mid` produces a valid MIDI file and exits cleanly |
| T-012 | NFR-6 | Terminal visualiser output is ≤80 columns per line |

### 3.8 Open Questions and TBD Items

The following items remain open and will be resolved by ADRs or during
Phase 1 requirements authoring. Each blocks a specific part of the spec.

| Item | Blocks | Resolution path |
| --- | --- | --- |
| MIDI target hardware (DOS) | §2.7, FR-16, FR-17, FR-18 | ADR-U-0001 |
| Piano synthesis approach | §2.5, §3.5 `synthesise_note`, NFR-7 | ADR-U-0002 |
| Composition model | §2.3, §2.4, §2.11, §3.5 `EngineState` | ADR-U-0003 |
| Chord progressions per mood | §2.3 mood table | After ADR-U-0003 |
| Accompaniment pattern selection per mood | §2.4 left-hand section | After ADR-U-0003 |
| Stereo vs mono output | §2.6, §3.4 `SAMPLE_RATE` channels | Phase 1 discussion |
| DJ discovery (`ca_synth*.py` glob) | §2.8 note | Phase 1 or separate DJ change |
| `NOTE_DECAY_FACTOR` per register | §3.4 constants table | After ADR-U-0002 |
| `CHORD_DURATION_BARS` value | §2.2 time model | After ADR-U-0003 |
| `drive` constant for soft-clip | §2.6 mixer | Implementation phase |
| Tonic selection strategy | §2.3 mood definitions | After ADR-U-0003 |
| Velocity layer weights | §2.11 velocity model | After ADR-U-0003 |
| Python coding standard | §1.4 constraints | Deferred |
