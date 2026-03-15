# M001: MVP Launch — Context

**Gathered:** 2026-03-15
**Status:** Ready for planning

## Project Description

ThingCost — a minimal iOS app that calculates and displays the daily cost of things you own. Add any purchase, see how the daily cost drops over time. Share beautiful cost cards on social media.

## Why This Milestone

This is the only milestone for v1. Ship a complete, polished app to the App Store with core functionality + viral sharing mechanic + monetization.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Add items with name, price, purchase date, and optional photo/icon
- See a list of all items sorted by daily cost, with live-updating costs
- Tap an item to see detailed cost breakdown and cost-over-time graph
- Generate and share a beautiful "cost card" image to Instagram/TikTok/any app
- See a home screen widget showing daily costs of top items
- Unlock unlimited items via a one-time $2.99 purchase (3 free)

### Entry point / environment

- Entry point: iOS app launch from home screen or widget tap
- Environment: iPhone running iOS 17+
- Live dependencies involved: StoreKit (App Store for IAP), no backend

## Completion Class

- Contract complete means: all views render, items persist, share card generates, IAP flow works in sandbox
- Integration complete means: widget shows real data, share card opens in share sheet, IAP processes
- Operational complete means: app launches clean on real device, widget updates daily, IAP works on TestFlight

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- User can add 3 items, see daily costs update, share a card, and hit the paywall on 4th item
- Widget displays real item data on home screen
- IAP purchase unlocks unlimited items and persists across app restart

## Risks and Unknowns

- Share card design quality — must be visually compelling for social sharing
- StoreKit 2 sandbox testing reliability
- Widget refresh timing — daily cost changes slowly, should be fine

## Existing Codebase / Prior Art

- No existing code — greenfield project

## Scope

### In Scope

- Item CRUD (add, edit, delete)
- Daily cost calculation (price / days since purchase)
- Item list with sorting
- Item detail with cost-over-time visualization
- Share card generation and sharing
- Home screen widget (small + medium)
- Freemium IAP (3 free, $2.99 unlimited)
- Category/icon selection for items
- Onboarding with example item

### Out of Scope / Non-Goals

- Cloud sync / multi-device
- Social features / leaderboards
- Camera-based receipt scanning
- Price comparison / shopping features
- Apple Watch app
- iPad-specific layout (works but not optimized)
- Localization beyond EN/TR

## Technical Constraints

- iOS 17+ minimum deployment target
- SwiftUI only (no UIKit except for image rendering bridge)
- No external dependencies — all Apple frameworks
- No backend / API calls

## Integration Points

- StoreKit 2 — IAP for premium unlock
- WidgetKit — home screen widget
- UIActivityViewController — share sheet
- PhotosUI — optional item photo from library

## Open Questions

- Exact share card designs — will iterate during S03
- Whether to include "projected future cost" (e.g., "in 1 year it'll be ₺1.2/day")
