# ThingCost — Kapsamlı Audit Raporu

**Tarih:** 7 Nisan 2026
**Versiyon:** 1.0.0 (Build 5)
**Bundle:** com.ufukozdemir.thingcost
**Platform:** iOS 17+, SwiftUI, SwiftData, Swift 6.0
**Dosya Sayısı:** 31 Swift | **Satır:** ~6,000

---

## RAKİP ANALİZİ (GERÇEK App Store Verisi — `asc apps public search`)

### Doğrudan Rakipler (cost-per-day / cost-per-use niche)

| App | Fiyat | Rating | Review # | Model | Öne Çıkan |
|-----|-------|--------|----------|-------|-----------|
| **Cently: Daily Cost Tracker** | Free | — | 0 | Yeni | Doğrudan rakip, henüz rating yok |
| **Use It Long - Cost per day** | Free | ★5.0 | 1 | ? | En yakın konsept, neredeyse sıfır kullanıcı |
| **Daily Penny - Show daily cost** | Free | ★4.9 | 17 | ? | Küçük ama sadık kitle |
| **Coday – Daily & Per-Use Cost** | Free | ★5.0 | 2 | ? | Yeni, çok az review |
| **Skip or Buy: Cost Per Use** | Free | — | 0 | ? | Yeni, sıfır traction |

### Dolaylı Rakipler (finance/expense trackers)

| App | Fiyat | Rating | Review # |
|-----|-------|--------|----------|
| Money Manager Expense & Budget | Free | ★4.8 | 17,572 |
| Budget App - Spending Tracker | Free | ★4.7 | 14,065 |
| Daily Budget Original | Free | ★4.7 | 4,841 |
| Weple Money | Free | ★4.9 | 3,559 |
| Tally: The Anything Tracker | Free | ★4.4 | 4,026 |

### Rekabet Değerlendirmesi

**FIRSATLAR:**
- Doğrudan "cost per day" niche'i BOŞLUK — hiçbir rakipte 100+ review yok
- ThingCost'un "Worth It Score" + share card + streak = rakiplerde YOK
- En büyük rakip Cently ve Daily Penny — ikisi de minimal feature set

**RİSKLER:**
- Niche çok küçük olabilir — "cost per day" arama hacmi düşük
- Genel finance tracker'lar (Money Manager, Budget App) çok güçlü
- Keşfedilebilirlik (discoverability) ana darboğaz

---

## QG 12 SORU SONUÇLARI

### Q1: Logo & Brand Uyumu ✅ (World-class DEĞİL)

**Mevcut:** App icon var (light + dark + tinted variants). Tag icon konsepti.
**Sorun:** Icon Gemini AI ile oluşturulmuş mu kontrol edilmeli. CoreGraphics icon yasak (CLAUDE.md kuralı).
**World-class için:** Icon güçlü ama marka tutarlılığı (icon → app UI → screenshots → metadata) kontrol edilmeli.

### Q2: Her Ekran Premium mi? ✅ (Güçlü, birkaç detay eksik)

**Metrikler:**
| Öğe | Sayı | Yeterli mi |
|-----|------|-----------|
| Haptic calls | 41 | ✅ Bolca |
| Shadows | 42 | ✅ Her card'da |
| Gradients (Linear+Radial) | 36 | ✅ Zengin |
| Spring animations | 63 | ✅ Mükemmel |
| Sound effects | 6 | ✅ Yeterli |
| Tabular numbers (.monospacedDigit) | 8 | ✅ Kullanılıyor |
| Scale on press | 2 | ⚠️ Sadece OnboardingButton'da |
| Reduce Motion desteği | 29 ref | ✅ OnboardingView'da güçlü |
| Symbol effects | 4 | ⚠️ Az (pulse warranty'de, bounce bell'de) |

**Eksikler:**
- 🟡 `Scale on press` sadece OnboardingButton'da → PaywallView CTA'sına ve diğer major butonlara eklenmeli
- 🟡 `symbolEffect` sadece 4 yerde → daha fazla yerde kullanılabilir (list item appear, tab switch)
- 🟡 Hardcoded font sizes: 38 yerde `.font(.system(size:))` kullanılıyor — bunlar çoğunlukla display/hero text için (kabul edilebilir) ama Dynamic Type'ı kırıyor
- 🟡 `easeIn`/`easeOut` animasyonlar: AchievementPopup ve confetti'de → spring'e çevrilmeli
- 🟢 Genel UI kalitesi premium seviyede

