# ADR-U-0003 — Composition model uses a CA-gated rule-based hybrid

**Status:** Accepted
**Date:** 2026-07-08

## Context

The musical engine must drive note selection, rhythm, and dynamics for two
independent voices (melody and accompaniment) indefinitely without exact repetition
(FR-2). It must satisfy several compositional constraints simultaneously:

- Melody moves predominantly by step; large leaps are rare and resolved by contrary
  motion (FR-13)
- Accompaniment places at least one note per bar on the downbeat in a register at
  least one octave below the melody (FR-14)
- Dynamic variation: velocity must vary per note in a musically motivated way (FR-15)
- The same seed always produces the same output (FR-2)
- The music must be listenable for 30 minutes without fatigue (BR-3)

Four composition models were identified during scoping:

| Model | Description |
|-------|-------------|
| **CA-only** | Wolfram 1D cellular automaton drives all musical decisions, as in `ca_synth.py` |
| **Markov chain** | Transition probabilities over scale degrees; trained or hand-authored |
| **Rule-based voice leading** | Explicit compositional rules: stepwise preference, leap resolution, avoid parallel fifths |
| **Hybrid** | CA provides rhythm and gate decisions; rule-based logic constrains note selection |

## Decision

Use a **CA-gated, rule-based hybrid** composition model.

**CA layer — rhythm and gating:**
- A Wolfram 1D CA (configurable rule, default Rule 30) advances one step per
  musical step.
- Specific bit positions in the CA row are mapped to musical gates:
  - Melody gate: 1 = note fires this step, 0 = rest
  - Accompaniment gate: interpreted per-pattern (e.g., in Alberti bass, the CA
    selects which Alberti position fires on non-downbeat steps)
  - Phrase boundary: a bit or combination of bits signals a phrase restart, which
    triggers the leap allowance in FR-13
- CA width is fixed at 32 cells. Bit assignments are named constants, not magic
  numbers.
- The CA is initialised from the `--seed` string using the same `initialize_state`
  approach as `ca_synth.py`: seed `"center"` lights the centre cell; any other
  seed uses `random.seed(seed_str)` to scatter bits pseudo-randomly.

**Rule layer — note selection:**
- At each step where the melody gate fires, a candidate note is selected from the
  current chord tones and their octave transpositions within `[MELODY_LOW, MELODY_HIGH]`.
- The candidate is accepted if it is within `MAX_MELODY_INTERVAL` semitones of the
  previous note (FR-13). If no candidate passes, the closest chord tone within the
  interval limit is used.
- At phrase boundaries (signalled by a CA bit), a leap of up to 12 semitones is
  permitted. The next note after a leap must move in the opposite direction by step
  (leap-then-resolve rule).
- The accompaniment pattern (Alberti, broken chord, sustained, stride) is selected
  per mood at startup and does not change within a run. The rule layer enforces the
  register constraint: the highest accompaniment note must be at least 2 semitones
  below the lowest melody note on each step.
- Beat 1 of each bar always fires the accompaniment bass note regardless of the CA
  gate, satisfying FR-14.

**`EngineState` structure:**

```python
from dataclasses import dataclass
import numpy as np

@dataclass
class EngineState:
    ca_row: np.ndarray      # shape (CA_WIDTH,), dtype int; current CA row
    step: int               # global step counter (0-indexed)
    prev_melody_note: int | None   # last melody note played (None at start)
    phrase_step: int        # steps elapsed in the current phrase (0-indexed)
    phrase_length: int      # phrase length in steps (64 or 128; selected at phrase boundary)
    phrase_high_note: int   # highest melody note seen in this phrase (for velocity shaping)
    rng: random.Random      # seeded RNG instance for stochastic elements
```

**Accompaniment patterns per mood:**

| Mood | Pattern |
|------|---------|
| `classical` | Alberti bass (root–fifth–third–fifth) |
| `romantic` | Broken chord (root up, then chord tones ascending) |
| `nocturne` | Sustained bass (root on beat 1, chord on beats 2–4) |
| `waltz` | Stride (bass note alternates with mid-register chord) |
| `ragtime` | Stride (faster alternation; bass on beats 1 and 3) |
| `ambient` | Sustained bass (whole-bar root with inner voices on beat 3) |

**Chord progressions per mood:**

All progressions are in 4/4 time and cycle every `CHORD_DURATION_BARS = 2` bars
(8 bars per full cycle). Root note is derived from the seed: `root = 48 + (hash(seed) % 12)`,
clamped to the accompaniment register.

