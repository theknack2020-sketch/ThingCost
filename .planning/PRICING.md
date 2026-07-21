# ThingCost — Pricing Decision

**Date:** 2026-07-21 · **Session:** v1.2.0 refresh · **Decider:** agent (owner standing authorization: `monetization-pricing-autonomy`)

## Current state (evidence)

- Product: **ThingCost Unlimited** `com.ufukozdemir.thingcost.unlimited.v2` (ASC IAP 6760629485) — NON_CONSUMABLE, **$2.99**, APPROVED. (ASC `familySharable: false`; local Store.storekit wrongly said true — synced.)
- Sales: **4 net sales ≈ $8.80 proceeds** (PL / HK / GB / CN — global spread, no US sale yet).
- Downloads: Apr 4 · May 17 · Jun 5 · Jul (2 wk) 3 ≈ **29 total** → paid conversion ≈ **13.8%**, far above the 2–5% freemium norm. Price is not the bottleneck; discovery is.
- Rating: 0 (no reviews yet).

## Competitor scan (live, 2026-07-21, `asc apps public search` + App Store pages via Claude Browser)

| App | Traction | Model |
|---|---|---|
| Daily Penny — Show daily cost | 4.9★ / 17 | Free + IAP unlock (small utility, iCloud backup) |
| iAsset: Cost Per Use Tracker | 4.4★ / 63 | Free + **subscription** (trial + auto-renew; AI scanner, resale ROI) |
| Use It Long — Cost per day | 5★ / 1 | Free + IAP |
| Cently / CostKeeper / WasteLess / Worth It / OneDay | 0 ratings each | Free + IAP (spam-wave clones, no traction) |
| Daily Budget Original (adjacent) | 4.7★ / 4.8K | Free + Pro subscription ($) |
| Money Manager (adjacent) | 4.8★ / 18.6K | Free + $ unlock |

Read: the direct cost-per-day niche is still wide open — nobody with >100 ratings. The only monetization
anchor with traction (iAsset) is a **subscription**, which ThingCost's "pay once, keep forever" positioning
deliberately counters. No credible lifetime-unlock anchor sits below us.

## Decision: raise lifetime unlock $2.99 → **$4.99** (USD tier; other territories via Apple equalization)

Rationale:
1. **13.8% paid conversion at $2.99** signals underpricing — buyers are value-driven, not price-driven.
2. v1.2.0 adds a **real home-screen widget**, and the Pro bundle already carries photos, use logging,
   3 share styles, themes, charts, CSV, unlimited projections, custom categories, multi-currency.
3. Anti-subscription wedge tolerates a higher one-time price (vs iAsset's recurring cost, $4.99 once is
   still cheap).
4. Portfolio consistency: NoBuy $4.99 lifetime; dB Meter Lifetime $39.99. $2.99 was the portfolio floor.
5. Sales volume is tiny (4 lifetime) → experiment risk ≈ zero; revenue upside +67%/sale.

No product-structure change: same non-consumable, no new SKU, price schedule update only (no review needed).

**APPLIED 2026-07-22:** `asc iap pricing schedules create --base-territory USA` → price point 10062 ($4.99),
verified via `asc iap pricing summary` (currentPrice 4.99 USD, proceeds 3.50). Local `Store.storekit`
synced to 4.99 + familyShareable=false (matching ASC).

## Follow-ups

- Re-check within 90 days (next refresh) — if conversion holds ≥8% at $4.99, test $6.99.
- If subscriptions ever get added, route through TheKnackKit `PaywallKit` (RevenueCat law) — not planned;
  one-time model is a positioning pillar here.