### Q3: Free vs Pro Belirgin mi? ✅ (World-class)

**Comparison table:** 11 satır (kural: 8+ ✅)
**Her satır açık:** Free value + Pro value net görünüyor
**Paywall fullscreen:** ✅ (az önce düzeltildi)
**Savings badge:** One-time purchase → savings badge yok (subscription olmadığı için normal)

### Q4: Pro Vaat = Gate Bütünlüğü ✅ (Sağlam)

**Gate kontrol raporu:**

| Paywall Satırı | Gate | Dosya | Durum |
|----------------|------|-------|-------|
| Items (5 max → Unlimited) | `canAddItem(currentCount:)` | StoreService | ✅ |
| Photos (— → ✓) | `canAttachPhoto` | StoreService | ✅ |
| Usage Logging (View → Log) | `canLogUses` | StoreService | ✅ |
| Share Styles (1 → All 3) | `isShareStyleAvailable(_:)` | StoreService | ✅ |
| Themes (2 → All) | `isThemeAvailable(_:)` | StoreService | ✅ |
| Charts (Basic → All) | `canAccessAdvancedCharts` | StoreService | ✅ |
| CSV Export (— → ✓) | `canExportCSV` | StoreService | ✅ |
| Projections (6mo → ∞) | `isMilestoneAvailable(days:)` | StoreService | ✅ |
| Categories (Standard → +Custom) | `canUseCustomCategories` | StoreService | ✅ |
| Widget (Basic → All sizes) | — | ⚠️ Widget'ta gate kodu yok |
| Priority Support (— → ✓) | — | ℹ️ Soft promise, kod gate yok (normal) |

**⚠️ Widget gate eksik:** PaywallView'da "Widget: Basic → All sizes" yazıyor ama ThingCostWidget.swift'te isPro kontrolü yok. Widget extension ayrı target — StoreService'e erişimi App Group üzerinden olmalı. Şu an tüm widget'lar herkese açık.

### Q5: Rakiplerden İyi miyiz? ⚠️ (Analiz gerekli)

**Moat'lar (rakipte YOK, bizde VAR):**
1. ✅ **Worth It Score** — 0-100 puan, faktörlü hesaplama
2. ✅ **Share Cards** — 3 stil, Instagram/TikTok optimized
3. ✅ **Streak + Achievements** — 8 achievement, celebration popup
4. ✅ **Warranty tracking** — rakiplerin hiçbirinde yok
5. ✅ **Receipt storage** — item'a fiş ekleme

**Gap'ler (rakiplerde VAR, bizde YOK veya ZAYıF):**
1. ❌ **iCloud Sync** — yok. Cihaz değişiminde veri kaybolur
2. ❌ **Multi-currency desteği** — gate var ama implementation kontrol edilmeli
3. ⚠️ **Depreciation models** — sadece linear. Hızlı depreciation (elektronik) vs yavaş (mobilya) modeli yok

### Q6: Beğenir/Kullanır/Öder mi? ✅ (Güçlü)

**Onboarding:** 4 sayfa, skip'lenebilir, confetti, MeshGradient background ✅
**D1-3 hooks:**
- Streak (günlük kullanım teşviki) ✅
- Notifications (reminder + streak alert) ✅
- Achievement popup (positive reinforcement) ✅
- Soft paywall trigger (5. item sonrası, 24h cooldown) ✅

**⚠️ Wow moment:** Onboarding'de sample item eklenmiyor — user "Add Your First Item" deyince direkt AddItemView'a gidiyor. İlk value moment user'ın item eklemesine bağlı → friction.

### Q7: Retention Kaliteli mi? ✅ (İyi)

| Element | Ref Count | Durum |
|---------|-----------|-------|
| Streak (StreakManager) | 57+ | ✅ Güçlü |
| Notifications | 22+ | ✅ Reminder + streak |
| Achievements | 45+ | ✅ 8 achievement |
| Review prompt | Mevcut | ✅ Smart trigger |
| TipKit | 3 tip | ✅ |

