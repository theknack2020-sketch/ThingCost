# S01: Share Card Quality & Visual Verification

**Goal:** Verify all 3 share card styles render beautifully with real item data, fix any visual issues found.
**Demo:** Screenshots of all 3 share card styles with a real item, visually inspected and approved.

## Must-Haves

- All 3 styles (Minimal, Bold, Gradient) render without clipping or layout issues
- Currency and day labels display correctly in both EN/TR
- Share card preview screen works (style picker, share button)
- ImageRenderer produces high-quality retina images
- All detail view sections render correctly (header, breakdown, chart, milestones)

## Verification

- Build app, navigate to detail view, take screenshots
- Open share card preview, capture all 3 styles
- Visual inspection of each screenshot for layout/text issues
- Fix any bugs found, rebuild and re-verify

## Tasks

- [ ] **T01: Screenshot all detail view sections** `est:20m`
  - Why: Detail view has 4 cards (header, breakdown, chart, projections) that haven't been visually verified
  - Files: `Sources/Views/Screens/ItemDetailView.swift`
  - Do: Launch app with sample data, navigate to item detail, take full-page screenshots in light and dark mode
  - Verify: Visual inspection of each section
  - Done when: All 4 cards render correctly, no clipping or overflow

- [ ] **T02: Screenshot all 3 share card styles** `est:30m`
  - Why: Share cards are the viral mechanism — they must look great
  - Files: `Sources/Views/Components/ShareCardView.swift`, `Sources/Views/Screens/ShareCardPreviewView.swift`
  - Do: Open share card preview for a real item, switch between Minimal/Bold/Gradient, screenshot each. Check text fits, currency correct, watermark visible
  - Verify: Visual inspection of each card style
  - Done when: All 3 styles render beautifully, text readable, no overflow

- [ ] **T03: Fix any visual bugs found** `est:30m`
  - Why: Bugs found in T01/T02 must be fixed
  - Files: Various view files
  - Do: Fix layout issues, text overflow, color problems. Rebuild and re-screenshot
  - Verify: Re-screenshot after fixes, visual confirmation
  - Done when: All screenshots look ship-ready

## Files Likely Touched

- `Sources/Views/Screens/ItemDetailView.swift`
- `Sources/Views/Components/ShareCardView.swift`
- `Sources/Views/Screens/ShareCardPreviewView.swift`
