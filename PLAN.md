# Liquid Glass tab bar, fix dark text, auto AI insights, remove PDF import

## What I found in your screenshots

1. **Tab bar** — currently a solid dark bar with a hard top border. Not glassy.
2. **Black-on-black text:**
   - "Progress" large nav title renders in near-black (toolbar background is forcing dark color scheme on a dark background, so the system title color disappears).
   - "Danger Zone" header and the app version footer on Profile are using a very faded tertiary gray that's nearly invisible on the dark background.
3. **Apple Intelligence** — the AI Insights card exists on the Progress tab but only shows insight after tapping "Generate." You want it to surface insights automatically.
4. **Import Exercises from PDF** — present as a row on Home's planning section.

## Changes I'll make

**Tab bar (Liquid Glass)**
- Rebuild the custom tab bar with a translucent Liquid Glass look on iOS 26 (using `.glassEffect` in a `GlassEffectContainer`), falling back to `.ultraThinMaterial` on iOS 18.
- Remove the solid background fill and the hard hairline border; let the content scroll behind it with a soft top edge.
- Keep the same three tabs (Home / Progress / Profile), same icons, same bounce animation, same accent-green selection state.

**Fix black-on-black text**
- Progress screen: make the large "Progress" title render in white (force the title color so it's visible on the dark background).
- Profile "Danger Zone" header: bump to a readable secondary white instead of faded tertiary.
- Profile footer ("MVM FITNESS / Me vs Me / Version / disclaimer"): raise opacity so it's legible in dark mode.

**Apple Intelligence insights (auto-surface)**
- On the Progress tab, auto-generate the performance insight on first appearance (when Apple Intelligence is available) instead of requiring a tap.
- Keep the manual refresh button and the Weekly / Coaching tabs as-is.
- Keep the iOS 26 availability guard and the graceful fallback card for older devices.

**Remove PDF import**
- Delete the "Import Exercises from PDF" row from the Home planning list. No other plan rows change.
- Leave the underlying PDF upload screen file in place (unused) so nothing else breaks; only the entry point is removed.

No other screens, flows, or logic will be touched.