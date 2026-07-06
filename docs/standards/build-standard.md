# Build Standard — Turbo Pascal 7

## Purpose

This document defines how source files are compiled, how build artefacts are organised, and what constitutes a "passed build" for commit evidence purposes.

---

## 1. Compiler

**Turbo Pascal 7.0** (`TPC.EXE`) — the command-line compiler. The IDE (`TURBO.EXE`) may be used for interactive development, but all reference builds use the command-line compiler so they can be automated and reproduced.

Minimum version: Turbo Pascal 7.0 (patch level `.1` preferred).

---

## 2. Project structure

```
games/corporate-ladder/
  src/
    GAME.PAS         ← program entry point
    WORLD.PAS        ← world data and tile logic
    PLAYER.PAS       ← player state and movement
    RENDER.PAS       ← all screen output
    INPUT.PAS        ← keyboard input
    ENEMY.PAS        ← enemy state and movement (Module 6+)
  src-baseline/      ← Module 0 vibe-code baseline (read-only reference)
  build/
    GAME.EXE         ← compiled output
    build.log        ← compiler output from the last build
    build-manifest.txt  ← content hash + timestamp per source file
  public/
    index.html       ← browser play page (JS-DOS or DOSBox-X embed)
  tests/
    manual-acceptance-tests.md
```

Source files live in `src/`. The compiler writes `GAME.EXE` to `build/`. All intermediate files (`.TPU`, `.MAP`, `.OBJ`) go to `build/` as well — never committed.

---

## 3. Build targets (Makefile)

The project provides a `Makefile` at the game root. Required targets:

| Target | Action |
| --- | --- |
| `make build` | Compile `src/GAME.PAS`; write output to `build/`; capture compiler output to `build/build.log` |
| `make test` | Run the manual acceptance test harness and report results |
| `make clean` | Delete all files in `build/` except `build.log` and `build-manifest.txt` |
| `make manifest` | Write `build/build-manifest.txt` (see §5) |

Example Makefile excerpt:
```makefile
TPC     = tpc
SRCDIR  = src
BUILDDIR = build

build:
	$(TPC) $(SRCDIR)/GAME.PAS /O$(BUILDDIR) /B 2>&1 | tee $(BUILDDIR)/build.log
	@grep -q "^Error" $(BUILDDIR)/build.log && exit 1 || exit 0

clean:
	rm -f $(BUILDDIR)/*.EXE $(BUILDDIR)/*.TPU $(BUILDDIR)/*.MAP

manifest:
	@echo "Build manifest — $$(date)" > $(BUILDDIR)/build-manifest.txt
	@sha256sum $(SRCDIR)/*.PAS >> $(BUILDDIR)/build-manifest.txt
```

The `make build` target must exit with code 0 on a clean compile and a non-zero code on any compiler error or warning. A build that produces warnings is **not** a passing build.

---

## 4. What "Build: passed" means

A commit may state `Build: passed` only when:

1. `make build` exits with code 0
2. `build/build.log` contains no lines beginning with `Error` or `Warning`
3. `build/GAME.EXE` exists and is non-zero bytes

If the compiler is unavailable (e.g. working on documentation only), the commit must state `Build: not run`.

---

## 5. Build manifest

`build/build-manifest.txt` records the SHA-256 hash and last-modified timestamp of every `.PAS` source file at the time of a successful build. This provides an evidence chain linking a commit to the exact source that produced the binary.

Format:
```
Build manifest — 2026-07-05 14:23:01
<sha256>  src/GAME.PAS
<sha256>  src/WORLD.PAS
<sha256>  src/PLAYER.PAS
<sha256>  src/RENDER.PAS
<sha256>  src/INPUT.PAS
```

Commit `build/build-manifest.txt` alongside source changes. Do not commit `GAME.EXE` or `.TPU` files.

---

## 6. `.gitignore` entries

```
games/corporate-ladder/build/*.EXE
games/corporate-ladder/build/*.TPU
games/corporate-ladder/build/*.MAP
games/corporate-ladder/build/*.OBJ
games/corporate-ladder/build/*.BAK
```

`build.log` and `build-manifest.txt` are committed (they are build evidence, not build artefacts).

---

## 7. Development vs release builds

Two compiler configurations:

| Configuration | Directives | Use |
| --- | --- | --- |
| Development | `{$R+}` `{$S+}` `{$D+}` `{$L+}` | Day-to-day development and all acceptance tests |
| Release | `{$R-}` `{$S-}` `{$D-}` `{$L-}` | Final course demonstration binary |

The development configuration is the default. The release build is produced manually before the course demonstration. Both must produce a passing build (zero errors, zero warnings).

---

## References

- Borland International, *Turbo Pascal 7.0 User's Guide*, 1992 — Chapter 4 (Command-Line Compiler).