### Q8: Crash-Free & Stable? ⚠️ (Dikkat gereken noktalar)

**Pozitif:**
- Force unwrap: 0 ✅
- Empty catch: 0 ✅
- Error handling: Mevcut ✅

**Dikkat:**
- 🟡 `try?` 15 yerde — çoğu `Task.sleep` (kabul edilebilir) ama StoreService'te transaction verification'da kullanılıyor (satır 161, 175) → silent fail riski
- 🟡 `print()` 1 yerde (StoreService:102) → Logger'a dönüştürülmeli
- 🟡 TelemetryDeck app ID = `"YOUR_TELEMETRYDECK_APP_ID"` **PLACEHOLDER** → crash olmaz ama analytics ÇALIŞMIYOR

### Q9: Dark Mode + Accessibility ⚠️ (Önemli eksikler)

**Dark Mode:**
- Semantic colors kullanılıyor (`.primary`, `.secondary`, `Color(.systemBackground)`) ✅
- `.ultraThinMaterial` yaygın ✅
- Custom color set: Sadece `AccentColor` — başka custom color YOK ✅ (system colors yeterli)

**Accessibility — KRİTİK EKSİKLER:**
- 🔴 **Dynamic Type:** `dynamicTypeSize` / `@ScaledMetric` / `relativeTo` = **0 kullanım**. 38 yerde hardcoded `.system(size:)` var. Büyük fontlarda layout kırılacak.
- 🟡 **Reduce Motion:** 29 ref ama SADECE OnboardingView'da. DashboardView, ItemDetailView, PaywallView'daki animasyonlar reduceMotion'ı IGNORE ediyor.
- 🟡 `accessibilityLabel`: 53 adet — iyi ama eksikler var (bazı icon-only butonlarda)
- 🟡 `accessibilityIdentifier`: 9 adet — test için minimal ama yeterli

### Q10: iPad + Küçük Ekran ✅ (İyi)

**iPad:**
- `NavigationSplitView` iPad'de ✅
- `horizontalSizeClass` kontrolü ✅
- PaywallView fullscreen ✅

**Küçük Ekran (SE):**
- `minimumScaleFactor` birkaç yerde ✅
- Hardcoded frame width yok ✅
- `maxWidth: .infinity` kullanılıyor ✅

### Q11: Offline + Error Handling ✅ (Temel seviyede)

- SwiftData = local → offline çalışır ✅
- Save error handling mevcut ✅
- StoreKit purchase error handling mevcut ✅
- Network yok (API çağrısı yok) → offline sorun yok ✅

### Q12: Privacy + Metadata + IAP ⚠️ (Birkaç sorun)

| Kontrol | Durum |
|---------|-------|
| PrivacyInfo.xcprivacy | ✅ Mevcut, doğru |
| Privacy Policy URL | ✅ 200 OK |
| Terms of Use URL | ✅ 200 OK |
| Support URL | ✅ 200 OK |
| Copyright | ✅ `© 2026 TheKnack` |
| ITSAppUsesNonExemptEncryption | ✅ false |
| knownRegions | ✅ en + Base |
| StoreKit config | ✅ Mevcut |
| Restore purchase | ✅ PaywallView + Settings |
| Terms/Privacy links | ✅ Paywall footer |
| Build artifact: tr.lproj | ⚠️ Eski build'de TR locale var — clean build gerekli |

---

## DOSYA BAZLI DETAYLI BULGULAR

### 🔴 KRİTİK (Hemen düzeltilmeli)

| # | Bulgu | Dosya | Detay |
|---|-------|-------|-------|
| C1 | **TelemetryDeck APP_ID placeholder** | Analytics.swift:98 | `"YOUR_TELEMETRYDECK_APP_ID"` — analytics hiç çalışmıyor. Env var da boş olabilir. |
| C2 | **Widget isPro gate yok** | ThingCostWidget.swift | Paywall'da "Widget: Basic → All sizes" vaadi var ama widget'ta sıfır gate. Tüm kullanıcılar tüm widget'lara erişiyor = Q4 ihlali. |
| C3 | **Dynamic Type desteği yok** | Proje geneli | 38 yerde `.system(size:)` + 0 `@ScaledMetric` + 0 `relativeTo` = a11y accessibility sizes'da kırılacak. Apple rejection riski. |
| C4 | **Bundle ID: project.yml `com.ufukozdemir`** | project.yml:33 | CLAUDE.md'de copyright TheKnack ama bundle `com.ufukozdemir`. ASC'de zaten kayıtlıysa değiştirilemez — tutarsızlığı belgele. |

