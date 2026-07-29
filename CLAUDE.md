# MVM Fit — constraints for this codebase

## Scoring (mission-critical)
- **Never change scoring behavior.** `AFTScoringRegressionTests` must pass with zero numeric diffs.
- Official tables: `aft_scoring_2025_06_01.json` (authoritative). Any interpolation in handoff Swift is presentation-only placeholder — swap the official tables in; the UI renders whatever they return.
- Calculator inputs always linked to sex, age band, and standard; min/max references visible per event.

## Typography & symbols (non-negotiable)
- No text may bleed, clip, or truncate. No value breaks mid-token (`3-1-\n1` is a defect). Every numeric/metric value: `lineLimit(1)` + `fixedSize()`.
- Metric cells stack label ABOVE value.
- Compound values use middle dots (`3·1·1`), never hyphens.
- SF Pro / SF Pro Rounded at Apple sizes; display face (Archivo) only for score numerals. Respect Dynamic Type — no fixed-height text containers.
- SF Symbols via `Image(systemName:)` only. No traced SVG paths, icon fonts, or third-party icon sets. Match symbol weight to adjacent text; tint with `.foregroundStyle`.

## Imagery
- Independent of DoD/Army: no uniforms, insignia, rank, unit patches, flags, camo, weapons, aircraft, or working dogs.
- Photography neutral/desaturated at the source; amber comes from the grade layer, not the photo. Golden-hour silhouettes are the one exception.
- Badge coin PNGs are reward art only — never navigation or UI chrome.
- User avatar defaults to an SF Symbol; optional user photo stays on device only.
