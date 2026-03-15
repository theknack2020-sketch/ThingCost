# M001: MVP Launch

**Vision:** Ship a polished, minimal iOS app that shows the daily cost of everything you own, with viral share cards and a clean freemium model.

## Success Criteria

- User can add items and see accurate daily cost calculations
- Share cards are visually compelling and generate as images ready for social media
- Widget shows live daily cost data on home screen
- Freemium gate works: 3 free items, IAP unlocks unlimited
- App feels fast, polished, and delightful to use

## Key Risks / Unknowns

- Share card visual quality — must be good enough that people actually share
- StoreKit 2 sandbox testing — can be flaky, needs thorough testing

## Proof Strategy

- Share card quality → retire in S03 by proving cards render beautifully and share correctly
- StoreKit 2 reliability → retire in S04 by proving purchase flow works in sandbox

## Verification Classes

- Contract verification: unit tests for cost calculation, SwiftData persistence
- Integration verification: widget shows real data, share sheet works, IAP processes
- Operational verification: app launches on real device, widget refreshes, IAP on TestFlight
- UAT / human verification: share card visual quality, overall UX feel

## Milestone Definition of Done

This milestone is complete only when all are true:

- All 5 slices complete and verified
- App builds and runs on simulator and real device
- Core flow works: add item → see cost → share card → hit paywall → purchase → add more
- Widget displays real item data
- Ready for App Store submission (icons, screenshots, metadata)

## Slices

- [x] **S01: Core Data Model + Item List** `risk:medium` `depends:[]`
  > After this: user can add items with name/price/date, see them in a list with daily costs, edit and delete items. All persisted with SwiftData.

- [x] **S02: Item Detail + Cost Visualization** `risk:low` `depends:[S01]`
  > After this: user can tap an item to see detailed cost breakdown, cost-over-time graph, and projected future costs.

- [x] **S03: Share Cards + Viral Loop** `risk:high` `depends:[S01]`
  > After this: user can generate beautiful share card images and share them via the system share sheet to Instagram/TikTok/any app.

- [ ] **S04: Freemium IAP** `risk:medium` `depends:[S01]`
  > After this: app enforces 3-item free limit, offers $2.99 one-time purchase for unlimited items, handles restore purchases.

- [ ] **S05: Widget + Polish** `risk:low` `depends:[S01,S02]`
  > After this: home screen widget (small + medium) shows top items with daily costs. App has onboarding, app icon, and launch polish.

## Boundary Map

### S01 → S02

Produces:
- `Item` SwiftData @Model with name, price, purchaseDate, category, iconName
- `dailyCost` computed property on Item
- Item CRUD operations working

Consumes:
- nothing (first slice)

### S01 → S03

Produces:
- `Item` model with all display properties
- Item list/detail views for context

Consumes:
- nothing (first slice)

### S01 → S04

Produces:
- `Item` model and item count
- Item add flow (to gate behind paywall)

Consumes:
- nothing (first slice)

### S01 + S02 → S05

Produces:
- `Item` model and SwiftData container
- Cost calculation logic

Consumes:
- S01: Item model and persistence
- S02: Detail view patterns
