# SDD Plan — Piano Stream Music Generator

## What this document is

This is a pre-SDD planning document. It answers the questions that must be
resolved before requirements can be written:

- What are we actually building?
- What decisions must be made before the spec can be authored?
- What does the SDD loop look like for a utility (not a game)?
- What is the right order of work?

Read this document before touching any requirements, code, or ADRs.

---

## 1. What we are building

A standalone Python script (`piano_stream.py`) that generates infinite,
procedural piano music suitable for:

1. **Stream background music** — runs live in a terminal window while coding
   on camera; must sound like a real grand piano playing well-composed music
2. **MIDI export** — outputs a `.mid` file for use in the TP7 DOS game

The two use cases share the same musical engine. The audio synthesis path
serves use case 1; the MIDI export path serves use case 2. Improvements to
the musical structure benefit both; improvements to raw audio synthesis
benefit only use case 1.

This is a util, not the game. It lives in `utils/piano-stream/`, not in
`games/`. The project standards apply to the SDD process and documentation;
the coding standards (Pascal style, build standard) do not apply to Python.

---

## 2. Architectural questions to resolve before writing requirements

These are the decisions that gate what requirements can exist. Each will
become an ADR in `docs/decisions/`. They must be answered first.

### Q1: What is the MIDI target for the game?

The piano MIDI export will be played back on DOS hardware. The available
targets are:

- **OPL2/OPL3 FM synthesis** (AdLib / Sound Blaster) — most common; uses FM
  patches; a "piano" patch exists but sounds thin
- **General MIDI / MPU-401** — richer piano patches; depends on Sound Blaster
  AWE or Roland MT-32/SC-55 being present
- **PC speaker** — one voice only; piano music is essentially impossible

The answer determines which MIDI features matter (velocity, program change,
pitch bend) and what limitations to design around.

**Action:** Decide the target hardware and record as ADR-U-0001.

### Q2: What is the piano synthesis approach for live audio?

Two options:

- **Physical modelling** — simulate string resonance, hammer strike, and
  soundboard using DSP (Karplus-Strong algorithm or more sophisticated
  variants). Produces realistic, natural sound. Moderate complexity.
- **Additive synthesis** — sum harmonics (fundamental + overtones with
  exponential decay). Faster to implement. Sounds more like a toy piano.

The choice determines the synthesis requirements entirely.

**Action:** Decide and record as ADR-U-0002.

### Q3: What is the musical composition model?

The source script uses CA bits to drive musical decisions within a chord
framework. For piano music specifically, several alternatives exist:

- **Keep CA driving** — same mechanism, different synthesis and musical
  constraints. Familiar code path, proven to produce non-repeating output.
- **Markov chain melody** — transition probabilities between scale degrees;
  produces more singable, idiomatic melodic lines.
- **Rule-based voice leading** — explicit compositional rules: avoid parallel
  fifths, prefer stepwise motion, resolve tendency tones. Most "composed"
  sounding but most complex to implement.
- **Hybrid** — CA for rhythm and structure decisions; rule-based voice leading
  for note selection.

The answer determines how musically sophisticated the output can be.

**Action:** Decide and record as ADR-U-0003.

### Q4: What does "well-composed piano music" mean concretely?

This is the most important question. Without a definition, acceptance criteria
cannot be written. Candidate concrete properties:

- Melody and bass occupy separate registers (no crossing voices)
- Melody moves predominantly by step (conjunct motion), with occasional leaps
  resolved by contrary motion
- Harmonic rhythm changes every 2 or 4 bars, not every step
- Dynamic variation: some notes louder than others (velocity)
- Pedal simulation: bass notes sustain while melody moves above
- Idiomatic piano patterns: Alberti bass, broken chords, rolled chords

**Action:** Agree on a concrete list. These become the non-functional
constraints (N) in the requirements.

---

## 3. How SDD applies to a utility script

The SDD loop was designed around game features with a clear playable test.
A music generator needs a small adaptation.

### The adapted loop

```
Idea
  └─► Requirement (R-NNN)
        └─► Acceptance Criterion (T-NNN)  ← MUST be audible/observable
              └─► Design Contract (I, P, Q, N)
                    └─► Implementation
                          └─► Test (run the script; listen; observe MIDI)
                                └─► Commit (with evidence)
```

### What "test" means for music

Acceptance criteria must be **observable without subjective judgement** where
possible. Examples of testable criteria:

- "Melody note selection stays within ±12 semitones of the previous note"
  → verifiable by inspecting the MIDI output
- "Every bar contains at least one bass note below MIDI 48"
  → verifiable by MIDI inspection
- "No two consecutive melody notes are more than 7 semitones apart"
  → verifiable

Subjective criteria ("sounds like a grand piano") must be decomposed into
measurable proxies:

- "Hammer strike transient decays to 10% amplitude within 200ms"
- "Sustain portion has at least 3 harmonic partials"

