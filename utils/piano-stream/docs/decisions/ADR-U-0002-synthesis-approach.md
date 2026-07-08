# ADR-U-0002 — Piano synthesis uses Karplus-Strong physical modelling

**Status:** Accepted
**Date:** 2026-07-08

## Context

The core acoustic requirement (BR-1) is that the output must sound like a grand
piano to a listener who does not know it is procedurally generated — not a
synthesiser approximation. NFR-7 makes this concrete: the waveform must have a
percussive attack transient, harmonic overtone content, and an exponential decay.

Two synthesis approaches were identified during scoping:

**Option A — Additive synthesis**
Sum the fundamental and several harmonics as sine waves, each with its own
exponential amplitude envelope. The envelope shapes (attack, decay time, initial
amplitude per partial) are chosen to approximate the frequency-dependent behaviour
of a real piano string.

**Option B — Karplus-Strong physical modelling**
Initialise a short delay line (length = sample rate / frequency) with a burst of
noise or an impulse. Each sample, apply a single-pole low-pass averaging filter
across the delay line. The natural resonance of the feedback loop produces harmonic
content; the low-pass filter causes the high harmonics to decay faster than the
fundamental, which matches real string physics.

## Decision

Use **Karplus-Strong physical modelling** (Option B) as the synthesis method for
all piano notes in `piano_stream.py`.

Implementation:

1. On note-on, initialise a delay line of length `N = round(SAMPLE_RATE / freq)`
   with white noise scaled by `velocity`.
2. Each output sample: `y[n] = 0.5 * (buf[n % N] + buf[(n-1) % N])` where `buf`
   is the delay line being read and written simultaneously.
3. Apply a tuning correction (fractional delay or frequency-domain adjustment) to
   place the pitch accurately when `N` is not an integer.
4. To model the attack transient (§2.5 requirement 1), add a brief noise burst at
   note start with amplitude `ATTACK_SCALE` (≥ 2× sustain amplitude) before the
   KS loop takes over.
5. `NOTE_DECAY_FACTOR` is register-dependent: lower notes use a longer decay
   constant (`stretch factor > 1`), implemented by occasionally skipping the
   averaging step on low-register notes (extended Karplus-Strong).

The concrete constants (`ATTACK_SCALE`, per-register `NOTE_DECAY_FACTOR` values)
are determined during implementation and recorded in §3.4 of the feature spec once
tuned by ear.

## Motivation

**Physical accuracy by construction.** Karplus-Strong produces the correct harmonic
relationships automatically — the delay-line resonance enforces integer-multiple
partials. Additive synthesis requires manual tuning of each partial's amplitude and
decay rate to approximate the same result, with no physical reason why the values
should be correct.

**Frequency-dependent decay for free.** Real piano strings decay faster in the
treble than in the bass because the high-frequency harmonics lose energy to the
low-pass averaging more quickly. Karplus-Strong replicates this without any explicit
per-register parameter: the averaging filter has a stronger relative effect on high
harmonics. (The extended KS stretch factor adds further register-dependent control
for low notes, but the basic effect is inherent.)

**Thin sound problem.** The spec itself notes that additive synthesis "can sound thin
without careful harmonic weighting." Karplus-Strong avoids this because the harmonic
content emerges from the noise initialisation rather than being explicitly summed.
A noise-seeded delay line naturally produces many partials.

**CPU cost is acceptable.** A Karplus-Strong delay line for the lowest piano note
(A0, 27.5 Hz at 44100 Hz sample rate) is approximately 1600 samples long. With at
most 6–8 simultaneous voices, the total memory footprint is a few kilobytes. The
per-sample computation is two array reads and one write — negligible on a modern
laptop (NFR-4).

Alternatives considered and not chosen:

| Alternative | Reason not chosen |
|-------------|-------------------|
| Additive synthesis | Requires careful per-partial tuning to avoid sounding synthetic; harder to achieve BR-1 without significant parameter work; "thin" risk cited in spec |
| Wavetable synthesis | Requires sampled data, violating BR-2 (DMCA-safe, no pre-recorded audio) |
| FM synthesis | Efficient but difficult to tune to a convincing piano timbre without replicating a hardware FM piano patch |

## Consequences

**Enables:**
- Physically motivated harmonic content that satisfies NFR-7 without manual tuning
  of individual harmonics
- Frequency-dependent decay that sounds natural across the keyboard range
- Compact implementation (the KS loop fits in one function, `synthesise_note`)
- Register-dependent sustain via the stretch-factor extension, satisfying §2.5
  requirement 3 (`NOTE_DECAY_MS` varies by register)

**Rules out:**
- Per-partial amplitude and decay control (not needed; KS handles this implicitly)
- Arbitrary spectral shaping of individual harmonics without modifying the filter
  design

**Watch for:**
- Karplus-Strong pitch accuracy degrades when `N = SAMPLE_RATE / freq` is not an
  integer. A fractional delay correction (all-pass filter or linear interpolation)
  must be applied to keep the pitch within 5 cents of true pitch — especially
  important in the melody register where tuning errors are audible
- The noise initialisation is seeded by the script's global `random.Random` instance
  (derived from `--seed`). To preserve determinism (FR-2), the KS delay line must
  be initialised from the seeded RNG, not from `os.urandom` or `time.time`
- Attack transient amplitude (`ATTACK_SCALE`) must be calibrated so that it is
  clearly percussive (≥ 2× sustain) but does not cause the soft-clip limiter to
  fire on every note
