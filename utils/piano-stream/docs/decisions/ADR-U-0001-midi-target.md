# ADR-U-0001 — MIDI export targets General MIDI as the baseline format

**Status:** Accepted
**Date:** 2026-07-08

## Context

The piano MIDI export has two downstream consumers:

1. **DAW import** — the export must open cleanly in GarageBand, Ableton Live, and
   equivalent tools so that music can be reviewed, edited, and repurposed.
2. **DOS game playback** — the export will be played back inside *The Corporate Ladder*
   running under a DOS emulator. The specific playback hardware (or emulated hardware)
   had not been decided when the feature spec was first authored.

The three viable DOS audio targets are:

| Target | Description | Piano quality |
|--------|-------------|---------------|
| **OPL2 / OPL3 FM synthesis** | AdLib / Sound Blaster FM; most widely emulated | Thin; the FM piano patch is recognisable but synthetic |
| **General MIDI / MPU-401** | Requires Sound Blaster AWE or a Roland MT-32 / SC-55 emulator | Rich; dedicated piano patch sounds convincingly like a piano |
| **PC speaker** | Single-bit buzzer; single voice only | Not viable for piano music |

The relevant MIDI features — velocity sensitivity, program change, pitch bend — vary
by target. Designing for a narrow target (OPL2) would mean ignoring features (velocity,
multiple channels) that OPL2 either ignores or handles poorly. Designing for the
richest target (hardware GM) would produce a file that degrades gracefully on simpler
targets rather than failing.

## Decision

Target **General MIDI (GM)** as the sole MIDI export format.

- Channel 0: melody (right hand), GM program 0 — Acoustic Grand Piano
- Channel 1: accompaniment (left hand), GM program 0 — Acoustic Grand Piano
- Velocity: full 7-bit range (0–127), derived from the musical engine
- No OPL2-specific limitations apply (no capping velocity, no stripping program
  change, no mono-channel workaround)

## Motivation

**Broadest compatibility.** A well-formed GM file plays correctly in every emulated
DOS environment that supports GM playback (DOSBox with a GM soundfont, DOSBox-X,
BasiEgaXorz). It also imports cleanly into every modern DAW — which is required
by NFR-5.

**Graceful degradation.** If the game ultimately targets OPL2/OPL3 FM, a GM file is
still the correct source; the conversion layer (MIDI-to-OPL2 driver) handles
any tonal differences. The piano MIDI file does not need to know about that
conversion.

**Velocity and program change matter.** FR-16 and FR-17 require program-change
messages and engine-derived velocities. OPL2 drivers typically ignore or map these
loosely, so targeting OPL2 directly would mean building to a lowest-common-denominator
that discards musical expression. GM preserves that expression for DAW users and
for emulated GM playback.

Alternatives considered and not chosen:

| Alternative | Reason not chosen |
|-------------|-------------------|
| OPL2-targeted MIDI | Restricts velocity resolution and program selection; degrades DAW import quality; the game target is not yet finalised |
| PC speaker | Not viable for polyphonic piano music; ruled out entirely |
| SoundFont-embedded SMF | Adds a non-standard dependency; DAW import becomes fragile |

## Consequences

**Enables:**
- Clean DAW import into GarageBand and Ableton (NFR-5 satisfied directly)
- Full velocity expression preserved from the musical engine (FR-17)
- Program-change messages assign the correct piano patch on any GM device (FR-16)
- Clean note-off messages work as expected on all GM-compliant players (FR-18)
- The export is usable in DOSBox and DOSBox-X with a GM soundfont without
  post-processing

**Rules out:**
- OPL2-native optimisation (not needed; a GM-to-OPL2 driver handles this at runtime)
- Embedding OPL2 patch numbers or FM operator data in the MIDI file

**Watch for:**
- DOSBox must be configured with a GM soundfont (e.g. GeneralUser GS) for the
  piano patch to sound correct; the raw OPL2 FM piano patch is audibly different
- If the game ships with a MIDI-to-OPL2 conversion layer, the velocity data in
  the GM export should be preserved through conversion rather than normalised to
  a fixed value