Some criteria will remain subjective ("music is pleasant to listen to for
30 minutes"). These are acceptance criteria that require a human listen test,
noted explicitly as such in the test document.

### Artefact locations

| Artefact | Location |
|---|---|
| Requirements | `utils/piano-stream/docs/requirements.md` |
| Technical design | `utils/piano-stream/docs/technical-design.md` |
| Traceability matrix | `utils/piano-stream/docs/traceability-matrix.md` |
| Acceptance tests | `utils/piano-stream/tests/manual-acceptance-tests.md` |
| ADRs | `utils/piano-stream/docs/decisions/` |
| Source | `utils/piano-stream/piano_stream.py` |

Utility ADRs are kept inside the utility's own folder tree and are numbered
with a `U-` prefix (`ADR-U-0001`, `ADR-U-0002`, …) to make clear they are
utility-scoped. They are never placed in `docs/decisions/`, which is reserved
for game and course architecture decisions.

---

## 4. Requirement decomposition — proposed modules

Once the architectural questions are answered, requirements will be grouped
into modules mirroring the course module structure. Proposed grouping:

### Module 1: Core piano synthesis
Requirements for the sound of a single note:
- Hammer strike transient
- Harmonic decay envelope
- Sustain and release
- Soft-clip output limiter

### Module 2: Musical framework
Requirements for the harmonic and rhythmic skeleton:
- Chord progression system (mood parameter)
- Bar / beat / step time model
- Tempo and time signature
- Register separation (bass vs melody)

### Module 3: Melody generation
Requirements for the melodic voice:
- Note selection within chord
- Stepwise motion constraint
- Phrase length and rest placement
- Velocity variation

### Module 4: Bass and accompaniment
Requirements for the left-hand part:
- Bass note on downbeats
- Accompaniment pattern (Alberti, broken chord, or sustained)
- Pedal simulation (sustain overlap)
- Register constraint

### Module 5: Musical structure
Requirements for macro-level shape:
- Section structure (intro, build, climax, resolution)
- Dynamic variation over time (pp → mf → f → mp)
- Harmonic rhythm (chord change timing)

### Module 6: MIDI export
Requirements for the game use case:
- Note events with correct timing
- Velocity from the musical engine (not hardcoded 100)
- Program change: Acoustic Grand Piano (GM patch 0)
- Pitch bend for any portamento effects
- Clean note-off messages

### Module 7: Stream DJ integration
Requirements for live-stream use:
- Fade in / fade out via flag file (compatible with `stream_dj.py`)
- Seed-based determinism
- Terminal visualiser
- CLI arguments consistent with `ca_synth.py` interface

---

## 5. Proposed order of work

```
Phase 0: Decisions (before any requirements)
  ├─ Decide MIDI target hardware      → ADR-U-0001
  ├─ Decide synthesis approach        → ADR-U-0002
  └─ Decide composition model         → ADR-U-0003

Phase 1: Requirements authoring (SDD steps 1–3 per module)
  ├─ Module 1: Core piano synthesis
  ├─ Module 2: Musical framework
  ├─ Module 3: Melody generation
  ├─ Module 4: Bass and accompaniment
  ├─ Module 5: Musical structure
  ├─ Module 6: MIDI export
  └─ Module 7: Stream DJ integration

Phase 2: Implementation (SDD steps 4–6 per requirement)
  ├─ Implement in module order
  ├─ Test each requirement before moving to next
  └─ Commit with evidence per requirement

Phase 3: Integration
  ├─ End-to-end listen test (30-minute run)
  ├─ MIDI export test in target playback environment
  └─ DJ crossfade test
```

**Do not begin Phase 1 until Phase 0 is complete.** The architectural
decisions in Phase 0 directly constrain what can be written in requirements.
Writing requirements before these decisions are made will produce requirements
that need to be rewritten.

---

## 6. Open questions for the human to answer

Before this plan can be executed, the following need your input:

1. **MIDI target:** Which DOS audio hardware is the game targeting? This
   determines how much to invest in MIDI quality.

2. **Synthesis approach:** Physical modelling (realistic, more work) or
   additive synthesis (faster, less realistic)? The answer shapes Module 1
   entirely.

3. **Composition model:** CA-driven (familiar, proven) or something more
   compositionally sophisticated (Markov, rule-based voice leading)?

4. **Scope of Module 7:** Do you want this script to be fully DJ-compatible
   from the start, or is that a later addition?

5. **Python standards:** The project coding standards are Pascal-specific. Do
   you want to define equivalent Python standards for this utility, or keep it
   as a prototype-quality brainstorm artefact?

---

## 7. What good looks like at the end

A listener who does not know the music is generated should:
- Not be able to tell it is procedural within the first 30 seconds
- Be able to listen for 30 minutes without irritation
- Recognise it as piano music specifically (not a generic synth)

The MIDI export should:
- Import cleanly into a DAW and sound intentional
- Play back recognisably as piano music on GM hardware
- Be usable as a game loop without editing
