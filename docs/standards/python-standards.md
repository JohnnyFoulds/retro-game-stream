# Python Coding Standards

## Purpose

This document defines the coding standards for all Python code in this repository.
Python is used exclusively in utility scripts under `utils/` — it is not the
language of the main project. These standards are therefore intentionally
lightweight compared to a full application standard.

The baseline is [PEP 8](https://peps.python.org/pep-0008/). This document
supplements PEP 8 with project-specific requirements and explicitly resolves
conflicts between PEP 8 and the standards already in force for this repository.

Compiled from:
- `aib-genai-standards/coding/coding-standards.md`
- `aib-genai-standards/coding/docstring-standards.md`
- `aib-genai-standards/coding/error-handling.md`
- `aib-genai-standards/logging/logging-standard.md`

Where those standards conflict with rules already established in this repository,
**this repository's rules take precedence**. Deviations are called out explicitly.

---

## 1. Scope

These standards apply to every `.py` file under `utils/`. Pascal coding standards
([coding-standards.md](coding-standards.md)) do not apply to Python.

---

## 2. Style

### 2.1 Baseline

Follow [PEP 8](https://peps.python.org/pep-0008/) unless a rule below overrides it.

### 2.2 Line length

**80 characters maximum.** This overrides PEP 8's 79-character recommendation.
80 characters is the project-wide standard (see NFR-6 in any utility spec) and
matches the Pascal standard for consistency.

### 2.3 Indentation

4 spaces per indent level. Never tabs.

### 2.4 Type hints

Type hints are **mandatory** on every function signature — parameters and return
type. No exceptions.

```python
# Good
def compute_velocity(step_in_bar: int, phrase_length: int) -> int: ...

# Bad — no type hints
def compute_velocity(step_in_bar, phrase_length): ...
```

Use `X | None` (Python 3.10+) rather than `Optional[X]`:

```python
def select_melody_note(prev_note: int | None) -> int | None: ...
```

### 2.5 Naming

| Construct | Convention | Example |
| --- | --- | --- |
| Modules | `snake_case` | `piano_stream.py` |
| Functions | `snake_case` | `synthesise_note`, `mix_and_limit` |
| Variables | `snake_case` | `samples_per_step`, `master_vol` |
| Constants | `UPPER_SNAKE_CASE` | `SAMPLE_RATE`, `MELODY_LOW` |
| Classes | `PascalCase` | `EngineState` |
| Dataclass fields | `snake_case` | `ca_row`, `prev_melody_note` |
| Private functions | Leading underscore | `_apply_stretch_factor` |

### 2.6 Magic numbers

No bare numeric literals with domain meaning. Every such value gets a named
constant at module level.

```python
# Good
MELODY_LOW = 60   # C4
MELODY_HIGH = 84  # C6

if note < MELODY_LOW or note > MELODY_HIGH:
    ...

# Bad
if note < 60 or note > 84:
    ...
```

### 2.7 Module structure

Single-file utilities are organised into named sections with `# ---` dividers.
Sections appear in this order where applicable:

```
# --- CLI ARGUMENT PARSER ---
# --- CONFIGURATION & TIME SCALING ---
# --- MUSIC THEORY / DOMAIN CONSTANTS ---
# --- CORE ENGINE ---
# --- SYNTHESISER ---
# --- MIXER ---
# --- OUTPUT ---
# --- MAIN LOOP ---
```

The section names and order are defined per utility in its technical design
document. Do not reorder sections without updating the design document.

---

## 3. Documentation

### 3.1 Docstring format

All docstrings must use
[reStructuredText / Sphinx-style](https://peps.python.org/pep-0287/) field lists.
Do not use Google-style (`Args:`, `Returns:`) or NumPy-style formats.

```python
def get_chord(mood: str, bar: int) -> list[int]:
    """
    Return the MIDI note list for the current chord.

    :param mood: The active mood name (must be a key in MOODS).
    :param bar:  Zero-based bar counter.
    :returns:    List of MIDI note numbers for the chord at this bar.
    :raises ValueError: If mood is not in MOODS.
    """
```

Fields:

| Field | Usage |
| --- | --- |
| `:param <name>: <desc>` | One entry per parameter |
| `:type <name>: <type>` | Omit when a type hint is present |
| `:returns: <desc>` | Describe the return value |
| `:rtype: <type>` | Omit when a type hint is present |
| `:raises <ExceptionType>: <condition>` | One entry per exception callers should handle |

### 3.2 What requires a docstring

| Construct | Requirement |
| --- | --- |
| All public functions and methods | **Mandatory** |
| All private functions and methods (`_name`) | **Mandatory** |
| All classes and dataclasses | **Mandatory** — one sentence stating their role |
| Modules | **Mandatory** — one short paragraph at the top of the file |

A one-line docstring is acceptable when a function has no parameters, no return
value, and no error conditions. Every other function — public or private — needs
a multi-line docstring with the applicable fields above.

```python
# One-liner acceptable — no params, no return, no errors
def _reset_state() -> None:
    """Reset the generative engine to its initial state."""


# Multi-line required — has params, return value, and a non-obvious constraint
def _clamp_to_register(note: int, low: int, high: int) -> int:
    """
    Clamp a MIDI note number into the closed interval [low, high].

    If the note is below low it is transposed up by octaves until it
    is in range; if above high, transposed down. This preserves the
    pitch class rather than hard-clamping, which avoids register
    collisions sounding unmusical.

    :param note: MIDI note number to adjust.
    :param low:  Lowest permitted MIDI note (inclusive).
    :param high: Highest permitted MIDI note (inclusive).
    :returns:    A MIDI note number in [low, high].
    """
```

### 3.3 Inline comments

The goal is code that a human reader can follow without referring to external
documents. Write inline comments generously — not to narrate every line, but to
maintain a running explanation of the logic so the reader is never left wondering
why the code does what it does.

**What to comment:**

- Any non-obvious algorithm step, formula, or constraint
- The physical or musical meaning of a numeric constant that is used inline
- The reasoning behind a branch or guard condition that is not self-evident
- Anything a reader might reasonably want to change but should not (explain why)

**What not to comment:**

- Lines whose intent is already stated by well-named identifiers
- Pure mechanics that are obvious from the syntax

```python
# Good — explains the algorithm step and the invariant it enforces
# Karplus-Strong averaging filter: blend adjacent delay-line samples.
# Writing back into buf is what sustains the resonance loop.
buf[pos % N] = 0.5 * (buf[pos % N] + buf[(pos - 1) % N])

# Good — explains why the constant has this value
N = round(SAMPLE_RATE / freq)  # delay line length = one period of freq

# Good — explains a non-obvious guard
if step_in_bar == 0:
    # Beat 1 always fires the bass note regardless of the CA gate so
    # that FR-14 (at least one bass note per bar) is unconditionally met.
    accompaniment_notes = [chord[0] - 12]

# Bad — restates the code
pos += 1  # increment position
```

Multi-line comments are fine when a block of logic needs a short header to
orient the reader. Keep each comment tight — one or two sentences at most.
If an explanation needs a paragraph, the complexity belongs in the design
document, not the source file.

### 3.4 License header

Every new `.py` file must carry the MPL 2.0 header as the **first lines** of the
file:

```python
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Source: https://github.com/JohnnyFoulds/retro-game-stream
```

---

## 4. Error Handling

### 4.1 Script-level vs library code

A single-file utility script is not a library. The full exception hierarchy
required by `aib-genai-standards/coding/error-handling.md` (base exception class,
domain-specific subclasses, HTTP error shapes) **does not apply** to standalone
scripts.

Raise standard Python exceptions (`ValueError`, `RuntimeError`, `OSError`) with
clear messages for argument validation and I/O failures. Reserve custom exception
classes for multi-module utility packages where callers need to catch specific
types.

### 4.2 Raise with context

Every raised exception must include a message that identifies what failed, which
value or resource was involved, and why:

```python
# Good
if volume < 0.0 or volume > 1.0:
    raise ValueError(
        f"volume must be between 0.0 and 1.0, got {volume}"
    )

# Bad — caller cannot identify the problem
if volume < 0.0 or volume > 1.0:
    raise ValueError("invalid volume")
```

### 4.3 Exception chaining

When wrapping a lower-level exception in a higher-level one, always use
`raise ... from exc`:

```python
try:
    stream.write(audio_out)
except sd.PortAudioError as exc:
    raise RuntimeError(
        f"Audio output failed at step {step_counter}"
    ) from exc
```

Never use `raise ... from None` unless the suppression is intentional and
documented with a comment explaining why.

### 4.4 Catching exceptions

Catch the most specific exception type available. `except Exception` is the
maximum permissible catch scope — never use `except BaseException`, which swallows
`KeyboardInterrupt` and `SystemExit`.

Only use `except Exception` at top-level handlers (e.g. the main loop guard) and
always log the traceback:

```python
try:
    result = synthesise_note(midi_note, duration, velocity)
except Exception:
    logger.error(
        "synthesise_note failed for note %d at step %d",
        midi_note, step_counter,
        exc_info=True,
    )
    result = np.zeros(samples_per_step, dtype=np.float32)
```

### 4.5 Never swallow errors silently

Do not catch an exception and do nothing. The minimum is a logged error.
If a subsystem failure is intentionally non-critical, this must be:

1. Documented in a comment at the catch site explaining why it is safe.
2. Logged at `ERROR` with `exc_info=True`.

```python
try:
    write_midi_file(args.out_midi, midi)
except OSError:
    # Non-critical: MIDI write failure must not stop the audio stream.
    # The player has already heard the music; only the export is lost.
    logger.error(
        "Failed to write MIDI file '%s'", args.out_midi, exc_info=True
    )
```

### 4.6 CLI argument validation

Validate all CLI arguments at startup before opening any audio device or file.
Each invalid argument must exit immediately with a descriptive `ValueError`
printed to `stderr`. See the error behaviour table in the utility's feature spec
for the exact message format per argument.

---

## 5. Logging

### 5.1 Log levels

Use the standard Python `logging` levels:

| Level | When to use |
| --- | --- |
| `ERROR` | Unexpected failures, unhandled exceptions, I/O failures |
| `WARNING` | Expected-but-notable conditions: a clamp applied, a file not writable |
| `INFO` | Lifecycle events: script started, MIDI file written, fade-out triggered |
| `DEBUG` | Internal state for active diagnosis; not left permanently active |

Rules:
- Use `ERROR` at every exception catch site.
- Do not use `INFO` for high-frequency per-step events — use `DEBUG`.
- Do not use `WARNING` for errors that require action — use `ERROR`.

### 5.2 Logger naming

Use `logging.getLogger(__name__)` at module level:

```python
import logging

logger = logging.getLogger(__name__)
```

### 5.3 Message format

Include the relevant identifiers (note, step, bar, file path) so that a log
record can be understood in isolation:

```python
# Good — context is present
logger.error(
    "Audio buffer NaN at step %d bar %d — replacing with silence",
    step_counter, bar,
)

# Bad — no context
logger.error("Bad audio buffer")
```

### 5.4 Use `%s` formatting, not f-strings

Use `%`-style lazy formatting in all log calls. The logging module performs
interpolation only when the message will actually be emitted — f-strings always
evaluate regardless of the active log level.

```python
# Good — lazy
logger.debug("Karplus-Strong delay line length %d for MIDI note %d", N, midi_note)

# Bad — always evaluates
logger.debug(f"Karplus-Strong delay line length {N} for MIDI note {midi_note}")
```

### 5.5 `exc_info=True` at ERROR level

Every `logger.error()` call at an exception catch site must include
`exc_info=True`:

```python
try:
    stream = sd.OutputStream(samplerate=SAMPLE_RATE, channels=1, dtype="float32")
except sd.PortAudioError as exc:
    logger.error("Failed to open audio output stream", exc_info=True)
    sys.exit(1)
```

### 5.6 Script-level log configuration

The main script (e.g. `piano_stream.py`) configures logging once at startup,
before any other work:

```python
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    stream=sys.stderr,
)
```

Utility modules that are not the entry point must never call `basicConfig`,
attach handlers, or set logger levels. Configuration is always the entry
point's responsibility.

### 5.7 No OTel / telemetry instrumentation

OpenTelemetry tracing and metrics are not used in utility scripts. The
corresponding sections of `aib-genai-standards/logging/logging-standard.md`
and `aib-genai-standards/logging/telemetry-standard.md` do not apply here.

---

## 6. Source control

Follow [git-standard.md](git-standard.md) for branching and commit conventions.

**Commit messages for utility work use the same format as game work:**

```
R-NNN <verb> <what changed>

- <specific change>
- <specific change>
- Update docs/traceability-matrix.md

Build: passed
Tests: passed
```

**This overrides the Conventional Commits format** (`feat(scope): subject`)
used by `aib-genai-standards`. Conventional Commits are the standard for the
AI Booster Plus project on GitLab; this repository uses a requirement-linked
format that ties every commit to a traceable specification artefact.

---

## 7. Dependencies

Utility scripts must minimise external dependencies. Every `import` that is not
Python stdlib must be explicitly listed in the utility's feature spec
(§3.6 Dependency Constraints) and justified.

Standard library modules (`os`, `sys`, `random`, `math`, `hashlib`, `argparse`,
`logging`, `dataclasses`) do not count as external dependencies and require no
justification.

---

## 8. Summary checklist

Before committing any Python file:

- [ ] MPL 2.0 license header is the first block in the file
- [ ] All function signatures carry type hints (parameters and return type)
- [ ] All public functions have a docstring in Sphinx/RST field format
- [ ] Module has a module-level docstring
- [ ] All constants with domain meaning are named — no bare numeric literals in logic
- [ ] All `logger.error()` calls at catch sites include `exc_info=True`
- [ ] Log calls use `%s` formatting, not f-strings
- [ ] No exception is silently swallowed without a log and an explanatory comment
- [ ] `except BaseException` is not used anywhere
- [ ] CLI arguments are validated at startup with clear `ValueError` messages
- [ ] No external dependencies that are not listed in the feature spec

---

## References

- [PEP 8 — Style Guide for Python Code](https://peps.python.org/pep-0008/)
- [PEP 257 — Docstring Conventions](https://peps.python.org/pep-0257/)
- [PEP 287 — reStructuredText Docstring Format](https://peps.python.org/pep-0287/)
- [PEP 3134 — Exception Chaining](https://peps.python.org/pep-3134/)
- [Python Logging HOWTO](https://docs.python.org/3/howto/logging.html)
- [12 Factor App — Logs](https://12factor.net/logs)
- [git-standard.md](git-standard.md) — commit and branch conventions for this repository
- aib-genai-standards `coding/coding-standards.md` — source standard (GitLab/Conventional Commits rules do not apply here)
- aib-genai-standards `coding/docstring-standards.md` — source for Sphinx/RST docstring format
- aib-genai-standards `coding/error-handling.md` — source for error handling rules (HTTP/SSE sections omitted)
- aib-genai-standards `logging/logging-standard.md` — source for logging rules (OTel sections omitted)
