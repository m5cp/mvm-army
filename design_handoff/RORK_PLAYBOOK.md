# MVM Fit — Golden Hour Redesign: Rork Playbook

Prepared by Benny, 2026-07-29. For Joe. One phase at a time; the app must build,
run, and pass `AFTScoringRegressionTests` after **every** phase.

---

## Part 1 — How this works (read once)

**The pipeline:** Claude Design produced the design package → Benny adapted it to
the real codebase (this folder) → the whole thing gets committed to GitHub →
Rork syncs from GitHub and you drive it with the phase prompts in Part 3, one at
a time, in order.

**Why GitHub for assets (your question):** Yes — the assets must be in the repo.
Rork's 2-way GitHub sync is how it sees files; chat-uploading ~35 files is
unreliable and loses the exact catalog structure. Claude Design can't push to
GitHub itself. This drop-in already contains every asset in the exact folder
format Xcode needs, so "uploading assets" = one commit of this bundle.

**Why the asset commit is build-safe:** the images go *inside*
`ios/MVMFitness/Assets.xcassets/` as `.imageset` folders — asset catalogs
auto-include their contents, no Xcode project edits needed. The splash video and
the Archivo font go in `ios/MVMFitness/Resources/` — this project uses Xcode
filesystem-synchronized groups (`objectVersion 77`), so files dropped into the
folder are picked up automatically. Nothing in `project.pbxproj` needs to change.

**The one landmine (why refined-swift/ exists):** that same auto-include means
any `.swift` file placed under `ios/` gets **compiled into the app**. The design
package's prototype code contains `IllustrativeScoring` (fake AFT math — a
ship-blocker) and a duplicate `AFTEvent` enum that collides with the app's real
`AFTEventType`. So all reference code lives here in `design_handoff/` (outside
`ios/`), and only the two pre-adapted files in `refined-swift/` ever get copied
into the app target — by Rork, in Phase 1, to exact destinations.

**What's in the drop-in:**