### 🟡 ORTA (Submit öncesi düzeltilmeli)

| # | Bulgu | Dosya | Detay |
|---|-------|-------|-------|
| M1 | **Reduce Motion: Ana ekranlarda yok** | Dashboard, ItemDetail, Paywall | OnboardingView'da 29 ref var ama diğer view'lar `reduceMotion`'ı hiç kontrol etmiyor. |
| M2 | **print() statement** | StoreService.swift:102 | `print("[StoreService]...")` → `Logger` kullanılmalı. |
| M3 | **try? transaction verification** | StoreService.swift:161,175 | Transaction verify fail sessizce atlanıyor. Tampered transaction tespiti zorlaşır. |
| M4 | **Scale-on-press eksik** | PaywallView CTA, ItemList add button | Sadece OnboardingButton'da var. Major CTA'lara eklenmeli. |
| M5 | **Build artifact: tr.lproj** | build/ folder | Eski build'de TR locale artifact var. `build/` clean edilmeli. |
| M6 | **easeIn/easeOut animasyonlar** | AchievementPopup.swift:27,94 | Spring yerine easeIn/easeOut kullanılıyor. Kural: spring DEFAULT. |
| M7 | **Paywall item limit tutarsızlığı** | PaywallView vs StoreService | Paywall'da "5 max" yazıyor, StoreService'te `freeItemLimit = 5`. Tutarlı ✅ ama PROJECT.md'de "3 items free" yazıyor ❌ — PROJECT.md güncellenecek. |
| M8 | **App icon Gemini AI oluşturulmuş mu?** | AppIcon.appiconset | CLAUDE.md: "Icon: Gemini AI-generated ZORUNLU" — doğrulanmalı. |

### 🟢 DÜŞÜK (Kalite artırıcı, sonra yapılabilir)

| # | Bulgu | Dosya | Detay |
|---|-------|-------|-------|
| L1 | **symbolEffect az kullanım** | Proje geneli | Sadece 4 yerde. Tab switch, list appear, save success gibi yerlerde eklenebilir. |
| L2 | **Custom color set yok** | Assets.xcassets | Sadece AccentColor var. Sistem renkleri kullanılıyor (iyi) ama marka tutarlılığı için `AppPrimary` tanımlanabilir. |
| L3 | **ContentUnavailableView sadece 2 yerde** | Dashboard + ItemList | Diğer boş state'ler (settings achievements = 0, share card preview) için de eklenebilir. |
| L4 | **Achievement "cheapestDay" trigger yok** | AchievementManager | `checkAndUnlock()` fonksiyonunda `cheapestDay` koşulu kontrol edilmiyor. Achievement tanımlı ama hiç unlock OLMUYOR. |
| L5 | **remainingFreeItems hesabı hatalı** | StoreService.swift:48 | `max(freeItemLimit - 0, 0)` → hardcoded 0. Bu property her zaman 5 döner. Kullanılmıyorsa silinmeli, kullanılıyorsa düzeltilmeli. |
| L6 | **onboarding_sample_desc kullanılmıyor** | Localizable.strings | Tanımlı ama hiçbir view'da referans edilmiyor → dead string. |
| L7 | **PaywallTrigger softPaywall kullanılmıyor (tam)** | AddItemView | `showingSoftPaywall` state var ama hiç okunmuyor. Trigger NotificationCenter üzerinden çalışıyor. Dead state. |

---

## FİYATLANDIRMA ANALİZİ

| | Mevcut | Değerlendirme |
|---|---|---|
| **Model** | One-time $2.99 (Non-Consumable) | ✅ Utility app için doğru |
| **Free tier** | 5 item + basic charts + 1 share style + 2 theme + 6mo projections | ✅ Cömert |
| **Pro tier** | 10 feature gate | ✅ Derin |
| **Rakip fiyat** | Rakipler genelde Free+ads veya subscription | ✅ One-time = avantaj |
| **Family Sharing** | ✅ Enabled | ✅ |
| **PPP** | Henüz ayarlanmamış | 🟡 Submit sonrası yapılmalı |

