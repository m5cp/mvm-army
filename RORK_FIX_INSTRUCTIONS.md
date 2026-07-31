# MVM Fitness — UI Fix Instructions (2026-07-31)

Paste this into Rork to reproduce the fixes, or just merge branch
`fix/ui-polish-cft-share` which already contains all of them.
Rules that must hold everywhere: never write "ACFT" (the test is the **AFT**;
the field test is the **CFT**), keep the Golden Hour amber theme, SF Symbols
only for icons, badge coin PNGs (`icon3d-*`) are reward art only.

## 1. Whole cards must be tappable (all screens)

- `Utilities/GoldenComponents.swift` — add
  `.contentShape(RoundedRectangle(cornerRadius: radius))` to `RaisedCard`
  right after its `clipShape`. This makes every RaisedCard-as-button-label
  hittable across its full area (padding and Spacer regions included).
- `Views/HomeView.swift` — the **No AFT Score Yet** plaque had the Button
  *inside* the RaisedCard, so only the text was tappable. Restructure: the
  Button now wraps the whole `RaisedCard` (see `noScoreCard`), split out from
  `readinessScoreCard(_:)`.
- `Views/ActivationChecklistCard.swift` — add `.contentShape(Rectangle())` to
  the checklist row button label.
- Rule going forward: any card that acts as a button must have the Button
  wrapping the card, and the label must carry a `contentShape`.

## 2. Workout blocks match the Golden Hour theme

- `Views/ActiveSessionView.swift` — the current-exercise block used a leftover
  blue/purple gradient (`#3B6DE0/#5B4DC7/#4A3DAF`). Replace with the amber
  family `#B87718 → #8A5A12 → #5E3C0B`; "Mark Done" text uses
  `MVMTheme.onAmber` instead of navy.
- `Models/QuickStartModels.swift` — `gradientHex` per activity replaced with
  amber variants (outdoorRun `#F2B358/#DD9027`, indoorRun `#E8A33D/#B87718`,
  functionalFitness unchanged `#D97706/#B45309`, outdoorBike `#D99A33/#A06A1B`,
  indoorBike `#C98F3A/#8B5E34`, outdoorHike `#B87718/#8A5A12`).
- `Views/AFTGoalModeView.swift` — "Share Goal Card" button background is
  `MVMTheme.amberButtonGradient` (was blue/purple), text `MVMTheme.onAmber`.

## 3. Tab bar never covers content + hides on scroll

`Views/MainTabView.swift`:
- New `@Observable @MainActor final class TabBarState { var isHidden }` with a
  spring-animated `setHidden(_:)`, injected via `.environment(tabBarState)`.
- New `HidesTabBarOnScroll` ViewModifier using iOS 18
  `onScrollGeometryChange`: scrolling down > 3pt hides the bar, any upward
  scroll or offset ≤ 24 shows it. Exposed as `.hidesTabBarOnScroll()`.
- The bar overlay gets `.offset(y: hidden ? reserved + 60 : 0)`, `.opacity`,
  `.allowsHitTesting(!hidden)`, `.accessibilityHidden(hidden)`.
- Reserved bottom inset is the measured bar height **plus 12pt clearance**.
- Apply `.hidesTabBarOnScroll()` to the root ScrollView of all five tabs:
  HomeView, AFTCalculatorView, PlanView, ProgressViewScreen, ProfileView.

## 4. Top-corner buttons always do something

`Views/HomeView.swift` toolbar Menu (the "⋯" that was empty before a plan
existed):
- Always show **Refresh Today** (`arrow.clockwise`) — refreshes steps, syncs
  today, ensures today's workout, refreshes the hero date.
- With a plan: **Regenerate Week** (icon changed to
  `arrow.trianglehead.2.clockwise.rotate.90` so it isn't confused with
  refresh) and **Export to Calendar**.
- Without a plan: **Build Weekly Plan**.
The Score tab's `clock.arrow.circlepath` history button already opens Saved
AFT Scores and is now only shown while the AFT test is selected.

## 5. CFT selectable in the Calculator tab

- `Views/CFTView.swift` — split into a thin `CFTView` sheet wrapper (Profile
  entry unchanged) and an embeddable `CFTContent` holding the stopwatch,
  7-event checklist, history, result/info sheets, plus a new photo-backed
  info banner card (`photo-ruck-man-scree`) that opens "About the CFT".
- `Views/AFTCalculatorView.swift` — new `FitnessTestKind` enum (`AFT` /
  `CFT`) and a `testPicker` segmented control at the top of the tab, styled
  exactly like the STANDARD toggle ("5 EVENTS · SCORED" vs "7 EVENTS ·
  GO/NO-GO"). AFT shows the existing calculator; CFT shows `CFTContent`.
  Navigation title switches accordingly. AFT scoring logic untouched
  (AFTScoringRegressionTests must still pass with zero diffs).

## 6. Share AFT Score card — full redesign (Strava/IG style)

`Views/AFTShareSheet.swift` rewritten:
- **Backgrounds**: "Golden Hour" bundled sunrise-silhouette photo
  (`photo-run-silhouette-sunrise`) by default, **My Photo** via PhotosPicker,
  or **Camera** (front camera first, for selfies at the actual test) via a
  `CameraPicker` UIImagePickerController wrapper. User photos are used only
  in the rendered card, never persisted.
- **Readability**: top and bottom black gradient scrims plus rounded
  translucent dark plates behind every text block, so text never gets lost in
  the photo — same trick Strava/Instagram use.
- **Card (1080×1350)**: MVM FITNESS header + ARMY FITNESS TEST + date on the
  top scrim; centered amber-outlined score plate with the total in the
  Archivo display face (`/500` beside it), a solid **GO / NO GO** pill and a
  "▲ +12 VS LAST" delta chip; a row of five event chips (MDL·HRP·SDC·PLK·2MR
  with points and raw values); footer "Me vs Me." + GET THE APP QR code.
- `AFTCardRenderer.render(score:previous:background:)` — background defaults
  to nil (bundled photo), so the existing `ShareCardRenderer` call still works.
- `project.pbxproj` — camera usage description updated to cover score-card
  photos/selfies (both configurations).

## 7. Every card carries a photo (all 13 unused uploads wired in)

New `CardPhotoThumb` + `EventPhotoChip` components in
`Utilities/GoldenComponents.swift` (photos graded `thumbnailNeutral` or
`goldenSilhouette`; event chips overlay the event code on a dark scrim).

| Asset | Now used on |
|---|---|
| golden-runner-portrait | No AFT Score Yet card + 2MR calculator row |
| photo-run-silhouette-sunrise | Quick Start card + default share-card background |
| corner-boxer | Generate FunctionFitness card |
| kettlebell-swing | Today's FunctionFitness card |
| golden-runner-wide | No Workout Scheduled card |
| ex-hex-deadlift | Plan My Individual PT row + MDL calculator row |
| ex-ab-rollout | Plan My FunctionFitness row |
| photo-ruck-man-coldbreath | Plan My Unit PT row |
| photo-ruck-woman-rimlight | My Squad row |
| ex-hand-release-pushup | HRP calculator row |
| ex-farmer-carry | SDC calculator row |
| ex-plank-weighted | PLK calculator row |
| ex-dead-bug | Recovery & Mobility card (Train tab) |
| photo-ruck-man-scree | CFT info banner |
| icon3d-kettlebell / icon3d-run | Two new earnable badges: "FunctionFitness" (any FunctionFitness workout logged) and "Quick starter" (any Quick Start activity logged) — reward art only, per the imagery rules |