| Path | What | Goes into the build? |
|---|---|---|
| `CLAUDE.md` (repo root) | Design constraints for any AI touching the repo | No (context only) |
| `ios/MVMFitness/Assets.xcassets/*.imageset` | 30 photos/badges + 1 SVG glyph, hash-checked: no duplicates of existing catalog images | Yes, automatically |
| `ios/MVMFitness/Resources/splash-runner-loop.mp4` | Splash video, transcoded H.265/hvc1, **0.4 MB** (spec said ≤3 MB) | Yes, automatically |
| `ios/MVMFitness/Resources/Archivo-Bold.ttf` | Display font (OFL license), PostScript name fixed to `Archivo-Bold`; registered at runtime — **no Info.plist change needed** | Yes, automatically |
| `design_handoff/refined-swift/MVMTheme.swift` | Merged theme: every legacy token name kept (2,373 references keep compiling), values re-mapped green→amber, Golden Hour tokens added | Phase 1 copies it in |
| `design_handoff/refined-swift/GoldenComponents.swift` | Prototype components adapted: no duplicate event enum, chips use the app's `AFTEventType` | Phase 1 copies it in |
| `design_handoff/swift/` | Original Claude Design prototype code — **reference only, never copy into ios/** | Never |
| `design_handoff/design/` | HTML design references (master + calculator prototype) | Never |
| `design_handoff/README.md` | The design spec (screens, tokens, grade recipes, interactions) | Never |
| `design_handoff/brand/` | App-icon candidate (separate decision, not part of this reskin) | Never |

**Getting it onto GitHub (pick one):**
- *You upload:* unzip `mvm-golden-hour-dropin.zip`, go to github.com/m5cp/mvm-army
  → "Add file" → "Upload files", drag in the three items (`CLAUDE.md`,
  `design_handoff`, `ios`) together, commit to `main` with message
  `Golden Hour design drop-in (assets + refs, no code changes)`. GitHub merges
  new files into existing folders; every path is new, nothing is overwritten.
- *I push:* give me a GitHub fine-grained token with write access to this one
  repo and I'll push it on a branch for your review instead.

**Before Phase 1:** in Rork, clone the project (Rork guide habit: clone before
big risky changes). That's your instant rollback if anything goes sideways.

---

## Part 2 — Ground truth about the current app (why the prompts say what they say)

Verified against the live repo on 2026-07-29:

- **Scoring is real and tested.** `AFTScoringEngine` + `aft_scoring_2025_06_01.json`
  (10,100 official entries) + `AFTScoringRegressionTests` (exact-cell checks).
  The engine API: `score(...)`, `evaluate(...)`, `rawNeeded(...)`, `entries(for:)`.
  The redesigned Score sheet gets its live points AND its min/max references from
  this engine — nothing else. The prototype's `IllustrativeScoring` never ships.
- **Event type:** `AFTEventType` (`mdl, hrp, sdc, plk, run2mi`). UI shows
  `MDL · HRP · SDC · PLK · 2MR` via the `displayCode` extension in
  GoldenComponents. No second enum.
- **3 tabs today** (Home / Progress / Profile), custom Liquid Glass tab bar, one
  `NavigationStack` per tab, `AppViewModel` in the environment. The redesign's
  naive `TabView` prototype must NOT replace this scaffolding — Phase 3 extends it.
- **Much more app than the 9 designed screens:** Squad, Unit PT, WODs, ABCP, CFT,
  DA-705 export, Quick Start, calendar, paywall/Pro gate, AI insights, QR
  share, Watch app, widget, Live Activities. These keep working at every phase;
  the global re-theme restyles them via the shared tokens.
- **Theme merge strategy:** legacy token names are preserved with new amber
  values → the entire app re-themes in one file swap without touching 60+ views.
  `success`/`danger` stay green/red (pass/fail semantics), slate/navy stay as
  categorical surfaces.

**Standard guardrail footer** — every prompt below ends with it. It's distilled
from the MF Elite 1.1.0→1.1.1 lessons (phase everything; guardrail every prompt;
regression-frame, don't symptom-frame):

> GUARDRAILS: Only modify the files listed above. Do not modify any
> .entitlements file, signing settings, project.pbxproj, Info.plist keys,
> asset catalogs, `aft_scoring_2025_06_01.json`, or anything in
> `Services/AFTScoringEngine.swift`, `Services/AFTScoringTables.swift`,
> `Services/AFTCalculatorService.swift`, or the test targets. Never copy
> anything from `design_handoff/swift/` into `ios/` — it is reference only.
> After the change: build, run ALL tests, and confirm
> `AFTScoringRegressionTests` passes with zero numeric diffs. If anything
> fails, stop and report — do not attempt broad fixes.

---

## Part 3 — The phase prompts (paste into Rork one at a time)

### Phase 0 — Sync + baseline (nothing changes)

```
A design drop-in was just committed to GitHub: repo-root CLAUDE.md, a
design_handoff/ reference folder, ~31 new imagesets in
ios/MVMFitness/Assets.xcassets, and two new files in ios/MVMFitness/Resources
(splash-runner-loop.mp4, Archivo-Bold.ttf). Pull the latest main.

Make NO code changes. Just: (1) confirm the new assets and resources are
visible in the project, (2) build the app, (3) run the full test suite
including AFTScoringRegressionTests, and (4) report results. Read repo-root
CLAUDE.md and design_handoff/README.md — they govern all upcoming work. This
is a baseline check before a phased redesign.
```

✅ Gate: build green, all tests pass, Rork confirms it can see the assets.

### Phase 1 — Theme foundation (the whole app turns amber)

```
Phase 1 of the Golden Hour redesign (spec: design_handoff/README.md).
Exactly two file operations, both from design_handoff/refined-swift/:

1. REPLACE ios/MVMFitness/Utilities/MVMTheme.swift with
   design_handoff/refined-swift/MVMTheme.swift — copy it verbatim, byte for
   byte. It intentionally keeps every legacy token name (the app has ~2,300
   references to them) while re-mapping values to the amber palette, and adds
   the new Golden Hour tokens and the runtime font registration for
   Archivo-Bold. Do not "improve" or reorganize it.
2. ADD design_handoff/refined-swift/GoldenComponents.swift as
   ios/MVMFitness/Utilities/GoldenComponents.swift, verbatim.

Expected effect: the entire app shifts from green to the dark-amber Golden
Hour look through the shared tokens alone. Screens are NOT redesigned yet.
If any view fails to compile, fix ONLY by adjusting that view's use of a
token, never by renaming or removing tokens in MVMTheme.

Then verify in the running app: score numerals on the AFT calculator render
in Archivo (or SF Rounded fallback), no screen shows leftover green from a
hardcoded hex, and text remains readable on the new dark background. List
any screens with hardcoded green hex values you noticed but did NOT change.

GUARDRAILS: [footer]
```

✅ Gate: build + tests green; app visibly amber; Rork's list of stray-green
screens saved for Phase 7 cleanup.

### Phase 2 — Splash

```
Phase 2: rebuild the launch experience per design_handoff/README.md
(SplashView row) and design_handoff/swift/SplashView.swift (visual reference
only — recreate with this codebase's patterns, don't port verbatim).

Modify ONLY ios/MVMFitness/Views/SplashView.swift (and, if launch wiring
requires it, the minimal call-site in MVMFitnessApp.swift/ContentView.swift):
- Muted, looping playback of the bundled resource splash-runner-loop.mp4
  (H.265, already in Resources) using AVPlayer/AVPlayerLayer or VideoPlayer,
  aspect-fill, with a radial scrim, the mvm-glyph-summit-m asset + wordmark.
- Auto-dismiss after ~3.5 s OR first tap, whichever comes first.
- COLD LAUNCH ONLY — never on foregrounding from background.
- If the video fails to load for any reason, fall back instantly to the
  current static splash content on MVMTheme.screen. Never block launch.

GUARDRAILS: [footer]
```

✅ Gate: cold launch shows video ≤3.5 s; backgrounding/foregrounding does NOT
replay it; airplane-mode launch still works (it's bundled, but check).

### Phase 3 — Five tabs (the structural phase — do this one alone, nothing else)

```
Phase 3: restructure navigation from 3 tabs to 5 per design_handoff/README.md:
Home · Score · Train · Trend · You (SF Symbols per
design_handoff/swift/MainTabView.swift reference; amber selected tint).

KEEP the existing architecture: the AppTab enum pattern, one NavigationStack
per tab with its own NavigationPath, the custom Liquid Glass tab bar
implementation, AppViewModel environment wiring, and the keep-alive ZStack
approach. Extend AppTab to five cases; do not replace MainTabView with a
plain TabView.

Content mapping (reuse existing screens; this phase restyles nothing):
- Home  → existing HomeView
- Score → existing AFT calculator flow (AFTCalculatorView / AFTScoreSheet),
          now reachable as a top-level tab
- Train → existing PlanView content (Individual PT, Functional Fitness, Unit
          PT, WODs, Quick Start entry points)
- Trend → existing ProgressViewScreen
- You   → existing ProfileView

HARD RULE — nothing orphaned: every feature reachable before this change
must remain reachable after it (Squad, Unit PT builder, ABCP, CFT, DA-705
export, Quick Start, calendar, saved AFT results, AI insights, Resources,
settings, paywall/upgrade, legal screens, QR share/scan). If a Home entry
point logically moves (e.g. calculator links now living on Score), keep a
path to it from its old context too. When done, output a navigation map:
every screen and which tab/path now reaches it, marking anything that moved.

GUARDRAILS: [footer]
```

✅ Gate: build + tests green; walk all 5 tabs; check the navigation map against
the app — especially Squad, DA-705 export, ABCP/CFT, saved results, upgrade
screen. **Do not proceed until you've personally tapped through this.**

### Phase 4 — Score sheet (the calculator — highest-care phase)

```
Phase 4: redesign the Score tab per design_handoff/README.md (ScoreSheetView
row), reference design_handoff/swift/ScoreSheetView.swift and the working
interaction prototype design_handoff/design/MVM Calculator.dc.html. Recreate
the look in the EXISTING calculator views (AFTCalculatorView/AFTScoreSheet)
— restyle and relayout, do not build a parallel calculator.

Layout: spec-sheet rows — event code chip (MDL/HRP/SDC/PLK/2MR) · raw input
in an InsetWell · live points. Sex, age band, and standard pickers stay
always visible and every event row shows its min(60-pt)/max(100-pt)
reference for the CURRENT sex/age band/standard selection.

SCORING RULES (mission-critical):
- Points come ONLY from the existing AFTScoringEngine (its score/evaluate
  API). Min/max references come ONLY from the engine's table data (its
  rawNeeded/entries API for points 60 and 100). Zero scoring or threshold
  math in the view layer.
- The prototype's IllustrativeScoring / interpolation must not appear
  anywhere. If the design's interaction and the engine's exact table lookup
  ever disagree, THE ENGINE WINS.
- Typing a raw value recomputes points live; changing any picker updates
  every row's min/max refs and re-scores; total, pass/fail, and
  minimum-total-required stay wired to evaluate() exactly as today.
- Keep every existing capability reachable from Score: save result, saved
  results list, share, goal mode, score tables view, DA-705 export.

Typography rules from repo-root CLAUDE.md are non-negotiable: every numeric
value lineLimit(1) + fixedSize(), labels above values, middle dots not
hyphens, Archivo (MVMTheme.scoreDisplay) only for the big score numerals.

GUARDRAILS: [footer]
```

✅ Gate — manual spot-check after tests pass (values from the official tables,
same cells the regression tests pin): Male 17-21 General — MDL 340 → 100 pts,
MDL 150 → 60 pts; HRP 58 → 100; SDC 2:28 → 60. Female 17-21 — MDL 220 → 100;
SDC 1:55 → 100. Male 37-41 — MDL 140 → 60. PLK 3:40 → 100 / 1:30 → 60 (any
column). Flip sex/age/standard pickers and watch min/max refs change per row.

### Phase 5 — Home

```
Phase 5: redesign HomeView per design_handoff/README.md screens 13a/13b,
reference design_handoff/swift/HomeView.swift. Modify ONLY HomeView.swift
(+ small extracted subviews if needed, new files under Views/).

- Full-bleed hero: GradedPhoto(name: "hero-runner-dusk", grade: .heroDuotone)
  (or hero-rucker-night as alternate), date line, "Me vs Me." statement.
- Readiness plaque (RaisedCard): latest AFT total in
  MVMTheme.scoreDisplay(76), margin over minimum, per-event status from the
  user's saved results via the existing stores/view models — no new storage.
- Graded session card for today's/next session (lowKeyGym grade) linking
  into the existing plan flow.
- 13b first-run state: no scores yet → baseline call-to-action into Score;
  no plan yet → into Train. Never show placeholder numbers.
- Existing Home functionality that survived Phase 3's mapping stays
  reachable (steps, quick actions, activation checklist, recap banner...).
  Restyle with RaisedCard/InsetWell/MetricCell rather than removing.

GUARDRAILS: [footer]
```

✅ Gate: fresh-install run shows 13b state; seeded run shows real numbers;
every card still navigates.

### Phase 6 — Train + builder

```
Phase 6: redesign the Train tab per design_handoff/README.md screens
14a/14b, references TrainView.swift and WorkoutBuilderView.swift in
design_handoff/swift/. Restyle the EXISTING plan/workout screens and
builder sheets — do not create a parallel training system, and do not touch
the workout generation/library services.

- 14a: active plan card (photo + progress pips + Start), premade plan cards
  (thumbnailNeutral photo thumbs from the ex-* / photo-* imagesets + event
  tag chips), build-your-own entry.
- 14b builder: name well; TARGETS / EST TIME / BLOCKS chips (MetricCell);
  movement blocks with SETS/HOLD/LOAD wells; EventTagChip per movement.
- Event tags are STRUCTURED data: AFTEventType values on movements/plans
  (this powers "targets your weakest event" on Home and badge rules later).
  Wire them to the existing workout/exercise models' fields if present;
  otherwise add an optional tags field to the models WITHOUT altering any
  existing persistence/decoding behavior (new field must be optional and
  backward-compatible with previously saved data — old saved workouts must
  still load).
- Compound values use middle dots (3·1·1), never hyphens; all numeric wells
  lineLimit(1) + fixedSize().

GUARDRAILS: [footer]
```

✅ Gate: previously saved workouts/plans still open (backward compatibility!);
building + starting a workout works end to end; timers/Live Activities intact.

### Phase 7 — Result plaque, Badges, Profile + green sweep

```
Phase 7, three visual items plus cleanup:

1. Result presentation per README (ResultView row, screens 10c/10d):
   restyle the existing post-calculation result into the plaque treatment —
   total in MVMTheme.scoreDisplay(64), margin-over-minimum table per event,
   delta vs previous saved test (baseline treatment when it's the first
   test). Data from existing evaluate() results and saved-results store only.
2. Badges per screen 15a, reference BadgesView.swift: a 3×3 BadgeCoin grid
   using the icon3d-* imagesets; earned = color + amber ring, locked =
   grayscale. Earn rules read existing logged data (streaks from logged
   sessions, improvement vs last recorded test, event-tag coverage). Badge
   art is reward art only — never navigation, never buttons. Hang it off
   You (or Trend) per the design; if a milestone system already exists,
   restyle it rather than duplicating it.
3. Profile (You) per screen 10g: SF Symbol avatar default; optional user
   photo stays on-device only (existing ProfileImageManager); restyle rows
   with plaque/well treatment. All settings/legal/upgrade rows keep working.
4. Green sweep: fix the hardcoded-green-hex list from Phase 1 by switching
   those views to MVMTheme tokens. Do not change pass/fail semantic colors.

GUARDRAILS: [footer]
```

✅ Gate: build + tests; badges show LOCKED correctly for a fresh account; no
green remnants anywhere except semantic success states.

### Phase 8 — Watch

```
Phase 8 (final): re-theme the Watch app to Golden Hour. Modify ONLY
ios/MVMFitnessWatch/WatchTheme.swift — map its tokens to the amber palette
(background #0F0D0A, amber #E8A33D, text #F2EDE4, wells #0C0908) keeping
every token name and all Watch functionality identical. No layout changes,
no new assets on the watch, no entitlement or capability changes of any
kind. (Reminder from MF Elite: watch-target entitlement/capability changes
were the thing that blocked an entire App Store submission — we are not
touching any of that.)

GUARDRAILS: [footer]
```

✅ Gate: watch builds, timer/AFT views readable, complications/widget
unaffected.

---

## Part 4 — If something breaks

- **Isolate by phase.** Each phase is one commit trail in Rork/GitHub — revert
  the phase, don't debug forward on a broken base (and the Phase 0 clone is the
  nuclear option).
- **Regression-frame it for Rork** (the MF Elite method): "Phase N-1 built and
  passed tests; Phase N fails with X; only files A, B changed — find the cause
  in that diff." Never just paste the symptom.
- **Scoring diffs are an automatic stop.** If `AFTScoringRegressionTests` ever
  fails: revert the phase entirely. No partial fixes to anything near the
  engine, the JSON, or the tests themselves. If Rork proposes "updating the
  test expectations" — that is the failure mode, refuse.
- **Verify-don't-rewrite** for config-smelling problems (fonts not rendering,
  video not found): make Rork check the *built product* ("list the bundle's
  resources") before letting it touch code.
- **Version discipline:** everything here can ship as one version. Feature-size
  it if review timing matters — the reskin (Phases 1-2-4-5) is shippable
  without the 5-tab restructure if you ever need to split.

## Part 5 — Deferred decisions (not in this pass)

- App icon swap (`design_handoff/brand/mvm-icon-4a-1024.png`) — App
  Store-facing, own decision, trivially separate.
- Marketing/App Store screenshots re-shoot after the reskin ships.
- `corner-boxer` asset is spare by design; `golden-runner-*`,
  `photo-founders-trail-run`, `kettlebell-swing` are available for
  onboarding/share-card passes later.
