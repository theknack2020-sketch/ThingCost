# ThingCost — Screenshot Plan (v1.2.0)

patterns_read: 2026-07-22
sizes: iPhone 6.9" 1320×2868 (covers 6.7") · iPad 13" 2064×2752
pipeline: store-shots (steady-state, calibrated defaults inherited)

## Funnel logic (conversion mandate)

- **P1 hook:** the promo-text number, verbatim — "$1,000 phone = $2.74 a day" over the iPhone 15 Pro
  detail screen (365 days, $2.74/day live in UI). Brand promise in one number.
- **P2 moat:** Worth Score 0–100 — the signature feature no clone has. Item list with score badges
  on every row, dark violet panel so the numbers pop.
- **P3 depth (NEW):** the home-screen widget — v1.2.0's headline feature and a retention promise
  ("your daily cost without opening the app"). Reinforces the `widget` keyword.
- P4: dashboard (aggregate outcome state — totals, categories).
- P5: share cards (social loop; "3 styles" mirrors metadata).
- P6: **Pro pre-sell as value** — use logging + cost-per-use + projections shown unlocked on the
  Espresso detail (85 "Amazing", $1.84/use). Never a price wall.

No two panels share hero content (01: iPhone item, 05: Herman Miller share card, 06: Espresso item;
02/04 are aggregate views). Background rotation sky→violet→mist→deep→sky→violet (no consecutive repeat,
dark under the moat/value numbers).

## Caption A/B variants (for post-launch PPO)

| Panel | Shipped | Variant B |
|---|---|---|
| 01 | $1,000 phone = $2.74 a day | What does your stuff really cost? |
| 02 | Worth it? The score knows | Every purchase, scored 0–100 |
| 03 | Your daily cost, always visible | Glance. Know. Move on. |
| 06 | Log uses. See real cost. | Your cost per wear, revealed |

## Capture notes

- Demo data: `-demoData --reset-data --skip-onboarding` per launch (deterministic 8-item seed;
  reset first so the fetchCount==0 guard always reseeds — avoids the Cadora stale-seed trap without
  uninstalling, which would remove the placed widget).
- Widget panel: capture home screen AFTER a final app launch + background (scenePhase hook reloads
  the timeline), status bar overridden.
- en_US locale verified on both sims before capture; status bar 9:41 / discharging / full bars.
- iPad: same 6 panels; App Group first-launch cost → settle +8s on iPad (PATTERNS lesson).
