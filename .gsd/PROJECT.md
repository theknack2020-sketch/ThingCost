# Project

## What This Is

ThingCost — a premium iOS app that tracks the daily cost of things you own. Add an item (name, price, purchase date), and the app shows how the cost-per-day decreases over time. Designed for viral sharing: users generate beautiful cards showing "my iPhone costs me $3.8/day" and share them on Instagram/TikTok stories.

## Core Value

Show the real daily cost of any purchase and make it effortlessly shareable. If scope must shrink, the daily cost calculation + share card must survive.

## Current State

Quality update complete. All HARD STOP violations fixed. Premium polish applied across all views.

- **Bundle ID:** com.theknack.thingcost
- **Localization:** English only (TR removed)
- **Privacy:** PrivacyInfo.xcprivacy present
- **Monetization:** Freemium — 3 items free, unlimited via one-time IAP ($2.99)
- **Pro gates:** 8 feature gates matching comparison table 1:1
- **Build:** Clean, zero errors on iPhone + iPad

## Architecture / Key Patterns

- **Platform:** iOS 17+ (SwiftUI, @Observable, SwiftData)
- **Architecture:** MVVM with @Observable (medium complexity, good testability)
- **Persistence:** SwiftData (local, no cloud sync for v1)
- **Notifications:** Local notifications for daily reminders, streak alerts, cost milestones
- **Monetization:** Freemium — 3 items free, unlimited via one-time IAP ($2.99)
- **Sharing:** Custom rendered share cards (ImageRenderer)
- **Haptics:** HapticManager singleton wired to all views (39 refs)
- **Sound:** SoundManager with 5 system sounds + toggle
- **Streak:** StreakManager with daily tracking + longest streak
- **Achievements:** 8 achievements with celebration popup
- **Analytics:** TelemetryDeck (pending integration in ThingCostApp)

## Quality Metrics

| Metric | Count |
|--------|:-----:|
| Haptic calls | 39 |
| Accessibility labels | 62 |
| Shadows | 21 |
| Gradients | 20 |
| Spring animations | 26 |
| Error handling | 20 |
| isPro gates | 27 |
| Sound calls | 13 |
| Streak refs | 57 |
| Notification refs | 22 |
| Achievement refs | 45 |
| Total Swift files | 27 |
| Total lines | ~3,400 |

## Next Steps

- [ ] App icon generation (Gemini AI)
- [ ] ASO metadata preparation
- [ ] App Store screenshots
- [ ] TelemetryDeck app ID setup
- [ ] Simulator UI flow test (light + dark)
- [ ] iPad layout verification
- [ ] App Store submission
