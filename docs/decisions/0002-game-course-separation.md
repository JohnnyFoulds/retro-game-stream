# 0002 — Separate game design from course structure

**Status:** Accepted
**Date:** 2026-07-04

## Context

The course is built around a specific game — currently *The Corporate Ladder: Avoid Middle Management*. Early versions of the README and CLAUDE.md embedded game-specific details (requirements, symbols, data model, file structure) directly alongside course-level content (skill clusters, pedagogy, module structure).

This creates a coupling problem: if the game changes, the course documents need surgical editing. More importantly, it obscures which decisions belong to the course itself and which belong to the current game choice.

## Decision

All game-specific design lives in `docs/brainstorm/<game-name>/`. The README and CLAUDE.md contain only course-level content. The current target game is referenced by name with a link, not embedded inline.

## Motivation

The course structure — SDD loop, five skill clusters, module sequence, agent protocol — is stable and reusable across any game. The game is a pedagogical vehicle, not the course itself. Keeping them separate means:

- The game can be swapped, extended, or replaced without touching course documentation
- A different game could be designed for a different audience (e.g. a simpler game for executives, a more complex one for advanced engineers) while reusing the same course framework
- The baseline experiment at the start (Module 0) applies regardless of which game is being built

The current target game (*The Corporate Ladder*) was chosen because its mechanics map cleanly onto the SDD skill clusters and it has strong motivational resonance for a corporate audience. But that is a separate decision from the course design itself.

## Consequences

**Enables:**
- Swapping the target game without rewriting course documents
- Designing multiple game variants for different audiences
- Keeping README and CLAUDE.md stable as the course matures

**Rules out:**
- Embedding game-specific requirements, data models, or file structures in README or CLAUDE.md
- Treating the current game choice as permanently fixed at the course level

**Watch for:**
- Game-specific ADRs (e.g. ADR-0001 on Pascal) belong at the course level when the decision affects all games, and in the game's own brainstorm folder when it is game-specific
