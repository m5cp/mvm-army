# MVM Fitness — Sister-Service Tests + GPS Route Map (2026-07-31)

Feature branch: `feature/service-tests-gps-map`. Context doc for Rork —
preserve these behaviors on future edits. Never write "ACFT" anywhere.

## New tests in the Calculator tab

The Calculator tab's test picker is now a 3×2 grid: **AFT · CFT · NAVY ·
AIR FORCE · MARINES · ADVANCED**. AFT scoring is completely untouched
(`AFTScoringRegressionTests` must still pass with zero diffs).

Scoring engines (drop-in from Joe's files — treat their tables as
authoritative, never edit numbers):
- `Services/MilitaryServiceScoring.swift` — Navy PRT + Air Force PT tables
- `Services/MarineCorpsScoring.swift` — Marine PFT + CFT
- `Services/AdvancedReadinessScoring.swift` — proprietary Advanced Readiness
  benchmarks (matches `advanced_readiness_benchmark_scoring.xlsx`)

UI (`Views/ServiceTestCalculators.swift`):
- **Navy PRT** — age/sex/altitude, push-ups, forearm plank, cardio choice
  (1.5-mi run / 2 km row / 500 yd swim / 450 m swim); overall category +
  level from the engine's average.
- **Air Force PT** — age/sex, waist-to-height ratio (20), strength choice
  (push-ups / HR push-ups, 15), core choice (sit-ups / reverse crunch /
  plank, 15), cardio choice (2-mi run / HAMR, 50 — or 2-km walk pass/fail,
  which drops the composite denominator to 50). Composite = earned/possible
  × 100; ≥90 EXCELLENT, ≥75 SATISFACTORY, else UNSATISFACTORY.
- **Marines** — PFT/CFT sub-toggle. PFT: pull-ups or push-ups, plank, 3-mi
  run or 5000 m row. CFT: Movement to Contact, Ammo Lift, Maneuver Under
  Fire. Classification FIRST/SECOND/THIRD CLASS or FAILED, /300.
- **Advanced Readiness** — pick one of 5 proprietary benchmarks (Water Ops,
  Light Infantry, Special Operations, Tactical Mobility, Reconnaissance);
  weighted 0–100 with ELITE/ADVANCED/STRONG/DEVELOPING/FOUNDATION rating.
  The AFT-total event pre-fills from the user's latest saved AFT score.

## Persistence + everywhere else

- `Models/ServiceTestModels.swift` — unified `ServiceTestRecord`
  (branch, score, result label, pass, per-event details).
- Saved via `AppViewModel.saveServiceTestRecord` → DataStore key
  `serviceTestRecords` (iCloud-mirrored like everything else).
- **Progress tab**: new "Service Tests" history card.
- **Calendar**: logged AFT scores and service tests now appear as completed
  "Test" entries on their day.
- Daily log records test days.

## Share cards

`Views/ServiceTestShareSheet.swift` — identical Strava/IG format to the AFT
card: golden-hour photo default, user photo or camera/selfie background,
translucent plates behind all text, big Archivo score, result pill,
"▲ +X VS LAST" delta, event chips, Me vs Me + QR footer.

## GPS route map (Apple Fitness style)

`Views/RouteMapView.swift` — full-screen route with pinch/pan, Map /
Hybrid / Satellite switcher, start/finish pins, distance-duration-pace
plate. Entry points: tapping the route thumbnail on the Quick Start
completion screen, and tapping any GPS session row in Progress → Quick
Start history (rows with routes show a map glyph).

---

# Batch 3 — Personalization, Badges, Ghost Race, Test Day Mode (2026-07-31)

Branch `feature/polish-badges-ghostrace`. Preserve all of this on future edits.

- **Branch selection**: onboarding Training Setup now asks for Service Branch
  (Army default, plus Navy / Air Force / Marines / Fitness Athlete). It ONLY
  sets which calculator opens first (AppStorage `serviceBranch` +
  `defaultCalculatorTest`) — every test stays available to everyone, nothing
  about storage/sync depends on it, changeable in Profile → App → Service
  Branch. Fitness Athlete defaults to the AFT calculator.
- **Badges**: 25 total. Original 11 PNG coins unchanged; 14 new SF-Symbol
  coins: starters (Spread the word, Early bird, First mile), distance
  (25/100/500-mile clubs, 30-mile month), streaks (14/30-day), holiday awards
  earned by training on the day (Veterans Day Nov 11, Memorial Day = last
  Monday of May, Independence Day Jul 4, Army Birthday Jun 14), and Joint
  Force (log Navy + Air Force + Marine results). Tapping an EARNED badge
  opens a golden share card; earn haptics fire once per badge.
- **Ghost Race**: on the Quick Start selection screen, GPS activities with a
  previous session offer "Ghost Race". During the session: pacer track (amber
  you vs gray ghost), big ▲AHEAD/▼BEHIND readout, haptics on overtake
  (success), overtaken (warning), and ghost-closing-within-5s (pulse).
  Screen stays awake for all active sessions. Ghost uses the previous run's
  real distance-time curve (`routeTimeOffsets`, pause-adjusted moving time,
  now persisted on QuickStartRecord) with average-pace fallback for old
  records. Also fixed: resuming from pause no longer wipes the recorded route.
- **Test Day Mode**: button at the top of the AFT calculator actions. Guided
  full-screen proctor flow: briefing → 5 events in order with photos,
  instructions, a big stopwatch for SDC/PLK/2MR (times drop straight into the
  score, manual ± adjust), rep/weight entry for MDL/HRP, live points from
  AFTScoringEngine only, voice announcements (AVSpeechSynthesizer, toggleable),
  keep-awake, final GO/NO-GO summary with Save (standard AFT record flow) and
  the photo share card. AFT scoring untouched.
- **2MR auto-fill**: button under the 2-mile run input pulls the user's best
  recent running pace from Apple Health (workout read permission added) or
  falls back to in-app Quick Start runs; estimate = best pace × 2 mi.
- **Mile splits**: RouteMapView now pins MI 1 / MI 2… along the route with
  per-mile split times when timing data exists (older records: pin only).
- **Motion**: home hero photo stretches on pull-down; readiness score counts
  up on appear; today's-workout card zoom-transitions into its detail sheet.
- **Trend chart**: Progress → Service Tests card charts score-over-time per
  branch (menu to switch branch).
- **App icons**: Profile → App → App Icon offers Classic / Blackout / Golden
  Hour (alternate icon assets AppIconDark / AppIconGold, app target only).
