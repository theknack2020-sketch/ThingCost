# App Store Review Notes — ThingCost

Bu metni App Store Connect > App Review Information > Notes alanına yapıştırın.

---

## Review Notes (paste this into App Store Connect)

### 1. App Functionality Summary

ThingCost launches directly to a 3-page onboarding flow (swipe or tap "Next"). After onboarding, the user lands on the main item list. Tapping the "+" button opens the Add Item form. Core flow: Add → View daily cost → Tap item for detail (chart, milestones) → Share card → Edit/Delete via swipe.

The app has no account system, no login, no user-generated content, no camera/microphone/location access, and no prompts requesting sensitive data.

Purchase flow: Free users can track up to 3 items. When attempting to add a 4th item, a paywall screen appears offering a one-time $2.99 Non-Consumable purchase ("Unlimited Items") via StoreKit 2. Users can also access "Restore Purchases" from the paywall or from Settings.

### 2. App Purpose & Value

ThingCost helps users understand the true daily cost of their purchases. Users enter an item name, price, and purchase date — the app calculates and displays the daily cost (price ÷ days owned), which decreases every day. This helps users make more mindful purchasing decisions by visualizing how cost amortizes over time.

Key features:
- Daily/monthly/yearly cost breakdown
- Interactive cost-over-time chart
- Future cost projections (1 month, 3 months, 1 year, etc.)
- Shareable cost cards in 3 visual styles (Minimal, Bold, Gradient)
- Sorting by daily cost, price, date, or name
- Light/Dark/System theme support
- English and Turkish localization

### 3. Instructions for Reviewing

- Launch the app → Complete the 3-page onboarding (tap "Next" twice, then "Add Sample & Start" or "Skip")
- On the main screen, tap "+" to add items (name, price, purchase date, category)
- Tap any item to see the detail view with cost breakdown, chart, and projections
- Tap the share icon on detail view to see share card styles
- Swipe left on an item to delete, swipe right to edit
- After adding 3 items, tap "+" to see the paywall
- Tap the gear icon (⚙️) for Settings → Theme, Restore Purchases, Privacy Policy, Terms of Use, Contact

No login or test credentials are required — the app has no account system.

### 4. External Services & Tools

ThingCost does NOT use any external services, APIs, SDKs, or third-party libraries. It is built entirely with:
- SwiftUI (UI framework by Apple)
- SwiftData (local on-device persistence by Apple)
- StoreKit 2 (in-app purchase by Apple)
- Swift Charts (charting by Apple)

All data is stored locally on the user's device. No data is transmitted to any server.

### 5. Regional Differences

The app functions consistently across all regions. There are no regional restrictions, geo-locked features, or region-specific content. The app is localized in English and Turkish, but all features are identical regardless of language or region.

### 6. Regulated Industry

Not applicable. ThingCost is a personal finance utility/calculator and does not operate in a regulated industry. It does not provide financial advice, process payments, or handle sensitive financial data beyond user-entered purchase prices stored locally on-device.

---

## Checklist Before Resubmission

- [x] Privacy Policy URL added to Settings
- [x] Terms of Use URL added to Settings
- [x] Contact/Support email added to Settings
- [x] Restore Purchases accessible from Settings
- [x] No account system (no login/registration needed)
- [x] No sensitive permissions requested
- [x] All features work on physical device (tested on simulator, all UI tests pass)
- [x] 32/32 unit tests pass
- [x] Full UI flow test passes (onboarding → add → detail → share → edit → delete → paywall → settings)
