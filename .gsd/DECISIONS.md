# Decisions

## D001: SwiftData over Core Data
**Date:** 2026-03-15
**Context:** Need local persistence for items. SwiftData is modern, less boilerplate, works natively with SwiftUI.
**Decision:** Use SwiftData with @Model and @Query.
**Rationale:** New project, iOS 17+ minimum, no legacy constraints.

## D002: MVVM with @Observable
**Date:** 2026-03-15
**Context:** Need testable architecture without over-engineering.
**Decision:** MVVM with @Observable for ViewModels. SwiftData @Query used directly in views where appropriate.
**Rationale:** Good balance of testability and simplicity. @Query works best directly in views.

## D003: Freemium monetization — 3 free items
**Date:** 2026-03-15
**Context:** Need monetization that doesn't alienate users.
**Decision:** 3 items free, unlimited via $2.99 one-time IAP.
**Rationale:** Enough to demonstrate value, low enough barrier to share, clear upgrade path.

## D004: Calculation based on purchase date
**Date:** 2026-03-15
**Context:** Daily cost = price / days since purchase. Counts from purchase date, not add date.
**Decision:** User enters purchase date. Days owned = today - purchase date. Daily cost = price / days owned.
**Rationale:** Accuracy matters for the share card — users want to show real daily cost.

## D005: Share card as rendered image
**Date:** 2026-03-15
**Context:** Share cards need to look good on Instagram/TikTok stories.
**Decision:** Render share cards as images using SwiftUI → UIImage rendering. Multiple card styles available.
**Rationale:** Images are universally shareable. Pre-designed templates ensure quality.
