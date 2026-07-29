# Handoff: MVM Fit — Golden Hour / Spec-Sheet Redesign (SwiftUI)

## ⚠️ Hard constraints — read first

> **One thing you must not ship as-is: the thresholds are illustrative** — linear interpolation between the 60 and 100 marks, with plausible sex/age/combat factors. That's stated on the screen. Swap in the official tables and the UI renders whatever they return; nothing about the layout depends on my numbers.

- The official tables live in `aft_scoring_2025_06_01.json` **in the app repo** and are authoritative. All prototype scoring math is presentation-only.
- **The scoring engine's behavior must not change.** `AFTScoringRegressionTests` must pass with zero numeric diffs after the re-skin.
- The app is independent of the DoD/Army: no uniforms, insignia, rank, unit patches, flags, camo, weapons, aircraft, or working dogs in any imagery. Every asset in `assets/` has been screened.
- Calculator inputs stay linked to **sex, age band, and standard**, with min/max references visible per event.
- Full constraint list in `CLAUDE.md` (typography, symbols, imagery rules). Put it at the repo root for Claude Code.

## Overview
A full visual redesign of MVM Fit ("Me vs Me"), an AFT score calculator + trainer. Dark UI (near-black warm ground), amber accent, raised-surface elevation system ("plaque" cards with inset value wells), spec-sheet data discipline, and graded golden-hour photography. Five tabs: **Home · Score · Train · Trend · You**.

## About the design files
Files in `design/` are **design references created in HTML** — prototypes showing intended look and behavior, not production code. The task is to **recreate these designs in the target codebase's existing SwiftUI environment** using its established patterns. `design/MVM Redesign.dc.html` is the master (turns 15 → 1, newest first; screens 13a/13b, 14a/14b, 10a–10h, 15a are the shipping direction). `design/MVM Calculator.dc.html` is a working prototype of the Score sheet — lift its interaction logic, not its markup.

> **Rork note:** Rork accepts Swift. The `swift/` sources are the implementation — refine them in Claude Code / Cowork first for exactness, then upload to Rork as-is. Keep every token, size, and rule identical if any file is regenerated.

## Fidelity
**High-fidelity.** Colors, type sizes, radii, shadows, spacing, and copy are final. Recreate pixel-perfectly with the codebase's existing components where they exist.

## Screens
| Swift file | Design ref | Purpose |
|---|---|---|
| SplashView.swift | 5a/8c + `assets/splash-runner-loop.mp4` | Cold-launch only. Muted looping video, radial scrim, logo + wordmark, auto-dismiss ≈3.5s or first tap |
| MainTabView.swift | 6a | Five tabs, SF Symbols, amber selected tint |
| HomeView.swift | 13a / 13b | Full-bleed silhouette header, date line, "Me vs Me." statement, readiness plaque, graded session card. 13b = first-run state |
| ScoreSheetView.swift | 10b + Calculator prototype | Spec-sheet rows: event code · raw input well · points. Sex / age band / standard pickers, min/max refs per event |
| ResultView.swift | 10c / 10d | Plaque total, margin-over-minimum table, delta vs previous (baseline treatment on first test) |
| TrainView.swift | 14a | Active plan card (photo, progress pips, Start), premade plans (photo thumbs + event tags), build-your-own entry |
| WorkoutBuilderView.swift | 14b | Name well, TARGETS/EST TIME/BLOCKS chips, movement blocks with SETS/HOLD/LOAD wells, event-tag chips |
| BadgesView.swift | 15a | 3×3 coin grid: earned = color + amber ring, locked = grayscale. Art = static PNGs, never UI chrome |
| ProfileView.swift | 10g | SF Symbol avatar default; user photo optional, on-device only |

## Design tokens (MVMTheme.swift)
Colors: base `#0F0D0A`, screen `#0B0908`, card gradient `#1C1613→#141010`, well `#0C0908`, text `#F2EDE4`, muted = text @ 50%, amber `#E8A33D`, amber button gradient `#F2B358→#DD9027`, text-on-amber `#180F06`, duotone ground `#A84A16`.
Radii: screen cards 24–26 · raised cards 20 · wells 13–15 · buttons 14–18 · coins/avatars circle.
Elevation: raised = gradient fill + 1px `white@7%` border + inner top highlight `white@7%` + drop shadow y12 r24 `black@100%→0`; inset = well fill + inner shadow y2 r6 `black@85%`.
Type: SF Pro / SF Pro Rounded at Apple sizes only. Display face (Archivo, bundled) **only** for score numerals (76pt readiness, 64pt plaque totals). Mono values = SF Mono, tracking .12em on labels.

## Typography & symbol rules (non-negotiable)
- No text may bleed, clip, or truncate. Every numeric/metric value: `lineLimit(1)` + `fixedSize()`.
- Metric cells stack **label above value** (see `MetricCell` in Components.swift).
- Compound values use middle dots (`3·1·1`), never hyphens.
- SF Symbols via `Image(systemName:)` only — no traced paths, icon fonts, or third-party sets. Match weight to adjacent text; tint with `.foregroundStyle`.
- Respect Dynamic Type; never fixed-height text containers.

## Photo grade recipes (GradedPhoto in Components.swift)
- **Hero duotone** (home hero): `saturation(0) · contrast(1.25)` over `#A84A16` ground, linear fade to base at 98%
- **Low-key gym** (session headers): `brightness(-0.18) · saturation(0.62) · contrast(1.08)` + 9% amber wash + bottom scrim from 34%
- **Golden silhouette** (splash/onboarding/share): `contrast(1.16) · saturation(1.08)`, radial vignette 72% — the only place original color survives
- **Thumbnail neutral** (58pt exercise chips): `saturation(0.28) · brightness(-0.08)`, no overlay

## Interactions
- Score sheet: typing a raw value recomputes points live; pickers (sex/age/standard) update every min/max ref. Values sync both ways with the result plaque.
- Train: event tags (PLK/MDL/HRP/SDC/2MR) on every movement are what let Home say "targets your weakest event" — the builder can't be a free-text field.
- Badges: earn rules read the same event tags; streak coins count logged sessions, improvement coins compare against the last recorded test.
- Splash: cold launch only; never on foregrounding.

## Assets (`assets/`)
Photography (screened, no DoD imagery): golden-runner-portrait/wide.jpg, hero-runner-dusk.png, hero-rucker-night.png, lowkey-kettlebells.jpg, kettlebell-swing.png, corner-boxer.png (spare), photo-* series (ruck/run), ex-*.jpg exercise stills (plank, dead bug, ab rollout, hex deadlift, hand-release push-up, farmer carry — neutral ground, for 58pt chips).
Badge coins: icon3d-*.png (kettlebell, barbell, dumbbell, run, ruck, plate, timer, shaker, pack, trophy, laurel) — static PNGs on baked dark-gray ground; crop circle, scale ≈1.3.
Brand: mvm-icon-*.png/svg app icons, mvm-glyph-summit-m.svg.
Video: **splash-runner-loop.mp4** (golden-hour runner loop) → SplashView; transcode to H.265 ≤3MB before bundling.

## Files
- `design/MVM Redesign.dc.html` — master design reference (open in a browser; needs the sibling js files)
- `design/MVM Calculator.dc.html` — working calculator prototype (interaction + illustrative math)
- `swift/` — SwiftUI sources (this package's spec-in-code)
- `CLAUDE.md` — constraints for Claude Code; copy to repo root
