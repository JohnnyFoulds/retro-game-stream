# 0001 — Turbo Pascal 7 as implementation language

**Status:** Accepted
**Date:** 2026-07-04

## Context

The course needs a programming language in which learners build the game. The language choice affects:

- How readable the generated code is to participants with varying technical backgrounds
- Whether non-technical participants (including executives) can meaningfully review AI-generated diffs
- Whether the retro DOS aesthetic is achievable on the target platform
- How much cognitive load is added by the language itself vs the SDD discipline being taught

## Decision

Use **Turbo Pascal 7** as the sole implementation language for *The Corporate Ladder*.

## Motivation

Niklaus Wirth designed Pascal specifically as a teaching language. Its syntax is explicit, strongly typed, and reads close to structured English:

```pascal
if TileAt(X + 1, Y) = ttPlatform then
  StopFalling
else
  ApplyGravity;
```

This readability serves the course's long-term accessibility goal: participants who cannot write code from scratch can still read a diff, compare it against a requirement, and make a genuine judgment about whether the AI did what was asked. That judgment — specification vs output — is the central skill the course teaches.

Modern alternatives considered:

| Language | Reason not chosen |
|----------|------------------|
| Python | Readable, but no natural path to a browser-playable DOS artefact; loses the retro concreteness |
| C | Too low-level; increases cognitive load without benefit for the SDD lesson |
| TypeScript / JavaScript | Familiar to web developers but verbose type scaffolding obscures the game logic in diffs |
| Rust | Excellent engineering discipline, but steep learning curve defeats the accessibility goal |

Turbo Pascal 7 also targets DOS text mode natively, which enables the browser-playable build via a DOS emulator — a concrete, motivating artefact that closes the feedback loop for every requirement.

## Consequences

**Enables:**
- Diff review accessible to non-technical participants, including executives
- Long-term course expansion beyond technical audiences
- A browser-playable artefact that closes the Specify → Build → Play loop visibly
- Authentic retro aesthetic that motivates engagement

**Rules out:**
- Using modern language tooling (LSPs, formatters, package managers) as part of the workflow
- Direct reuse of course artefacts in production systems (intentional — this is a laboratory)
- Swapping to another language mid-course or in a future version without revisiting this decision

**Watch for:**
- Platform team must ensure a working Turbo Pascal 7 compiler and DOS emulator are available in each learner's container
- Instructors should not assume Pascal knowledge — the syntax should be introduced briefly at the start and referenced as a feature (readable by design), not apologised for
