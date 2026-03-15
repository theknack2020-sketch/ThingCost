# M002: Comprehensive QA & Bug Fix — Context

**Gathered:** 2026-03-16
**Status:** Ready for execution

## Project Description

ThingCost MVP (M001) is feature-complete. This milestone is a thorough QA pass covering every screen, every interaction, edge cases, visual quality, data persistence, and widget behavior. Bugs found are fixed immediately.

## Why This Milestone

M001 was built slice-by-slice with unit + UI flow tests, but several areas haven't been visually inspected or stress-tested: share card rendering quality, widget display, edge cases (empty input, huge values, special characters), app lifecycle (kill/relaunch data persistence), and settings/theme switching. These must be verified before App Store submission.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Trust that every screen looks correct in both EN/TR, light/dark
- Trust that share cards render beautifully in all 3 styles
- Trust that widgets display correct data on home screen
- Trust that the app handles edge cases gracefully without crashes

### Entry point / environment

- Entry point: ThingCost.app on iOS Simulator (iPhone 17 Pro)
- Environment: Xcode 26.3 simulator, debug build
- Live dependencies involved: none (StoreKit sandbox only)

## Completion Class

- Contract complete means: all existing unit tests pass, new edge case tests pass
- Integration complete means: widget shows real SwiftData, share cards render as images
- Operational complete means: app survives kill/relaunch, data persists

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- Every screen screenshot-verified in both light and dark mode
- Share cards render correctly in all 3 styles with real data
- Widget displays on simulator home screen with correct data
- Edge cases (empty, huge values, special chars) don't crash
- App data survives kill/relaunch cycle

## Risks and Unknowns

- Widget testing on simulator may have limitations
- Share card ImageRenderer quality depends on screen scale

## Existing Codebase / Prior Art

- `Sources/Views/` — all view files to test
- `Widget/ThingCostWidget.swift` — widget to verify
- `Sources/Services/ShareService.swift` — image rendering
- `Tests/ItemTests.swift` — existing unit tests
- `UITests/UIFlowTests.swift` — existing UI flow test

## Scope

### In Scope

- Visual verification of all screens (screenshot-based)
- Share card quality check (all 3 styles)
- Widget testing
- Edge case testing and fixes
- Data persistence verification
- Theme switching verification
- Bug fixes for anything found

### Out of Scope / Non-Goals

- Real device testing (requires TestFlight)
- App Store screenshots/metadata
- Performance profiling
- Accessibility audit (VoiceOver)

## Technical Constraints

- Simulator only (no real IAP, no real device)
- Screenshots via `xcrun simctl io`
- No Screen Recording permission for mac_screenshot
