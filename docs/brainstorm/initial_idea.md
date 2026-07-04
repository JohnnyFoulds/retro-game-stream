# Course Design: Specification-Driven AI Development with “The Corporate Ladder”

Source: [ChatGPT](https://chatgpt.com/g/g-p-6a47f621cdec81919a775843c5da78d7/c/6a47f625-b964-83ea-97ee-3a14826b6fd3)
Extracted: 2026-07-04T11:51:13.778Z
🚀 Exported with [Save my Chatbot](https://save.hugocolin.com)!

---

[Skip to content](#main)

[

New chat](/)

Search chats

Pinned

Recents

![](https://cdn.auth0.com/avatars/us.png)

## Chat history

[ChatGPT](/)

- [New chat⇧⌘O](/)
- 
- Search chats⌘K

[

Library

](/library)[

Scheduled

](/scheduled)[

Apps

](/apps)[

Codex

](/codex)

More

## Pinned

- [Pascal Programming Lineage](/c/6a42202f-8f3c-83ea-b249-c2bbcebaa4fc)

## Projects

- Retro Games[Retro DOS Game Design](/g/g-p-6a47f621cdec81919a775843c5da78d7/c/6a47f625-b964-83ea-97ee-3a14826b6fd3)

p-system

Chess

Philosophy

Writing

Show more

## Chats

[

](/)

- [WhatsApp Spanish Learning Plan](/c/6a2fbad1-44cc-83ea-99fd-eb2d202e5bfc)
- [Shoe Making Molds Guide](/c/6a3d144b-e3e8-83ea-8055-92f601b499c9)
- [Romance Scam Analysis](/c/6a36b8f9-c5a8-83ea-82ac-65074e7ad171)
- [E-ink Display with Pi](/c/6a367010-7cc4-83ea-a28a-5cbe28535dc5)
- [E Ink 80x25 Display](/c/6a34e86f-e508-83ea-8b87-20de413e902b)
- [Relationship Dynamics Over Time](/c/6a33c024-9df8-83ea-98d9-4875722d83a6)
- [Report Read in Full](/c/6a342857-1184-83ea-adc6-32ead2e68bc4)
- [File Availability Confirmation](/c/6a301dd9-27c4-83ea-af41-64f03b166e90)
- [AI behavior analysis](/c/6a2dce7a-b858-83ea-aefb-303d7a9b6eff)
- [PhD Supervision Inquiry Review](/c/6a27ff86-1834-83ea-b7dd-0daef426708e)
- [ASM Program Explanation](/c/6a26895e-2ea8-83ea-a6d6-77b0f2b88aab)
- [Gaslighting Analysis Breakdown](/c/6a203600-e220-83ea-857c-422b3c481c41)
- [Transcript Analysis Breakdown](/c/6a1ffc62-d7d8-83ea-af0d-86b48ac5816f)
- [Missing Binding Externalisation](/c/6a0ed4a4-f12c-83ea-b6ce-69df9a933b9c)
- [Yudkowsky AI Controversy](/c/6a0d6cb4-0630-83ea-82cc-1cbfb148d5e0)
- [Interpreting LinkedIn Message](/c/6a0ac49e-7b18-83ea-94e8-6cc5b06ca3d8)
- [Unicorn AI Career Path](/c/6a084cd7-2c40-83ea-b484-4ba6a4f87155)
- [Rust and Cuda-Oxide Use](/c/6a0841a8-604c-83ea-a559-3493012cf16a)
- [Cast Android to Apple TV](/c/6a05fbc0-cf20-83ea-a99d-b495e4c6502e)
- [Google Authenticator 2FA Tips](/c/6a05ca1b-300c-83ea-8e3b-e0359220cff3)
- [Casual Shoe Modifications](/c/6a0459d4-6d8c-83ea-ad86-21b2cf165eca)
- [Adversarial Pressure-Testing Analysis](/c/6a036f68-6470-83ea-96ef-fc396eb3bfae)
- [Transcript Analysis and Decoupling](/c/6a0315b2-fc00-83ea-bf82-6d4e0b90f854)
- [Conversation Analysis Breakdown](/c/6a020c56-6f68-83ea-976c-54dfda071d1b)
- [Neovim Explained](/c/6a004b34-b4c8-83ea-ae57-dc61704dcf16)
- [Video Transcription Request](/c/69fb3dee-717c-83ea-9be7-3edc5494b211)
- [Claude Code Leak Details](/c/69f9a533-5484-832d-911f-38a9cde6def8)
- [Identity and Background Summary](/c/69f886f6-6590-83ea-9b72-0856a5b3c76e)

![](https://cdn.auth0.com/avatars/us.png)

hfoulds@gmail.com

Plus

[

Retro Games
](/g/g-p-6a47f621cdec81919a775843c5da78d7-retro-games/project)

![](chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/browser/images/acrobat_prodc_appicon_24.svg)Convert chat to PDF

Share

#### ChatGPT said:

I’ll consolidate the decisions into one coherent course blueprint: learning outcomes, platform assumptions, one-day structure, game specification, technical design, Git/build workflow, and post-training enhancement path.

Thought for 12s

# Course Design: **Specification-Driven AI Development with “The Corporate Ladder”**

## Course title

# **Specification-Driven AI Development**

## **Building *The Corporate Ladder*: Avoid Middle Management**

Tagline:

> **Specify. Build. Test. Commit. Play.**

The course is a one-day, instructor-led training programme for Vodacom employees. Learners use the corporate AI coding platform to build a small DOS-style ASCII platform game in Turbo Pascal 7. The game is deliberately simple, but the development process is rigorous.

The training is not primarily about retro gaming, Pascal, or DOS. Those are the laboratory. The real subject is disciplined AI-assisted software engineering.

The central transformation taught is:

Idea→Specification→Design→Code→Test→Git Commit→Playable Artefact\text{Idea} \rightarrow \text{Specification} \rightarrow \text{Design} \rightarrow \text{Code} \rightarrow \text{Test} \rightarrow \text{Git Commit} \rightarrow \text{Playable Artefact}Idea→Specification→Design→Code→Test→Git Commit→Playable Artefact

Every meaningful increment must satisfy:

Δi=⟨Ri,Di,Ci,Ti,Gi,Bi,Pi⟩\Delta_i =
\langle R_i, D_i, C_i, T_i, G_i, B_i, P_i \rangleΔi​=⟨Ri​,Di​,Ci​,Ti​,Gi​,Bi​,Pi​⟩

where:

Ri=requirement,Di=design decision,Ci=code change,R_i = \text{requirement},\quad
D_i = \text{design decision},\quad
C_i = \text{code change},Ri​=requirement,Di​=design decision,Ci​=code change,
Ti=test evidence,Gi=Git commit,Bi=build result,Pi=playable result.T_i = \text{test evidence},\quad
G_i = \text{Git commit},\quad
B_i = \text{build result},\quad
P_i = \text{playable result}.Ti​=test evidence,Gi​=Git commit,Bi​=build result,Pi​=playable result.

The specification is always authoritative:

Specification≻AI output\text{Specification} \succ \text{AI output}Specification≻AI output

This is the course’s core intellectual claim.

# 1. Target audience

The primary audience is Vodacom technical employees who need to learn how to use AI coding tools productively without losing engineering control.

The course is suitable for:

| Audience | Fit |
| --- | --- |
| Software engineers | Excellent |
| Data scientists / AI engineers | Excellent |
| Automation engineers | Good |
| Solution architects | Good |
| Technical product owners | Useful if paired with technical participants |
| Non-technical business users | Not ideal for the first version |

Learners do not need prior Turbo Pascal experience. They should have basic programming literacy and be comfortable with files, functions/procedures, variables, and simple control flow.

# 2. Course purpose

The purpose is to teach learners how to use an AI coding agent as a **controlled implementation assistant**, not as an autonomous developer.

The learner should leave with the habit:

```
Do not ask the AI to “make the game”. 
 
Specify the behaviour. 
Constrain the files. 
Generate a small patch. 
Inspect the diff. 
Run the build. 
Run the test. 
Commit the change. 
Play the result.
```

This directly addresses the central failure mode of AI coding: plausible output without traceability, verification, or human ownership. Requirements-engineering and traceability literature emphasises the need to relate requirements to downstream artefacts across the lifecycle [1]. This course makes that relation visible in a small, playful system.

# 3. Learning outcomes

By the end of the one-day course, learners should be able to:

| ID | Learning outcome |
| --- | --- |
| LO1 | Convert a vague game idea into small, observable requirements. |
| LO2 | Express simple behaviour using acceptance criteria. |
| LO3 | Use an AI coding agent with explicit constraints and bounded scope. |
| LO4 | Separate game state, rendering, input, movement, and rules at a basic modular level. |
| LO5 | Inspect AI-generated changes using Git diff before accepting them. |
| LO6 | Run or interpret a build/test result before committing. |
| LO7 | Make meaningful local Git commits tied to requirements. |
| LO8 | Produce a browser-playable DOS game artefact from a green build. |
| LO9 | Explain the difference between extensibility and over-engineering. |
| LO10 | Identify safe next enhancements after the training. |

The one-day version does **not** try to teach full Git collaboration, merge requests, QEMU validation, full game-engine design, or advanced graphics. Those are deferred.

# 4. Course product

The product built during training is:

# **The Corporate Ladder**

## **Avoid Middle Management**

A single-screen ASCII DOS platform game.

Premise:

> Climb the corporate ladder, collect dollar signs, avoid middle management, and reach the exit.

Core symbols:

```
@ player / employee 
= platform 
H ladder 
$ collectible money 
M middle management enemy 
E exit 
# wall / boundary 
. empty space
```

Example level:

```
######################################## 
#.............$.......................E# 
#.....======.............======........# 
#.........H..................H.........# 
#.........H..........$.......H.........# 
#..@..=====.....========.....=====.....# 
#.........H..................H.........# 
#.........H.......M..........H.........# 
#.....======.............======........# 
#..................$...................# 
########################################
```

The game loop is intentionally simple:

move+climb+fall+collect+avoid+exit\text{move} + \text{climb} + \text{fall} + \text{collect} + \text{avoid} + \text{exit}move+climb+fall+collect+avoid+exit

Win condition:

Win  ⟺  all $ collected∧player reaches E\text{Win} \iff \text{all } \$ \text{ collected} \land \text{player reaches } EWin⟺all $ collected∧player reaches E

Loss condition:

Lose  ⟺  player collides with M\text{Lose} \iff \text{player collides with } MLose⟺player collides with M

For the one-day version, the enemy can be optional depending on class pace. The absolute minimum playable version is movement, ladders, collectibles, and exit.

# 5. Platform assumptions

The course uses the corporate AI platform with the following capabilities:

| Platform capability | Course use |
| --- | --- |
| Web-based AI agent | Learners interact with a project-specific coding assistant. |
| Claude Code-style file editing | Agent can create and modify project files. |
| Isolated container per learner | Each learner has a private runtime. |
| UID-backed private EFS storage | Project files persist and are isolated. |
| Gateway with privileged control | Platform can provision files and later expose remote Git. |
| Web serving/proxy path | Student can play the generated DOS game in-browser. |
| Build/test execution | Container can run DOS/Turbo Pascal build and simple tests. |
| Local Git available | Learners can commit meaningful increments. |

Phase 1 uses only local Git inside the private EFS workspace. Phase 1.5 adds native Git remotes through the gateway using bare repositories and `git-http-backend`.

No external GitHub accounts are required. No Forgejo/Gitea is needed for the first course.

# 6. Project directory structure

Each learner receives a project like this:

```
corporate-ladder/ 
 README.md 
 CHANGELOG.md 
 
 docs/ 
 product-vision.md 
 requirements.md 
 technical-design.md 
 traceability-matrix.md 
 ai-collaboration-log.md 
 project-state.md 
 extension-backlog.md 
 
 src/ 
 CORPLADR.PAS 
 WORLD.PAS 
 PLAYER.PAS 
 ENEMY.PAS 
 SCREEN.PAS 
 GAME.PAS 
 
 tests/ 
 manual-acceptance-tests.md 
 TESTWORLD.PAS 
 TESTMOVE.PAS 
 TESTCOLL.PAS 
 
 build/ 
 build-log.txt 
 test-log.txt 
 manifest.json 
 
 public/ 
 index.html 
 play.html 
 build.html 
 traceability.html
```

For the first one-day pilot, the code may start smaller:

```
src/ 
 CORPLADR.PAS 
 WORLD.PAS 
 PLAYER.PAS 
 SCREEN.PAS
```

The important design principle is that the project lives in files, not in the chat.

conversation state≠project state\text{conversation state} \neq \text{project state}conversation state=project state

The canonical state is stored in the repository.

# 7. Game technical design

## 7.1 Core data model

The game should not hard-code behaviour directly against display characters everywhere. Instead, it should distinguish between static map tiles and dynamic entities.

pascal

```
type 
 TTile = (ttEmpty, ttWall, ttPlatform, ttLadder, ttExit); 
 
 TPlayer = record 
 X, Y: Integer; 
 Score: Integer; 
 Lives: Integer; 
 end; 
 
 TEnemy = record 
 X, Y: Integer; 
 DX: Integer; 
 end;
```

This teaches the distinction:

static world≠dynamic entities\text{static world} \neq \text{dynamic entities}static world=dynamic entities

That is a foundational design lesson.

## 7.2 Rendering seam

Rendering should be replaceable. The one-day version uses simple ASCII. Later, students can improve the visual layer using extended DOS characters, colour, or graphics.

A simple theme record is enough:

pascal

```
type 
 TTheme = record 
 EmptyChar: Char; 
 WallChar: Char; 
 PlatformChar: Char; 
 LadderChar: Char; 
 ExitChar: Char; 
 PlayerChar: Char; 
 EnemyChar: Char; 
 MoneyChar: Char; 
 end;
```

Basic theme:

pascal

```
const 
 BasicTheme: TTheme = ( 
 EmptyChar: '.'; 
 WallChar: '#'; 
 PlatformChar: '='; 
 LadderChar: 'H'; 
 ExitChar: 'E'; 
 PlayerChar: '@'; 
 EnemyChar: 'M'; 
 MoneyChar: '$' 
 );
```

This is the key extensibility seam:

change visual representation⇏change game rules\text{change visual representation} \not\Rightarrow \text{change game rules}change visual representation⇒change game rules

This is enough extensibility. It is not an engine. It is a small, intentional seam.

## 7.3 Movement

Horizontal movement is cell-based:

xt+1={xt−1,left pressed and target passablext+1,right pressed and target passablext,otherwisex_{t+1} =
\begin{cases}
x_t - 1, & \text{left pressed and target passable} \\
x_t + 1, & \text{right pressed and target passable} \\
x_t, & \text{otherwise}
\end{cases}xt+1​=⎩⎨⎧​xt​−1,xt​+1,xt​,​left pressed and target passableright pressed and target passableotherwise​

Ladder movement:

yt+1={yt−1,up pressed and ladder condition holdsyt+1,down pressed and ladder condition holdsyt,otherwisey_{t+1} =
\begin{cases}
y_t - 1, & \text{up pressed and ladder condition holds} \\
y_t + 1, & \text{down pressed and ladder condition holds} \\
y_t, & \text{otherwise}
\end{cases}yt+1​=⎩⎨⎧​yt​−1,yt​+1,yt​,​up pressed and ladder condition holdsdown pressed and ladder condition holdsotherwise​

Gravity:

yt+1={yt+1,unsupported and not on ladderyt,otherwisey_{t+1} =
\begin{cases}
y_t + 1, & \text{unsupported and not on ladder} \\
y_t, & \text{otherwise}
\end{cases}yt+1​={yt​+1,yt​,​unsupported and not on ladderotherwise​

For the one-day course, jumping is excluded. Ladders provide vertical movement. Jumping is a post-course enhancement.

## 7.4 Update order

The update order must be specified before implementation:

```
1. Read input. 
2. Apply player movement. 
3. Apply gravity. 
4. Collect dollar signs. 
5. Update enemy. 
6. Check player/enemy collision. 
7. Check exit condition. 
8. Render screen.
```

This teaches that even simple games have rule-order semantics. If update order is unspecified, an AI agent may produce inconsistent behaviour.

# 8. Requirements for the one-day game

Initial requirements:

| ID | Requirement |
| --- | --- |
| R-001 | The game shall render a fixed ASCII level in DOS text mode. |
| R-002 | The player shall be represented by `@`. |
| R-003 | The player shall move left and right by one cell when the target cell is passable. |
| R-004 | The player shall climb ladders represented by `H`. |
| R-005 | Platforms represented by `=` shall support the player. |
| R-006 | The player shall fall one cell per update when unsupported. |
| R-007 | Dollar signs represented by `$` shall be collected when the player enters their cell. |
| R-008 | The score shall increase when a dollar sign is collected. |
| R-009 | The exit represented by `E` shall complete the level only after all dollar signs have been collected. |
| R-010 | Middle management represented by `M` shall cause the player to lose when touched. |

The one-day minimum may implement R-001 to R-009 and leave R-010 as optional.

Acceptance criterion example:

```
T-007: Collect dollar sign 
 
Given the player is adjacent to a cell containing $ 
when the player moves into that cell 
then the $ disappears 
and the score increases by one.
```

Traceability:

| Requirement | Code area | Test |
| --- | --- | --- |
| R-003 | `PLAYER.PAS:TryMoveHorizontal` | T-003 |
| R-004 | `PLAYER.PAS:TryClimb` | T-004 |
| R-006 | `GAME.PAS:ApplyGravity` | T-006 |
| R-007 | `WORLD.PAS:CollectAtPlayer` | T-007 |
| R-009 | `GAME.PAS:CheckExit` | T-009 |

This is where the course makes software engineering concrete.

# 9. Agent operating protocol

The project agent should behave like a disciplined junior developer, not an autonomous product owner.

For any implementation request, the agent must follow:

```
1. Identify the requirement ID. 
2. Check whether the requirement exists. 
3. Check whether the design contract exists. 
4. Modify the smallest necessary file set. 
5. Avoid unrelated feature additions. 
6. Run build/test. 
7. Show changed files and diff summary. 
8. Update traceability. 
9. Propose a commit message. 
10. Commit only after learner approval.
```

The agent must not:

```
rewrite the whole project 
invent new mechanics 
silently change requirements 
modernise the target platform 
replace Turbo Pascal 
introduce a game engine 
commit without review 
publish broken builds
```

A good learner prompt:

```
Implement R-007. 
 
The player should collect dollar signs when entering their cell. 
Modify only WORLD.PAS, GAME.PAS, tests/manual-acceptance-tests.md, 
and docs/traceability-matrix.md. 
 
Do not add new enemy behaviour. 
Do not change rendering. 
Run the build and show the diff summary before proposing a commit.
```

This teaches that good AI use is not vague prompting. It is bounded task delegation.

# 10. Git workflow

## Phase 1: local Git

Each learner starts with a local repository in their private EFS workspace.

Initialisation:

Bash

```
git init --initial-branch=main 
git config user.name "Student {uid}" 
git config user.email "student-{uid}@course.local" 
 
git add . 
git commit -m "M0 initialise course project"
```

Learners use:

```
git status 
git diff 
git add 
git commit 
git log 
git branch 
git merge 
git tag
```

Every meaningful development step ends in a commit.

A good commit message:

```
R-007 implement dollar collection 
 
- Remove dollar sign when player enters its cell 
- Increment score 
- Add acceptance test T-007 
- Update traceability matrix 
 
Build: passed 
Tests: passed
```

Bad commit messages are explicitly discouraged:

```
update 
fix 
stuff 
AI changes 
final
```

The commit represents an engineering claim:

Gi=⟨ΔCi,Ri,Ti,Bi⟩G_i = \langle \Delta C_i, R_i, T_i, B_i \rangleGi​=⟨ΔCi​,Ri​,Ti​,Bi​⟩

## Phase 1.5: gateway Git remote

Later, add a native Git remote through the gateway:

```
https://ai-platform/git/retro-dos-sdd/{uid}/corporate-ladder.git
```

Implementation:

gateway auth+bare EFS repo+git-http-backend\text{gateway auth} + \text{bare EFS repo} + \texttt{git-http-backend}gateway auth+bare EFS repo+git-http-backend

Included:

```
clone 
fetch 
pull 
push 
branches 
tags
```

Excluded:

```
MRs 
PRs 
review comments 
approval workflow 
Forgejo/Gitea 
GitHub accounts
```

MRs/PRs are not native Git, so they are out of scope for the early platform.

# 11. Build, test, and browser play pipeline

The course platform should build after source changes or approved commits.

Pipeline:

```
source/spec change 
 ↓ 
agent writes files 
 ↓ 
build/test runs in container 
 ↓ 
Git diff inspected 
 ↓ 
local commit created 
 ↓ 
manifest records commit hash 
 ↓ 
latest green build published 
 ↓ 
browser DOS emulator plays the game
```

Build invariant:

publish⁡(c)  ⟺  build⁡(c)=passed∧tests⁡(c)=passed\operatorname{publish}(c) \iff
\operatorname{build}(c)=\text{passed}
\land
\operatorname{tests}(c)=\text{passed}publish(c)⟺build(c)=passed∧tests(c)=passed

Manifest example:

JSON

```
{ 
 "course": "spec-driven-ai-development", 
 "game": "the-corporate-ladder", 
 "student_uid": "uid-100231", 
 "branch": "main", 
 "commit": "8d0f4c2", 
 "build_status": "passed", 
 "tests_passed": 7, 
 "tests_failed": 0, 
 "published": true 
}
```

The evidence chain is:

playable game→build manifest→commit→diff→requirement\text{playable game} \rightarrow
\text{build manifest} \rightarrow
\text{commit} \rightarrow
\text{diff} \rightarrow
\text{requirement}playable game→build manifest→commit→diff→requirement

This is the strongest practical expression of the course.

# 12. One-day schedule

Assume a 7-hour training day excluding lunch.

## 09:00–09:30 — Orientation

Content:

```
platform overview 
AI agent role 
project files 
local Git repo 
browser play surface
```

Key message:

The AI agent proposes changes; the learner accepts or rejects them.\text{The AI agent proposes changes; the learner accepts or rejects them.}The AI agent proposes changes; the learner accepts or rejects them.

Deliverable:

```
M0 initial repo ready
```

## 09:30–10:15 — Game idea to requirements

Introduce:

```
The Corporate Ladder: Avoid Middle Management
```

Learners define or inspect requirements R-001 to R-009.

Deliverables:

```
docs/product-vision.md 
docs/requirements.md 
docs/traceability-matrix.md
```

Commit:

```
R-000 define game scope and requirements
```

## 10:15–11:00 — Technical design

Cover:

```
tiles vs entities 
player state 
level map 
rendering theme 
update order
```

Deliverables:

```
docs/technical-design.md 
src/WORLD.PAS skeleton 
src/PLAYER.PAS skeleton 
src/SCREEN.PAS skeleton
```

Commit:

```
R-001 define world and rendering design
```

## 11:00–12:15 — First implementation slice

Implement:

```
render fixed level 
draw player 
basic left/right movement
```

Agent task is constrained to selected files.

Deliverables:

```
src/CORPLADR.PAS 
src/WORLD.PAS 
src/SCREEN.PAS 
src/PLAYER.PAS
```

Build and play first version.

Commit:

```
R-001/R-003 render level and move player
```

## 12:15–13:00 — Lunch

## 13:00–14:00 — Ladders and gravity

Implement:

```
ladder climbing 
platform support 
falling when unsupported
```

Acceptance tests:

```
player can climb on H 
player cannot climb in empty space 
player falls when unsupported 
player does not fall through =
```

Commit:

```
R-004/R-006 implement ladders and gravity
```

## 14:00–15:00 — Collectibles and exit

Implement:

```
collect $ 
score increases 
exit locked until all $ collected 
win screen
```

Commit:

```
R-007/R-009 implement money collection and exit
```

## 15:00–15:45 — Middle management enemy

Implement if pace allows:

```
M patrols horizontally 
collision causes loss
```

Otherwise, instructor demonstrates it.

Commit:

```
R-010 implement middle management collision
```

Optional for slower class.

## 15:45–16:30 — Git milestone and browser playable build

Learners inspect:

Bash

```
git log --oneline 
git status 
git diff
```

Then tag:

Bash

```
git tag -a M1 -m "M1 playable Corporate Ladder vertical slice"
```

Platform publishes latest green build.

Deliverables:

```
build/manifest.json 
public/play.html 
Git tag M1
```

## 16:30–17:00 — Extensibility and post-course roadmap

Discuss:

```
YAGNI 
small seams 
future ASCII polish 
colours 
more levels 
sprites 
graphics 
sound 
gateway remote Git later
```

Deliverable:

```
docs/extension-backlog.md 
docs/retrospective.md
```

Final message:

> You did not build a full game engine. You built a small working game with clean seams.

# 13. Extensibility design

This must be taught carefully.

The principle is:

YAGNI now≠make future change impossible\text{YAGNI now} \neq \text{make future change impossible}YAGNI now=make future change impossible

The one-day version should avoid speculative architecture, but it should preserve clean seams.

Good seams:

| Likely future change | Seam |
| --- | --- |
| Better ASCII symbols | `TTheme` rendering map |
| Colours | `SCREEN.PAS` only |
| More levels | map arrays or level files |
| New enemies | `ENEMY.PAS` |
| Sprites/graphics | replace renderer, preserve game state |
| Sound effects | add `SOUND.PAS` |
| Scoreboard | add file I/O later |
| External level editor | later data-driven levels |

Bad over-engineering:

```
plugin system 
entity-component framework 
scripting engine 
generic game engine 
sprite editor on day one 
networking 
save-game framework 
complex physics
```

The course should teach:

small seams>large abstractions\text{small seams} > \text{large abstractions}small seams>large abstractions

This is consistent with Parnas’s information-hiding principle [2], Beck’s incremental delivery orientation [4], and Brooks’s warning that conceptual integrity is damaged by uncontrolled complexity [5].

# 14. Post-training enhancement ladder

At the end, students should be encouraged to continue building.

## Enhancement Phase A — Better ASCII

```
replace H with box-drawing ladder symbols 
replace # with block characters 
replace = with horizontal line characters 
add colour attributes 
add title screen 
add win/lose screens
```

## Enhancement Phase B — More gameplay

```
multiple levels 
timer 
lives 
score bonus 
moving enemies 
different middle-management behaviours 
fall penalty
```

## Enhancement Phase C — Better engineering

```
load levels from text files 
separate theme configuration 
high-score file 
testable enemy movement 
recorded input replay
```

## Enhancement Phase D — Graphics path

```
CGA graphics mode 
tile sprites 
simple animation 
sprite collision 
PC speaker sound
```

Every enhancement should follow the same discipline:

requirement→design→patch→test→commit→play\text{requirement} \rightarrow \text{design} \rightarrow \text{patch} \rightarrow \text{test} \rightarrow \text{commit} \rightarrow \text{play}requirement→design→patch→test→commit→play

# 15. Assessment rubric

For an internal one-day course, this can be lightweight rather than formal.

| Category | Weight |
| --- | --- |
| Requirements and acceptance criteria | 20% |
| Working playable slice | 25% |
| Traceability between requirement, code, and test | 15% |
| Git discipline and commit quality | 15% |
| AI-use discipline | 15% |
| Extensibility/backlog reflection | 10% |

The learner should not be rewarded merely for producing more code. They should be rewarded for producing controlled, verified, traceable changes.

# 16. Instructor preparation checklist

Before training day, prepare:

```
course template repo 
starter Pascal skeleton 
agent instructions 
build script 
test script 
browser play page 
sample level 
sample requirements 
sample traceability matrix 
local Git initialisation script 
fallback completed solution
```

The instructor should have three versions ready:

| Version | Purpose |
| --- | --- |
| Starter | Used by learners |
| Checkpoint | Used if class falls behind |
| Complete | Used for final demonstration |

This prevents the session from failing because of one implementation bottleneck.

# 17. Agent instruction summary

The course agent’s system role should say, in essence:

```
You are a Specification-Driven Development assistant for a one-day course. 
You help learners build The Corporate Ladder, a simple Turbo Pascal 7 DOS ASCII 
platform game. 
 
You must preserve traceability between requirements, design, code, tests, and Git 
commits. Make small changes only. Do not add features outside the current 
requirement. Do not modernise the target platform. After code changes, run the 
build/test process, summarise the diff, update traceability, and propose a commit 
message. Do not commit without learner approval.
```

This is the behavioural centre of the platform experience.

# 18. What is deliberately excluded from the one-day version

Explicit exclusions:

```
full game engine 
jumping physics 
multiple levels 
CGA graphics 
sprites 
sound 
QEMU validation 
gateway Git remote 
MRs/PRs 
Forgejo/Gitea 
external VS Code workflow 
complex collaboration
```

These are not rejected permanently. They are deferred.

The one-day course succeeds by teaching one complete disciplined loop, not by finishing every possible feature.

# 19. Final course blueprint

The final design is:

```
Course: 
 Specification-Driven AI Development 
 
Game: 
 The Corporate Ladder: Avoid Middle Management 
 
Product: 
 One-screen DOS ASCII platform game 
 
Mechanics: 
 move, climb, fall, collect $, avoid M, reach E 
 
Platform: 
 AI agent + isolated container + EFS + local Git + build/test + browser play 
 
Git: 
 local repo in Phase 1 
 gateway native Git remote in Phase 1.5 
 no MRs/PRs initially 
 
Pedagogy: 
 specification first 
 AI as bounded assistant 
 tests/acceptance as evidence 
 Git as project-state control 
 browser play as feedback 
 extensibility without over-engineering 
 
End state: 
 each learner has a playable game, a local Git history, a tagged milestone, 
 and a backlog for future enhancement.
```

This is a strong and coherent one-day corporate training course.

It is small enough to deliver, playful enough to motivate, and rigorous enough to teach real software-engineering discipline.

# References

[1] ISO/IEC/IEEE, *ISO/IEC/IEEE 29148:2018 Systems and Software Engineering — Life Cycle Processes — Requirements Engineering*. Geneva, Switzerland: ISO, 2018.

[2] D. L. Parnas, “On the Criteria To Be Used in Decomposing Systems into Modules,” *Communications of the ACM*, vol. 15, no. 12, pp. 1053–1058, Dec. 1972.

[3] C. A. R. Hoare, “An Axiomatic Basis for Computer Programming,” *Communications of the ACM*, vol. 12, no. 10, pp. 576–580, Oct. 1969.

[4] K. Beck, *Extreme Programming Explained: Embrace Change*. Reading, MA, USA: Addison-Wesley, 2000.

[5] F. P. Brooks, Jr., *The Mythical Man-Month: Essays on Software Engineering*, anniversary ed. Reading, MA, USA: Addison-Wesley, 1995.

[6] S. Chacon and B. Straub, *Pro Git*, 2nd ed. New York, NY, USA: Apress, 2014.

[7] N. Wirth, *Algorithms + Data Structures = Programs*. Englewood Cliffs, NJ, USA: Prentice-Hall, 1976.

[8] K. Salen and E. Zimmerman, *Rules of Play: Game Design Fundamentals*. Cambridge, MA, USA: MIT Press, 2003.

 
 
 

![](chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/browser/images/acrobat_dc_20x20_dark.svg)![](chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/browser/images/acrobat_prodc_appicon_24.svg)Convert to PDF

 

#### You said:

A key question at the start, that should be addressed is "Why this slower SDD, and not just vibe code it for quick results?"

 

#### ChatGPT said:

Thought for 11s

Yes. This should be one of the **opening framing questions** of the training.

The answer should not be defensive. It should say:

> We are not rejecting fast AI coding. We are learning when speed is real and when it is only the illusion of progress.

The key distinction is:

fast generation≠fast delivery\text{fast generation} \neq \text{fast delivery}fast generation=fast delivery

A model can produce code quickly. But delivery includes understanding, testing, debugging, integration, review, handover, and future change.

A useful framing equation is:

Tdelivery=Tspecification+Tgeneration+Tdebugging+Tintegration+TmaintenanceT_{\text{delivery}} =
T_{\text{specification}}
+
T_{\text{generation}}
+
T_{\text{debugging}}
+
T_{\text{integration}}
+
T_{\text{maintenance}}Tdelivery​=Tspecification​+Tgeneration​+Tdebugging​+Tintegration​+Tmaintenance​

“Vibe coding” minimises:

TgenerationT_{\text{generation}}Tgeneration​

but often increases:

Tdebugging+Tintegration+TmaintenanceT_{\text{debugging}} + T_{\text{integration}} + T_{\text{maintenance}}Tdebugging​+Tintegration​+Tmaintenance​

Specification-Driven Development deliberately increases the small upfront term:

TspecificationT_{\text{specification}}Tspecification​

to reduce the larger downstream terms.

## Opening answer for the course

I would present it like this:

> **Why not just vibe code it?**
> Because in a corporate engineering environment, the goal is not merely to make code appear. The goal is to produce software that can be understood, tested, changed, reviewed, handed over, and trusted. AI makes it easier than ever to generate plausible code quickly, but it also makes it easier to generate plausible wrong code quickly. Specification-Driven Development slows us down just enough at the beginning to prevent uncontrolled acceleration in the wrong direction.

Then give the core contrast:

| Vibe coding | Specification-Driven AI Development |
| --- | --- |
| Starts with a broad prompt | Starts with a bounded requirement |
| Optimises for visible output | Optimises for accepted behaviour |
| Relies on conversational plausibility | Relies on explicit acceptance criteria |
| Produces large unreviewed changes | Produces small inspectable diffs |
| Debugs after generation | Prevents ambiguity before generation |
| AI decides many hidden details | Human/specification controls decisions |
| Hard to maintain | Traceable and extensible |

The point is not:

vibe coding bad\text{vibe coding bad}vibe coding bad

The point is:

vibe coding is useful for exploration, not sufficient for accountable delivery\text{vibe coding is useful for exploration, not sufficient for accountable delivery}vibe coding is useful for exploration, not sufficient for accountable delivery

## The message to Vodacom employees

For this audience, I would make the corporate argument explicit:

> Inside a company, code is rarely just personal experimentation. It becomes part of a service, a workflow, a customer journey, a data pipeline, a compliance surface, or another team’s dependency. Once that happens, the question is not only “does it run?” The question is “can we explain it, test it, change it, recover it, and trust it?”

That is why the course uses a tiny game. The game is playful, but the workflow is serious:

requirement→AI patch→diff→test→commit→playable build\text{requirement} \rightarrow \text{AI patch} \rightarrow \text{diff} \rightarrow \text{test} \rightarrow \text{commit} \rightarrow \text{playable build}requirement→AI patch→diff→test→commit→playable build

The discipline learned on the game transfers directly to production AI-assisted development.

## A practical demonstration

At the start of the course, you can run a short contrast exercise.

### Prompt A: vibe-coded

```
Make me a DOS platform game in Turbo Pascal.
```

Likely result: lots of code, unclear assumptions, unpredictable structure, no traceability.

### Prompt B: specification-driven

```
Implement R-003: the player shall move one cell left or right when the target cell is passable. 
 
Constraints: 
- Turbo Pascal 7. 
- Modify only PLAYER.PAS and WORLD.PAS. 
- Do not change rendering. 
- Do not add jumping. 
- Return whether movement succeeded. 
- Update the acceptance test T-003.
```

Likely result: smaller patch, easier review, clearer behaviour, simpler testing.

This makes the trade-off visible immediately.

## The principle

The course should give learners this rule:

> Use vibe coding for exploration. Use Specification-Driven Development for delivery.

Or more sharply:

Vibe coding finds possibilities. SDD turns selected possibilities into controlled software.\text{Vibe coding finds possibilities. SDD turns selected possibilities into controlled software.}Vibe coding finds possibilities. SDD turns selected possibilities into controlled software.

That is the right balance. We do not want to kill experimentation. We want to prevent experiments from being mistaken for engineered increments.

## Why the retro game helps

The ASCII game makes this obvious. If the learner vaguely asks the agent:

```
Make the game better.
```

the agent may add jumping, colours, enemies, score changes, new files, and broken logic.

But if the learner says:

```
Implement R-007: collect dollar signs when the player enters their cell.
```

then the change is small, testable, and commit-worthy.

That is the habit we want:

small requirement→small patch→green build\text{small requirement} \rightarrow \text{small patch} \rightarrow \text{green build}small requirement→small patch→green build

not:

large wish→large generated mess\text{large wish} \rightarrow \text{large generated mess}large wish→large generated mess

## Suggested opening slide

```
Why not just vibe code it? 
 
Because fast code generation is not the same as fast, reliable delivery. 
 
In this course, we use AI for speed, 
but we use specifications, tests, and Git for control. 
 
The aim is not to type less. 
The aim is to lose less time to ambiguity, rework, and unreviewable code.
```

## Final course framing

The opening thesis should be:

> **AI gives us acceleration. Specification gives us steering. Git gives us memory. Tests give us evidence.**

That is a strong way to explain why the course is not merely about prompting.

## References

[1] ISO/IEC/IEEE, *ISO/IEC/IEEE 29148:2018 Systems and Software Engineering — Life Cycle Processes — Requirements Engineering*. Geneva, Switzerland: ISO, 2018.

[2] D. L. Parnas, “On the Criteria To Be Used in Decomposing Systems into Modules,” *Communications of the ACM*, vol. 15, no. 12, pp. 1053–1058, Dec. 1972.

[3] F. P. Brooks, Jr., *The Mythical Man-Month: Essays on Software Engineering*, anniversary ed. Reading, MA, USA: Addison-Wesley, 1995.

[4] K. Beck, *Extreme Programming Explained: Embrace Change*. Reading, MA, USA: Addison-Wesley, 2000.

 
 
 

Sources

![](chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/browser/images/acrobat_dc_20x20_dark.svg)![](chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/browser/images/acrobat_prodc_appicon_24.svg)Convert to PDF

 

#### You said:

Yes, and that is a perfectly good and correct answer, and perfecrly boring and does not quite the sceptics. 

We should show, not just tell. So try maybe a one shot at the start as baseline or something like that?

 

#### ChatGPT said:

Thought for 8s

Yes. The course should **demonstrate the failure mode**, not merely lecture about it.

The opening should be a controlled experiment:

# **Opening Experiment: The Vibe-Code Baseline**

Before teaching SDD, let the class try the obvious thing:

> “Ask the agent to build the game in one shot.”

Then inspect what happens.

The point is not to prove that AI is bad. The point is to show that unconstrained AI coding often produces **apparent progress without engineering control**.

# 1. Baseline exercise

At the start, give every learner the same blank or minimal project folder.

Then use one deliberately broad prompt:

```
Build a simple DOS ASCII platform game in Turbo Pascal 7 called The Corporate Ladder. 
 
The player should climb ladders, collect dollar signs, avoid middle management enemies, 
and reach the exit.
```

Timebox:

Tbaseline=20 minutesT_{\text{baseline}} = 20\text{ minutes}Tbaseline​=20 minutes

The agent is allowed to generate files. The learner is not yet taught the SDD method.

The result becomes the **baseline branch**:

Bash

```
git checkout -b baseline/vibe-code
```

or, if Git is not introduced yet, the platform can snapshot it as:

```
baseline-vibe-code/
```

# 2. What we measure

Do not merely ask, “Does it run?”

Measure the baseline against a small checklist:

| Question | Why it matters |
| --- | --- |
| Does it compile? | Generation is not delivery. |
| Does it run in the target DOS environment? | Environment assumptions matter. |
| Is the game actually playable? | Visible output is not necessarily usable output. |
| Are the rules clear? | Hidden assumptions create rework. |
| Are there tests or acceptance checks? | No evidence means no confidence. |
| Is the code modular? | Future change depends on structure. |
| Can we change one mechanic safely? | Maintainability test. |
| Is there a clean commit? | Project state must be recoverable. |
| Can another person understand it? | Corporate code is handed over. |

This gives a concrete scoring model:

Q=C+R+P+T+M+HQ = C + R + P + T + M + HQ=C+R+P+T+M+H

where:

C=compiles,R=runs,P=playable,T=tested,C = \text{compiles},\quad
R = \text{runs},\quad
P = \text{playable},\quad
T = \text{tested},C=compiles,R=runs,P=playable,T=tested,
M=maintainable,H=handover-ready.M = \text{maintainable},\quad
H = \text{handover-ready}.M=maintainable,H=handover-ready.

The one-shot baseline may score well on CCC and RRR, but usually poorly on TTT, MMM, and HHH. That is the teaching moment.

# 3. The crucial follow-up test

After the one-shot build, ask for one small change:

```
Change the ladder symbol from H to an extended DOS box-drawing character, 
without changing any movement or collision logic.
```

or:

```
Make the exit locked until all dollar signs are collected.
```

Then inspect what happens.

This is where vibe-coded systems often reveal the real cost. If rendering, movement, level data, and game rules are tangled together, a small change becomes risky.

The class sees the difference between:

code that exists\text{code that exists}code that exists

and:

code that can safely change\text{code that can safely change}code that can safely change

That distinction is central to the course. Parnas’s argument about modular decomposition around design decisions is directly relevant here: the visual representation of a tile should be isolated from the movement rules that interpret the tile [1].

# 4. Then introduce SDD as the fix

Only after the baseline do you introduce the disciplined method.

Say:

> “Now we are going to build a smaller version, more slowly at first. The goal is not to generate more code. The goal is to produce code we can explain, test, change, and commit.”

Then create the SDD branch:

Bash

```
git checkout -b main-sdd
```

or reset to the starter template.

Now the class builds the game through small requirements:

```
R-001: Render a fixed ASCII level. 
R-002: Draw the player as @. 
R-003: Move left and right across passable cells. 
R-004: Climb ladders represented by H. 
R-005: Collect $ when entering the cell. 
R-006: Exit only works after all $ are collected.
```

Each step follows:

Ri→Di→Ci→Ti→GiR_i \rightarrow D_i \rightarrow C_i \rightarrow T_i \rightarrow G_iRi​→Di​→Ci​→Ti​→Gi​

where:

Ri=requirement,Di=design,Ci=code,Ti=test,Gi=Git commit.R_i = \text{requirement},\quad
D_i = \text{design},\quad
C_i = \text{code},\quad
T_i = \text{test},\quad
G_i = \text{Git commit}.Ri​=requirement,Di​=design,Ci​=code,Ti​=test,Gi​=Git commit.

This lets learners compare two artefacts:

```
baseline/vibe-code 
main-sdd
```

The contrast is now empirical, not philosophical.

# 5. Make the comparison visible

At the end of the first half of the day, show a comparison table:

| Dimension | One-shot baseline | SDD version |
| --- | --- | --- |
| Code appeared quickly | Yes | Slower |
| Requirements explicit | No | Yes |
| Behaviour testable | Weak | Strong |
| Diff reviewable | Usually weak | Yes |
| Easy to change symbols | Maybe | Yes |
| Easy to add exit rule | Maybe | Yes |
| Build tied to commit | No/weak | Yes |
| Future extension path | Accidental | Designed seam |

The message becomes:

> The baseline was faster to generate. The SDD version is faster to trust, change, and extend.

That is the real answer to sceptics.

# 6. Important: make the baseline fair

Do not sabotage the prompt. The one-shot should be a genuine attempt.

A fair baseline prompt could be:

```
Create a small Turbo Pascal 7 DOS text-mode game called The Corporate Ladder. 
 
It should fit on one screen. Use @ for the player, H for ladders, = for platforms, 
$ for collectibles, M for enemies, and E for the exit. The player should climb 
ladders, collect all dollar signs, avoid enemies, and then reach the exit. 
 
Create whatever source files you think are needed.
```

This is realistic “vibe coding”. It is not maliciously vague. It is the kind of prompt a capable employee might naturally try.

Then the postmortem is credible.

# 7. What if the baseline works well?

That is fine. In fact, it is better.

If the one-shot baseline compiles and runs, the instructor says:

> “Good. AI is powerful. Now let us see whether we can safely change it.”

The sceptic’s strongest argument is not “AI can produce nothing”. AI clearly can produce useful code. The deeper question is:

Can we control, verify, and evolve what it produced?\text{Can we control, verify, and evolve what it produced?}Can we control, verify, and evolve what it produced?

So even a successful baseline helps.

The follow-up tests are what matter:

```
Can we add one rule without breaking another? 
Can we explain where movement is implemented? 
Can we test dollar collection without rendering? 
Can we change symbols without changing physics? 
Can we produce a clean commit?
```

That is where SDD earns its keep.

# 8. Revised opening sequence

The first 90 minutes should now be:

## 09:00–09:10 — Framing

Question:

> “Why not just vibe code it?”

Answer:

> “Let us try.”

## 09:10–09:30 — One-shot baseline

Students ask the agent to build the game from a broad prompt.

## 09:30–09:50 — Run and inspect

Check compile, run, playability, structure, and assumptions.

## 09:50–10:10 — Change request

Ask for one small change. Observe whether the generated design supports change.

## 10:10–10:30 — Debrief

Introduce the distinction:

fast generation≠fast delivery\text{fast generation} \neq \text{fast delivery}fast generation=fast delivery

Then begin the SDD build properly.

This opening will do more than any slide deck.

# 9. The line to use

The strongest framing sentence is:

> **We are going to vibe-code first, not because it is wrong, but because it gives us a baseline. Then we will rebuild the same idea with specifications and compare which version is easier to trust and change.**

That is fair, non-preachy, and difficult for sceptics to dismiss.

# 10. Final recommendation

Add a formal module at the start:

# **Module 0: Vibe-Code Baseline**

Deliverables:

```
baseline/vibe-code snapshot 
baseline build result 
baseline inspection checklist 
baseline change attempt 
short postmortem
```

Then proceed to:

# **Module 1: Specification-Driven Rebuild**

This gives the course a much stronger narrative:

Try the obvious fast path→observe its limits→introduce SDD as control, not bureaucracy\text{Try the obvious fast path}
\rightarrow
\text{observe its limits}
\rightarrow
\text{introduce SDD as control, not bureaucracy}Try the obvious fast path→observe its limits→introduce SDD as control, not bureaucracy

That will land much better with sceptics.

# References

[1] D. L. Parnas, “On the Criteria To Be Used in Decomposing Systems into Modules,” *Communications of the ACM*, vol. 15, no. 12, pp. 1053–1058, Dec. 1972.

[2] ISO/IEC/IEEE, *ISO/IEC/IEEE 29148:2018 Systems and Software Engineering — Life Cycle Processes — Requirements Engineering*. Geneva, Switzerland: ISO, 2018.

[3] F. P. Brooks, Jr., *The Mythical Man-Month: Essays on Software Engineering*, anniversary ed. Reading, MA, USA: Addison-Wesley, 1995.

[4] K. Beck, *Extreme Programming Explained: Embrace Change*. Reading, MA, USA: Addison-Wesley, 2000.

 
 
 

Sources

![](chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/browser/images/acrobat_dc_20x20_dark.svg)![](chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/browser/images/acrobat_prodc_appicon_24.svg)Convert to PDF

High

ChatGPT can make mistakes. Check important info.