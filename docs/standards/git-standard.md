# Git Standard

## Purpose

This document defines branching, commit, and code-review conventions for this repository. These rules apply to all contributors, including AI assistants acting under human supervision.

---

## 1. Branches

Two long-lived branches:

| Branch | Purpose |
| --- | --- |
| `master` | Published, reviewed state. Always buildable. |
| `development` | Integration branch. Short-lived feature branches merge here first. |

Short-lived branches branch from `development` and follow the naming convention:

```
<type>/<short-description>
```

Types:

| Type | Use |
| --- | --- |
| `feat/` | New requirement implementation |
| `fix/` | Bug fix |
| `refactor/` | Code restructure with no behaviour change |
| `docs/` | Documentation or standards changes only |
| `chore/` | Build, tooling, or course material |

Examples:
```
feat/r007-dollar-collection
fix/r004-gravity-off-by-one
docs/traceability-matrix-update
```

Hotfixes branch from `master` and merge back into both `master` and `development`.

---

## 2. Commit messages

Format: **Conventional Commits** with a requirement ID as scope.

```
<type>(<scope>): <subject>

<body — one bullet per logical change, imperative present tense>

Build: <passed | failed | not run>
Tests: <passed | failed | not run>
```

### Subject line rules

- Lowercase after the colon
- No trailing period
- 72 characters maximum
- Scope is the requirement ID when implementing a requirement; omit scope for tooling/docs changes with no requirement ID

### Body rules

- Required for any commit that changes behaviour or structure
- One bullet per logical change
- Imperative present tense: "add", "remove", "change" — not "added", "removes", "changing"
- Include test and build evidence on the final two lines

### Examples

Requirement implementation:
```
feat(R-007): implement dollar collection

- Remove dollar sign from tile map when player enters its cell
- Increment score by 1
- Add acceptance test T-007
- Update traceability matrix

Build: passed
Tests: passed
```

Documentation only:
```
docs: add git standard

Build: not run
Tests: not run
```

Bug fix:
```
fix(R-004): correct gravity when player reaches bottom row

- Clamp player Y to world height minus one instead of world height
- Add regression test T-004b

Build: passed
Tests: passed
```

### What to omit

- No AI co-authorship attribution in commit messages
- No "this commit" preamble ("This commit adds…")
- No ticket URLs (requirement IDs are sufficient)

---

## 3. Merge / pull requests

- PRs must be small and focused — one requirement or one logical change per PR
- The CI build (compile + tests) must pass before requesting review
- PR description must include:
  - Summary of what changed and why (one paragraph)
  - Linked requirement ID(s)
  - Test evidence (which acceptance tests were run and passed)
  - Any compatibility notes (save-file format changes, interface changes)
- Minimum 1 approval before merge; 2 approvals for changes to the game engine core or course materials

---

## 4. Tags

Tag after completing a milestone:

```
git tag -a v<module>.<iteration> -m "<short description>"
```

Example:
```
git tag -a v3.1 -m "Module 3 complete: world renders, player draws and moves"
```

---

## References

- Conventional Commits specification: <https://www.conventionalcommits.org/>
- Google Engineering Practices: <https://google.github.io/eng-practices/>
