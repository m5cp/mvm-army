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