| Mood | Progression (Roman numerals, major unless noted) |
|------|--------------------------------------------------|
| `classical` | I → IV → V → I (C major: C–F–G–C) |
| `romantic` | i → VI → III → VII (A minor: Am–F–C–G) |
| `nocturne` | i → iv → V → i (D minor: Dm–Gm–A–Dm) |
| `waltz` | I → V → V → I (G major: G–D–D–G) |
| `ragtime` | I → IV → I → V (F major: F–Bb–F–C) |
| `ambient` | Imaj7 → IVmaj7 → iiim7 → vim7 (F: Fmaj7–Bbmaj7–Am7–Dm7) |

Each chord entry in `MOODS` is a list of MIDI note numbers giving the root voicing
in the accompaniment register, following the same structure as `ca_synth.py`'s
`MOODS` dict.

**`CHORD_DURATION_BARS`:** 2 bars (resolved from TBD in §2.2). This gives a harmonic
rhythm of one chord change every 32 steps — slow enough to feel compositional, fast
enough to prevent monotony over a 30-minute run.

**Velocity layer weights** (§2.11 — resolved from TBD):

The three velocity layers are combined as:

```
v_struct  = structural accent component (beat 1 → 90, beat 3 → 75, others → 60)
v_phrase  = phrase shape component (0–20, peaks at phrase climax bar)
v_noise   = rng.randint(-10, 10)  (from EngineState.rng)
velocity  = clamp(v_struct + v_phrase + v_noise, VELOCITY_MIN, VELOCITY_MAX)
```

The `compute_velocity` signature is updated to accept `rng: random.Random` as a
parameter (see spec fix in feature-spec.md).

**Tonic selection strategy** (§2.3 — resolved from TBD):
Root note = `48 + (int(hashlib.md5(seed.encode()).hexdigest(), 16) % 12)`.
Using MD5 (not `hash()`) ensures the result is stable across Python versions and
platforms. The `hashlib` module is added to the dependency list.

## Motivation

**CA layer satisfies FR-2 without repetition.** A CA driven by Rule 30 or similar
rules produces aperiodic, unpredictable output indefinitely. This is the proven
approach from `ca_synth.py` — its non-repeating property is the core reason to
keep it.

**Rule layer satisfies FR-13 and FR-14 directly.** A pure CA driving note selection
has no mechanism to enforce stepwise motion or register separation. These are
compositional constraints that the CA cannot express as a sequence of bits — they
require checking the interval between successive notes, which is inherently a rule.
Adding rule-based post-processing to CA output is the natural way to combine their
strengths.

**Markov chains considered and deferred.** Markov transition matrices can produce
smooth melodic lines, but they require either hand-authored probability tables (per
mood, per scale) or a training corpus — neither of which is available. The
rule-based layer achieves the same stepwise motion property with explicit, auditable
logic rather than learned probabilities.

**Pure rule-based voice leading alone would repeat.** Explicit compositional rules
without a stochastic or chaotic driver tend to converge on similar patterns within
a few bars. The CA provides the variability; the rules provide the constraint.

Alternatives considered and not chosen:

| Alternative | Reason not chosen |
|-------------|-------------------|
| CA-only | Cannot enforce interval constraints (FR-13) or register separation without additional logic, which is effectively the rule layer anyway |
| Markov chain | Requires training data or manual probability tables; adds significant design work without a clear quality advantage over the hybrid |
| Rule-based only | Deterministic rules converge on repeated patterns; does not satisfy FR-2 (no exact repetition) without a noise source, which is effectively the CA |

## Consequences

**Enables:**
- Non-repeating output driven by CA aperiodicity (FR-2 satisfied)
- Melodic lines that stay within the interval constraint (FR-13 satisfied by the
  rule layer)
- Accompaniment always places a note on the downbeat (FR-14 satisfied by the rule
  override on beat 1)
- Deterministic output from a text seed (CA initialisation is seeded; RNG in
  `EngineState.rng` is seeded from the same string)
- `EngineState` is a dataclass — serialisable, inspectable, and easy to unit-test

**Rules out:**
- Per-step CA rule selection (the CA rule is fixed per run, not user-configurable
  via `--rule`; this is intentional — the piano script has no `--rule` argument)
- Purely emergent voice leading (the rule layer is explicit, not learned)

**Watch for:**
- The phrase boundary detection (via a CA bit) must be guarded against false
  positives from noisy CA rows. A phrase boundary should fire at most once every
  `MIN_PHRASE_BARS` bars (minimum phrase length); shorter phrase boundaries produce
  an erratic, non-musical feel
- The leap-then-resolve rule (FR-13) requires the note *after* a phrase-boundary
  leap to move by step in the opposite direction. `select_melody_note` must track
  whether the previous note was a leap and enforce the resolution constraint on
  the current step, overriding the CA gate if necessary
- `hashlib` must be added to the import list in §3.6 of the feature spec (small
  addition; `hashlib` is a stdlib module with no new package dependency)