**TAVSİYE:** Fiyatlandırma modeli doğru. $2.99 bu niche için uygun. Değişiklik önerilmez.

---

## SCREENSHOT PLANI

### iPhone (6.7" — 1290x2796)

| # | Ekran | Caption (ASO optimized) | Vurgu |
|---|-------|-------------------------|-------|
| 1 | Item List (5+ item, gradient total card görünür) | **See What Everything Really Costs** | Daily cost in large font, total card gradient |
| 2 | Item Detail (iPhone örneği, worth ring, chart) | **Worth It? Your Score Says It All** | Worth Score ring (80+), cost curve chart |
| 3 | Share Card Preview (gradient style) | **Share Your Daily Cost on Social** | Gradient share card, Instagram-ready |
| 4 | Dashboard (tüm card'lar, kategori chart) | **Your Spending Dashboard at a Glance** | Category breakdown, hero card, warranty alert |
| 5 | Paywall (fullscreen, comparison table) | **One Purchase. Every Feature. Forever.** | Comparison table, $2.99 prominent |

### iPhone (6.9" — 1320x2868)
Aynı ekranlar, aynı caption'lar — farklı boyut.

### iPad (13" — 2064x2752)

| # | Ekran | Caption | Vurgu |
|---|-------|---------|-------|
| 1 | Item List (split view, detail pane) | **Track Everything on iPad** | Two-column split view |
| 2 | Dashboard (geniş layout) | **Full Dashboard. Full Picture.** | Tüm card'lar geniş ekranda |
| 3 | Item Detail (chart + milestones) | **Deep Cost Insights** | Chart + worth score geniş |

### Caption Stratejisi
- Her caption FAYDA odaklı (feature değil)
- İlk screenshot en önemli — "See What Everything Really Costs" → curiosity trigger
- Son screenshot paywall — "One Purchase. No Subscription" → objection handling
- Keywords: "daily cost", "worth", "share", "dashboard", "one purchase"

### Screenshot Notları
- ⛔ QG 12/12 ✅ tamamlanmadan screenshot ALINMAYACAK
- Light mode default
- Gerçek verili (sample data): iPhone 15 Pro $999, MacBook $1499, Nike $150, IKEA desk $299, watch $450
- Her screenshot'ta ≥3 item görünmeli (app dolu hissetmeli)

---

## ÖNCELİK SIRASI — NE YAPILACAK

### Faz 1: Kritik (Submit blocker)
1. **C1:** TelemetryDeck app ID ayarla (env var veya hardcode)
2. **C3:** Dynamic Type — en azından hero/display fontlarda `relativeTo:` ekle
3. **C2:** Widget gate → App Group + isPro kontrolü veya paywall satırını "Widget: Basic → All sizes" kaldır

### Faz 2: Orta (Kalite + rejection riski)
4. **M1:** reduceMotion desteğini Dashboard, ItemDetail, PaywallView'a ekle
5. **M2:** print → Logger
6. **M4:** Scale-on-press → PaywallView CTA, add button
7. **M6:** easeIn/easeOut → spring (AchievementPopup)
8. **M7:** PROJECT.md "3 items free" → "5 items free" düzelt
9. **L4:** cheapestDay achievement trigger ekle
10. **L5:** remainingFreeItems bug düzelt

### Faz 3: Polish (World-class)
11. **L1:** symbolEffect daha fazla yere ekle
12. **L6-L7:** Dead code/strings temizle
13. **M8:** App icon Gemini AI doğrulaması
14. **Screenshot** alma (QG sonrası)
15. **PPP fiyatlandırma** (submit sonrası)

---

## ÖNEMLİ NOTLAR

- **Build durumu:** ✅ Build Succeeded (iPhone 17 Pro Max simulator)
- **Git durumu:** 6 dosya modified (sheet→fullScreenCover dönüşümü)
- **Privacy/Legal:** Tüm URL'ler 200 OK ✅
- **Rakip durumu:** Niche BOŞLUK — doğrudan rakipler çok zayıf, fırsat büyük
- **App Store'da kayıtlı:** Evet (appId: 6739488576)
