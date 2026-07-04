# Specification-Driven AI Development

> **Specify. Build. Test. Commit. Play.**

A one-day, instructor-led corporate training course for Vodacom technical employees. Learners use an AI coding agent to build a small game. The game is the laboratory — the real subject is disciplined AI-assisted software engineering.

The current target game is *The Corporate Ladder: Avoid Middle Management* — see [docs/brainstorm/corporate-ladder/](docs/brainstorm/corporate-ladder/).

---

## What this course teaches

The game is not the point. The game is the vehicle for five skill clusters:

### 1. Specification-Driven Development (SDD)
Turn a vague idea into small, observable requirements with explicit acceptance criteria before writing a line of code. The requirement is the unit of work. The full loop:

```
Idea → Requirement → Acceptance Criterion → Design → Code → Test → Commit → Playable
```

### 2. AI usage and prompting discipline
Use the AI as a *controlled implementation assistant*, not an autonomous developer. Constrain every prompt: name the requirement ID, name the files to modify, name what not to do. Demand a diff before a commit. The course opens with a vibe-code baseline to demonstrate — not lecture about — what uncontrolled AI coding looks like.

### 3. Git as the engineering record
Commits are engineering claims, not saves. Every commit carries: requirement ID, what changed, test result, build result. The evidence chain runs:

```
playable game → build manifest → commit → diff → requirement
```

### 4. Software design thinking
Static world vs dynamic entities. Rendering seams that allow visual changes without touching game rules. Specifying update order *before* implementation. YAGNI vs small intentional seams — not every future concern needs engineering now, but the right doors must stay open.

### 5. AI-assisted research and documentation
Using AI productively in the discovery and design phase (requirements, technical design, extension backlog) — distinct from using it in the implementation phase. The learner stays the author throughout both phases.

---

## The central claim

```
Specification ≻ AI output
```

Fast generation is not the same as fast, reliable delivery:

```
T_delivery = T_specification + T_generation + T_debugging + T_integration + T_maintenance
```

Vibe coding minimises `T_generation` but inflates the downstream terms. SDD invests a small amount upfront to reduce a much larger cost later.

---

## Course structure (one day, ~7 hours)

| Time | Module | Goal |
|------|--------|------|
| 09:00 | **Module 0:** Vibe-code baseline | Try the obvious thing first; inspect the result |
| 09:30 | **Module 1:** Requirements | Define requirements with acceptance criteria |
| 10:15 | **Module 2:** Technical design | Core data model, rendering seam, update order |
| 11:00 | **Module 3:** First slice | Render world, draw player, basic movement |
| 13:00 | **Module 4:** Vertical movement | Climbing and gravity |
| 14:00 | **Module 5:** Collectibles and exit | Collection, score, win condition |
| 15:00 | **Module 6:** Enemy *(optional)* | Collision and loss condition |
| 15:45 | **Module 7:** Git milestone | `git log`, tag milestone, publish green build |
| 16:30 | **Module 8:** Extensibility | Extension backlog, YAGNI discussion |

---

## Repository structure

```
retro-game-stream/
  docs/
    brainstorm/           — raw design notes per game candidate
      corporate-ladder/   — current target game design
    decisions/            — Architecture Decision Records
    standards/            — project standards (ADR format, etc.)
    course/               — instructor-facing course materials
  games/                  — one directory per game trial build
```

---

## Target audience

| Audience | Fit |
|----------|-----|
| Software engineers | Excellent — pilot target |
| Data scientists / AI engineers | Excellent — pilot target |
| Automation engineers | Good — pilot target |
| Solution architects | Good — pilot target |
| Technical product owners | Good — pilot target |
| Non-technical business users / Executives | Target after pilot is stable |

No prior experience with the chosen language required. The long-term vision is that **anyone** — including executives — can use the SDD loop to build small personal tools and automation, and in doing so gain genuine insight into what software engineers navigate every day.

The pilot focuses on technical employees to iron out delivery problems first. Once stable, the course is open to everyone.
