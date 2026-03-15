# M001: MVP Launch — Research

**Date:** 2026-03-15

## Summary

ThingCost enters a space where "cost per wear" exists in fashion (Vær, Acloset, Whering, Indyx) but **no app does general "cost per use" for all purchases**. The fashion apps are niche and complex — they bundle wardrobe management, outfit tracking, and sustainability metrics. Nobody has built the simple, universal version.

The viral mechanic is the real differentiator. "My iPhone costs me ₺3.8/day" is inherently shareable content. The app needs to make sharing frictionless and the cards visually stunning.

Key technical decisions: SwiftData for persistence (simple, modern), @Observable MVVM for architecture, StoreKit 2 for IAP, WidgetKit for home screen presence, and SwiftUI image rendering for share cards.

## Recommendation

Build the simplest possible version with maximum polish on two things: the daily cost display and the share card. Everything else is secondary. The share card IS the growth engine — invest design time there.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Persistence | SwiftData | Native, zero config, SwiftUI integration |
| In-app purchase | StoreKit 2 | Native, async/await, much simpler than StoreKit 1 |
| Widgets | WidgetKit | Only option for iOS widgets |
| Share | UIActivityViewController | Native share sheet, universal |
| Image rendering | ImageRenderer (iOS 16+) | SwiftUI native view-to-image |

## Competitive Landscape

| App | Focus | Weakness |
|-----|-------|----------|
| Vær | Cost per wear (fashion) | Fashion only, no general items |
| Acloset | Digital wardrobe + CPW | Bloated, complex |
| Whering | Outfit planning + CPW | Fashion only |
| Indyx | Wardrobe organizer | No cost per use focus |

**Gap:** No app does "cost per use" for phones, laptops, furniture, shoes, bikes — everything.

## Constraints

- iOS 17+ minimum (for @Observable, SwiftData, ImageRenderer)
- No backend needed for v1 (all local)
- StoreKit 2 requires iOS 15+ (we exceed this)
- Widget timeline refresh is system-managed (can't force frequent updates)

## Common Pitfalls

- **Share card quality** — Low-res or ugly cards won't get shared. Must be retina-quality, well-designed.
- **Onboarding friction** — If adding first item takes >30 seconds, users bounce. Pre-fill with example item.
- **Widget staleness** — WidgetKit timelines need thoughtful refresh. Daily cost changes slowly, so daily refresh is fine.
- **IAP edge cases** — Restore purchases, family sharing, sandbox testing. StoreKit 2 handles most but test thoroughly.

## Open Risks

- Share card virality is unproven — might not resonate as expected
- StoreKit 2 sandbox testing can be flaky
- Widget design needs to convey value in tiny space

## Sources

- Competitive research via App Store search (cost per wear, daily cost calculator)
- Apple developer docs for SwiftData, StoreKit 2, WidgetKit, ImageRenderer
