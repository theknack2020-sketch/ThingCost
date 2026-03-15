---
status: complete
started: 2026-03-16
completed: 2026-03-16
---

# S04: Freemium IAP — Summary

## What Was Built

- **StoreService**: @Observable singleton with StoreKit 2 — product loading, purchase, restore, entitlement checking, transaction listener
- **PaywallView**: feature list, purchase button with loading state, restore button, error display, auto-dismiss on purchase
- **Freemium gate**: add-item button shows paywall when at 3 items (free limit), counter shows "2/3 free" in list header
- **StoreKit config**: Store.storekit file with non-consumable "Unlimited Items" at $2.99
- **Scheme wired**: storeKitConfiguration set in scheme for sandbox testing

## Key Decisions

- Singleton StoreService injected via @Environment from app root
- 3 free items before paywall — enough to understand value
- Non-consumable (one-time purchase), family shareable
- Auto-listen for transaction updates in background

## Verification

- Build: ✓
- Tests: 10/10 passing
- App launches, paywall gate functional
