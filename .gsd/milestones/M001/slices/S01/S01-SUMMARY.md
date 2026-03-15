---
status: complete
started: 2026-03-15
completed: 2026-03-16
---

# S01: Core Data Model + Item List — Summary

## What Was Built

- **Item model** (`@Model`): name, price, purchaseDate, category, iconName, createdAt + computed dailyCost, monthlyCost, yearlyCost, costMilestones
- **ItemCategory enum**: 8 categories with SF Symbol icons and colors
- **SortOption enum**: 7 sort options (daily cost, price, date, name)
- **ItemListView**: total daily/monthly cost header, sorted item list, sort menu, swipe actions (delete + edit), empty state
- **AddItemView**: form with live cost preview, category picker, date picker
- **EditItemView**: pre-populated form, save updates
- **ItemRowView**: category icon, name, days owned, daily cost display

## Key Decisions

- Used `@Query(sort: \Item.createdAt)` with client-side sorting via `sortedItems` computed property — SwiftData @Query can't sort on computed properties
- Tap-to-edit (sheet) + swipe-to-edit/delete pattern for item management
- Sort state is in-memory (resets on app restart) — fine for this app size

## Verification

- Build: ✓
- Tests: 10/10 passing (cost calculation, projections, milestones, categories, sort options)
- App launches on iPhone 17 Pro simulator
