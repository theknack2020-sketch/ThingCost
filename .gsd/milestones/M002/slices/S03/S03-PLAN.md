# S03: Edge Cases & Stress Test

**Goal:** Verify app handles all edge cases gracefully, no crashes, no data corruption.
**Demo:** All edge case unit tests pass, UI test for edge cases passes, zero crashes.

## Must-Haves

- Empty name validation works (can't add item with blank name)
- Zero/negative price rejection
- Very large price values display correctly
- Very old purchase dates (years ago) work
- Today's date purchase works (minimum 1 day)
- Special characters in item name (emoji, unicode)
- Rapid add/delete doesn't crash
- 3-item limit enforced correctly at boundary
- Sort works with mixed data (new items, old items, expensive, cheap)
- Swipe delete confirmation
- Back navigation from all screens

## Verification

- Unit tests for edge case calculations
- UI test for edge case input validation
- Manual screenshots for display edge cases
- `xcodebuild test` all suites pass

## Tasks

- [ ] **T01: Add edge case unit tests** `est:30m`
  - Why: Current tests cover happy path only, need boundary testing
  - Files: `Tests/ItemTests.swift`
  - Do: Add tests for: very large price (999999999), very old date (10 years), price = 0.01, item with emoji name, all sort options with varied data
  - Verify: `xcodebuild test -only-testing:ThingCostTests`
  - Done when: All new tests pass

- [ ] **T02: Test input validation UI** `est:30m`
  - Why: AddItemView must reject invalid input gracefully
  - Files: `UITests/UIFlowTests.swift`, `Sources/Views/Screens/AddItemView.swift`
  - Do: UI test: try to add item with empty name (Add button should be disabled), try 0 price, verify DatePicker doesn't allow future dates. Also test max character length in name field
  - Verify: UI test passes
  - Done when: Invalid input properly rejected, no crashes

- [ ] **T03: Test display edge cases** `est:30m`
  - Why: Very large numbers, very long names, emoji can break layouts
  - Files: Various view files
  - Do: Add items with: very long name (50+ chars), very large price (₺999,999), emoji name, very old purchase date. Screenshot each to verify display
  - Verify: Visual inspection — no text clipping, no overflow
  - Done when: All edge case items display correctly

- [ ] **T04: Rapid action stress test** `est:15m`
  - Why: Rapid add/delete can expose race conditions in SwiftData
  - Files: `UITests/UIFlowTests.swift`
  - Do: UI test that rapidly adds 3 items then deletes them one by one. Also test rapid sort switching
  - Verify: No crashes, item count correct after operations
  - Done when: Stress test passes without errors

- [ ] **T05: Final all-tests run** `est:10m`
  - Why: Ensure no regressions from fixes
  - Files: All test files
  - Do: Run complete test suite (unit + UI), verify all pass
  - Verify: `xcodebuild test` all green
  - Done when: 100% pass rate, zero warnings

## Files Likely Touched

- `Tests/ItemTests.swift`
- `UITests/UIFlowTests.swift`
- `Sources/Views/Screens/AddItemView.swift`
- `Sources/Views/Components/ItemRowView.swift`
- `Sources/Views/Screens/ItemDetailView.swift`
