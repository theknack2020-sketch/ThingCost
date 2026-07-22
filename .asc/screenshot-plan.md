# ThingCost — Screenshot Plan (v1.2.0)

patterns_read: 2026-07-22
sizes: iPhone 6.9" 1320×2868 (covers 6.7") · iPad 13" 2064×2752
pipeline: store-shots (steady-state, calibrated defaults inherited)

## Funnel logic (conversion mandate)

- **P1 hook:** the promo-text number, verbatim — "$1,000 phone = $2.74 a day" over the iPhone 15 Pro
  detail screen (365 days, $2.74/day live in UI). Brand promise in one number.
- **P2 moat:** Worth Score 0–100 — the signature feature no clone has. Item list with score badges
  on every row, dark violet panel so the numbers pop.
- **P3 depth:** dashboard (aggregate outcome state — totals, categories, worth overview).
- **P4:** share cards (social loop; "3 styles" mirrors metadata).
- **P5 Pro pre-sell as value** — use logging + cost-per-use + projections shown unlocked on the
  Espresso detail (85 "Amazing", $1.84/use). Never a price wall.

Five strong panels, no filler. No two panels share hero content (01: iPhone item, 04: Herman Miller
share card, 05: Espresso item; 02/03 are aggregate views). Background rotation
sky→violet→mist→deep→sky (no consecutive repeat, dark under the moat/value numbers).

## Caption A/B variants (for post-launch PPO)

| Panel | Shipped | Variant B |
|---|---|---|
| 01 | $1,000 phone = $2.74 a day | What does your stuff really cost? |
| 02 | Worth it? The score knows | Every purchase, scored 0–100 |
| 05 | Log uses. See real cost. | Your cost per wear, revealed |

## Capture notes

- Demo data: `--reset-data -demoData --skip-onboarding` per launch (reset wipes store+sidecars, then
  the fetchCount==0 guard reseeds the deterministic 8-item set — verified reseed, no stale-data no-op).
- en_US locale verified on both sims before capture; status bar 9:41 / discharging / full bars.
- **Isolation:** parallel sessions may share the iPhone sim → capture on a dedicated clone or confirm
  no other app is foregrounded; verify each raw with Read (breadcrumb / wrong-app check) before compose.
- **iPad: 3 panels only** (01-hero, 03-dashboard, 05-pro) — all full-screen detail/dashboard views.
  `list` (02) and `share` (04) are dropped on iPad: NavigationSplitView leaves a big empty
  "Select an item" pane, and the share card floats mid-screen with dead space below — both read
  weak at iPad scale. Compose iPad with `--device ipad --panels 01-hero,03-dashboard,05-pro`.
- **iPad locale trap:** host machine is tr_TR → fresh sims inherit it (currency shows ₺, dates TR).
  Fix: on the BOOTED clone `simctl spawn <ud> defaults write -g AppleLocale en_US` +
  `AppleLanguages -array en` → shutdown → boot; also pass `-AppleLocale en_US -AppleLanguages "(en)"`
  as launch args (belt-and-braces). iPad `simctl launch` never returns (attach hang) but the app
  DOES open → fire-and-forget launch, wait ~14s, then `simctl io screenshot`.
