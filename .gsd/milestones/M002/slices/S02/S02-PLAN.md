# S02: Widget, Lifecycle & Theme Verification

**Goal:** Verify widget shows real data, app data persists through kill/relaunch, theme switching works.
**Demo:** Widget screenshot on home screen, app relaunch with data intact, theme toggle working.

## Must-Haves

- Widget (small + medium) displays real item data from SwiftData
- App data survives terminate + relaunch
- Settings theme toggle works (system/light/dark)
- Theme preference persists after app restart
- Onboarding doesn't re-show after completion

## Verification

- Install widget on simulator, screenshot with data visible
- Kill app, relaunch, verify items still present
- Toggle each theme in settings, verify visual change
- Kill/relaunch after theme change, verify theme persists

## Tasks

- [ ] **T01: Test widget on simulator** `est:30m`
  - Why: Widget is a key feature but hasn't been visually verified on home screen
  - Files: `Widget/ThingCostWidget.swift`
  - Do: Add widget to simulator home screen (small + medium sizes), verify it shows real item data. Check layout, text, and colors
  - Verify: Screenshot of widgets on home screen
  - Done when: Both widget sizes show correct item data

- [ ] **T02: Test app lifecycle (kill/relaunch)** `est:15m`
  - Why: Data persistence is critical — users will lose trust if items disappear
  - Files: `Sources/App/ThingCostApp.swift`, `Sources/Models/Item.swift`
  - Do: Add items, force-kill app (simctl terminate), relaunch, verify all items present
  - Verify: Screenshot comparison before/after kill
  - Done when: All items present after relaunch

- [ ] **T03: Test theme switching** `est:20m`
  - Why: Theme was just added, needs visual verification
  - Files: `Sources/Views/Screens/SettingsView.swift`, `Sources/App/ThingCostApp.swift`
  - Do: Open settings, switch to dark, verify dark mode. Switch to light, verify. Switch to system. Kill/relaunch, verify theme persists
  - Verify: Screenshots in each theme mode
  - Done when: All 3 theme modes work and persist

- [ ] **T04: Fix any issues found** `est:20m`
  - Why: Bugs found in T01-T03 must be fixed
  - Files: Various
  - Do: Fix widget layout, data issues, theme bugs
  - Verify: Re-verify after fixes
  - Done when: All verifications pass

## Files Likely Touched

- `Widget/ThingCostWidget.swift`
- `Sources/App/ThingCostApp.swift`
- `Sources/Views/Screens/SettingsView.swift`
- `Sources/Models/AppTheme.swift`
