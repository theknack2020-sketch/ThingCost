# M002: Comprehensive QA & Bug Fix

**Vision:** Every screen verified, every edge case tested, every bug found and fixed. Ship-ready quality.

## Success Criteria

- All screens render correctly in light + dark mode, EN + TR
- Share cards produce high-quality images in all 3 styles
- Widget shows real data on home screen
- No crashes on edge case input
- Data persists through app kill/relaunch
- Theme switching works correctly

## Key Risks / Unknowns

- Widget may not be testable in all scenarios on simulator
- ImageRenderer quality may vary

## Verification Classes

- Contract verification: unit tests for edge cases, existing 10 tests pass
- Integration verification: widget shows SwiftData, share cards render
- Operational verification: app lifecycle (kill/relaunch), theme persistence
- UAT / human verification: share card visual quality, overall polish

## Milestone Definition of Done

This milestone is complete only when all are true:

- All slices complete with screenshots proving each verification
- Zero known crashes or visual bugs
- All unit + UI tests pass
- App is ship-ready for App Store review

## Slices

- [x] **S01: Share Card Quality & Visual Verification** `risk:high` `depends:[]`
  > After this: all 3 share card styles verified to render beautifully with real data, screenshots captured as evidence.

- [x] **S02: Widget, Lifecycle & Theme Verification** `risk:medium` `depends:[]`
  > After this: widget shows correct data, app survives kill/relaunch, theme switching works in settings.

- [x] **S03: Edge Cases & Stress Test** `risk:medium` `depends:[]`
  > After this: app handles empty input, huge values, special characters, rapid actions without crashes. All edge case tests pass.
