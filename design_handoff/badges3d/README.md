# Handoff: MVM Fitness — 3D Achievement Badges (v2)

Task for Claude Code: replace the app's existing challenge-coin badge assets with the 3D badge set in this bundle, wire the new/renamed achievements into the badge catalog, and commit the changes to the GitHub repo.

## Hard constraints

> **One thing you must not ship as-is: the thresholds are illustrative** — linear interpolation between the 60 and 100 marks, with plausible sex/age/combat factors. That's stated on the screen. Swap in the official tables and the UI renders whatever they return; nothing about the layout depends on my numbers.
> The official tables live in `aft_scoring_2025_06_01.json` in the repo and are authoritative. Any prototype scoring math is presentation-only.

- Scoring engine is mission-critical: never change its behavior. `AFTScoringRegressionTests` must pass with zero numeric diffs.
- No military insignia, rank, uniforms, flags, weapons, or aircraft in imagery. The badge icons here are deliberately generic (anchor, paper plane, globe — NOT service insignia). Do not "improve" them toward official emblems.
- No text may bleed, clip, or truncate. Badge names / how-to lines use `lineLimit` + `minimumScaleFactor`, never fixed-height containers. Respect Dynamic Type.
- UI text: SF Pro at Apple's sizes/weights. UI symbols stay SF Symbols — the badge PNGs are award imagery, not UI glyphs.

## About the files
- `assets/` — **production assets, use exactly as-is.** 32 badges (`badge-<id>.png`, 1024×1024 transparent PNG, ids match catalog.json) + `badge-rosette-premium.png` (congrats-sheet hero).
- `catalog.json` — source of truth for the achievement list: id → { name, group, how, citation }. Ship in bundle or mirror into Swift.
- `design/` — HTML design references, NOT production code. Recreate layouts in SwiftUI with the app's existing patterns. `badge-forge.html` is the 3D source used to render the PNGs (keep for future re-bakes; do not integrate).

## What changed vs the previous challenge-coin set
1. All coin-style assets replaced by 3D rendered badges (glossy PBR metals). Delete old `icon3d-*` / coin imagesets; add one imageset per PNG here.
2. 7 new achievements: 60/90-day, 6-month, 12-month streaks; Marine Corps (Nov 10), Navy (Oct 13), Air Force (Sep 18) birthdays.
3. Grouping changed from metal tiers to 5 sections, in this order: Getting started · Consistency · Streaks · Milestones · Honors (`group` field: start / consistency / streaks / milestones / honors).
4. Every badge card now shows a "how to earn" line (`how`) under the name. `citation` is the flavor line shown once earned.
5. Congrats moment: `badge-rosette-premium.png` on the award sheet — slow float (5s ease-in-out, ±10pt), radial amber glow behind, "Congrats!" headline, white pill Continue button.

## Achievements screen spec (You tab)
- Background `#0E0F12`; cards `#16171C`, corner radius 26, no border.
- Card layout (centered column): badge image 128pt → name (SF Pro Semibold 14, `#E8E9EB`) → how-to (SF Pro Regular 12, `#7C7E83`) → status caps label (10pt, tracking 0.16em): EARNED `#E0A23C` / LOCKED `#5B5D62`.
- Earned: full color + radial glow `rgba(246,195,79,0.22)` behind the image. Locked: ~60% grayscale + ~0.67 opacity via modifiers (`saturation`/`opacity`) — do NOT ship separate locked assets.
- Section headers: caps 13pt bold, tracking 0.2em, hairline rule to the right, earned count "n/m" right-aligned.
- Grid: 3 columns on iPhone (the 5-column design file is a desktop reference).
- Header stats: Earned count + total.

## Badge model
id, name, group, how, citation, earned (Bool), earnedDate (Date?). Streaks computed from consecutive training days; honors from training-session date matching the holiday; miles from cumulative tracked distance.

## Git
Work on a feature branch (suggest `feature/badges-3d`), commit in logical chunks (assets, catalog/model, UI), run `AFTScoringRegressionTests` before the final commit, then push and open a PR. Do not force-push or commit directly to main.
