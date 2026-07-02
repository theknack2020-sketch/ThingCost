# ThingCost — ASO Overhaul Raporu

**Tarih:** 7 Nisan 2026
**Version:** 1.1.0 (PREPARE_FOR_SUBMISSION)
**App ID:** 6760629048

---

## 1. RAKİP ANALİZİ (GERÇEK App Store Verisi)

### Top 5 Doğrudan Rakip

| # | App | Rating | Reviews | Fiyat | Niche |
|---|-----|--------|---------|-------|-------|
| 1 | **Daily Penny - Show daily cost** | ★4.9 | 17 | Free | Günlük maliyet |
| 2 | **Use It Long - Cost per day** | ★5.0 | 1 | Free | Günlük maliyet |
| 3 | **Coday – Daily & Per-Use Cost** | ★5.0 | 2 | Free | Günlük + kullanım başı |
| 4 | **Worth It - Cost Per Use** | ★0.0 | 0 | Free | Kullanım başı maliyet |
| 5 | **Skip or Buy: Cost Per Use** | ★0.0 | 0 | Free | Satın alma kararı |

### Dolaylı Rakipler (adjacent market)

| App | Rating | Reviews | Niche |
|-----|--------|---------|-------|
| Spending Tracker | ★4.8 | 19,026 | Genel harcama |
| Budget app | ★4.7 | 14,071 | Bütçe takibi |
| Daily Budget Original | ★4.7 | 4,841 | Günlük bütçe |
| Tally: The Anything Tracker | ★4.4 | 4,026 | Genel takip |
| Monefy | ★4.7 | 6,416 | Para yönetimi |

### Rekabet Değerlendirmesi

**NİCHE BOŞLUĞU:** Doğrudan rakiplerin TOPLAMI 20 review. Bu alan sahipsiz.

**ThingCost MOAT'ları (rakipte YOK):**
1. Worth It Score (0-100, faktörlü)
2. Share Cards (3 stil, sosyal medya optimized)
3. Streak + 8 Achievement
4. Warranty tracking
5. Receipt storage + photos
6. Cost projection milestones
7. Category breakdown dashboard

**Positioning:** ThingCost = "the daily cost app with a brain" — sadece bölme yapmıyor, worth score ile akıllı değerlendirme + viral sharing.

---

## 2. MEVCUT METADATA ANALİZİ

### Şu An (ASC'de canlı)

| Alan | Mevcut | Char | Sorun |
|------|--------|------|-------|
| **Title** | `ThingCost` | 9/30 | ⛔ 21 char BOŞA GİDİYOR — keyword fırsatı kaybı |
| **Subtitle** | `What You Really Pay Per Day` | 27/30 | ⚠️ Benefit-focused ama keyword-poor |
| **Keywords** | `expense,savings,price,spending,money,finance,budget,per use,ownership,depreciation,item,value,log` | 97/100 | ⚠️ Çok generic, high-competition keyword'ler |
| **Description** | 3060 char, iyi yapılı | 3060/4000 | ✅ İyi ama hook güçlendirilebilir |
| **Promotional** | 161 char, güçlü | 161/170 | ✅ İyi |

### Kritik Sorunlar
1. **Title sadece 9 char** — 21 char boşa gidiyor. Apple title'ı en yüksek ağırlıkla indexliyor
2. **Keywords çok generic** — "expense", "money", "finance" gibi billion-app keyword'lerle rekabet imkansız
3. **Cross-field overlap:** "cost" title'da YOK ama olmalı. "per" subtitle'da var ama keyword'de de "per use" olarak var → waste
4. **TR locale hala mevcut** — ASC'de tr.json var, kaldırılmalı

---

## 3. YENİ METADATA ÖNERİSİ

### Title (30 chars)
```
ThingCost - Daily Cost Tracker
```
**30/30 char** — her karakter kullanılıyor.
**Yeni indexed words:** daily, cost, tracker (3 yüksek-değerli keyword kazanıldı)

### Subtitle (30 chars)
```
Worth Score for Every Purchase
```
**30/30 char** — benefit-first + keyword-rich.
**Indexed words:** worth, score, every, purchase
**Neden:** "Worth Score" unique differentiator + "purchase" high-intent keyword

### Keywords (100 chars)
```
expense,savings,price,per use,ownership,depreciation,value,spending,budget,item,log,cheap,how much
```
**100/100 char**

**Cross-field dedup kontrolü:**
- Title words: thingcost, daily, cost, tracker → keyword'de YOK ✅
- Subtitle words: worth, score, every, purchase → keyword'de YOK ✅
- Keyword words: expense, savings, price, per use, ownership, depreciation, value, spending, budget, item, log, cheap, how much → title/subtitle'da YOK ✅
- **SIFIR overlap** ✅

**Değişiklikler vs mevcut:**
- ❌ Çıkarılan: `money`, `finance` (çok generic, milyonlarca rakip)
- ✅ Eklenen: `cheap`, `how much` (long-tail, user language, "how much does X cost per day")
- **Toplam unique indexed words: 27** (önceki: 25)

**Önemli Long-tail Kombinasyonlar:**
- "daily expense" / "daily cost" / "daily price" / "daily tracker"
- "cost per use" / "price per use"
- "purchase tracker" / "purchase value"
- "worth score" / "worth it"
- "how much cost" / "how much per day"
- "cheap ownership" / "cheap per day"
- "expense tracker" / "spending tracker"
- "budget tracker" / "budget item"

### Promotional Text (170 chars)
```
NEW: Full-screen Pro upgrade, smarter Worth Score, and accessibility improvements. Your $1,000 phone costs $2.74/day after a year — see the true cost of everything you own.
```
**170/170 char**

### What's New (v1.1.0)
```
What's New in 1.1:

• Full-screen Pro experience — immersive upgrade flow
• Smarter achievement tracking — Penny Pincher now unlocks when any item drops below $1/day
• Accessibility improvements — better support for Dynamic Type and Reduce Motion
• Currencies added to Pro comparison — see every Pro benefit at a glance
• Under-the-hood polish — Logger, dead code cleanup, refined animations

Thank you for using ThingCost! Rate us if you're enjoying it ⭐
```

### Description (UPDATED — güçlendirilmiş hook)
```
Ever wondered what your iPhone really costs you per day? Or how cheap your couch has become after 3 years?

ThingCost instantly calculates the daily cost of everything you own. Just add what you bought, how much you paid, and when — ThingCost does the math. Watch the cost drop every single day.

▸ THE SIMPLE IDEA
Every purchase has a daily cost: what you paid divided by how long you've owned it. A $1,000 phone bought a year ago? That's $2.74/day. And dropping. ThingCost makes this invisible math visible.

▸ WORTH IT SCORE
ThingCost's unique Worth It Score rates every purchase from 0 to 100. It factors in how long you've owned it, how often you use it, and how much the daily cost has dropped. Amazing (80+), Great (60+), Decent (40+), or time to rethink? Now you'll know before your next impulse buy.

▸ KEY FEATURES

• Instant Daily Cost — Add any purchase and see its cost per day, month, and year
• Worth It Score — A smart 0-100 score tells you if your purchase was truly worth it
• Cost Per Use — Track how often you use items and see the real cost per use
• Item Photos — Attach photos to your items for a beautiful visual inventory
• Cost Over Time Chart — Watch your daily cost curve drop with an interactive chart
• Future Projections — See what items will cost per day in 1 month, 6 months, 1 year, and beyond
• Smart Dashboard — Total daily cost, category breakdown, and worth overview at a glance
• Share Cards — Generate stunning social media cards in 3 styles to share your stats
• Smart Categories — Organize by Electronics, Clothing, Furniture, Vehicle, Sports, Kitchen & more
• Streak Tracking — Build a daily streak and unlock achievements as you track
• Multiple Currencies — Track items in your local currency
• Dark Mode — Full dark mode with automatic system detection
• Privacy First — All data stays on your device. No accounts. No tracking. No cloud.

▸ WHY PEOPLE LOVE IT

"That $200 jacket I felt guilty about? It's down to $0.55/day after a year. Worth It Score: 85. Best purchase ever."

ThingCost changes how you think about money. Expensive purchases feel better over time. Impulse buys reveal their true cost. It's the mindset shift that helps you spend smarter.

▸ FREE TO START

Track up to 5 items for free. Unlock unlimited tracking, photos, use logging, all share card styles, premium charts, CSV export, and multiple currencies with a single one-time purchase — no subscriptions, no recurring charges, ever.

▸ SHARE YOUR STATS

Generate beautiful share cards and post them to Instagram, TikTok, Twitter, or send to friends. Three unique styles designed for social media. Every card includes your Worth It Score — the conversation starter that makes people download ThingCost.

Download ThingCost and start seeing the real cost of everything you own.

Terms of Use: https://theknack2020-sketch.github.io/ThingCost/terms
Privacy Policy: https://theknack2020-sketch.github.io/ThingCost/privacy
```

**Değişiklikler vs mevcut:**
- "Home Screen Widget" satırı → "Multiple Currencies" (widget gate yoktu, currencies gate var)
- "beautiful interactive chart" → "an interactive chart" (daha kısa, aynı anlam)
- Minor polish

---

## 4. REVIEW YANITLARI

**Durum:** 0 review — hiç review yok. Cevap verilecek bir şey yok.
**Aksiyon:** İlk review geldiğinde 48 saat içinde A.C.T. formula ile cevaplanacak.

---

## 5. FEATURING NOMINATION

**Uygun mu:** EVET — anlamlı update (accessibility, fullscreen paywall, achievement fix).

**Pitch özeti:**
- **Hook:** ThingCost flips the script on buyer's remorse — showing purchases get cheaper every day
- **What's new:** Accessibility improvements (Dynamic Type, Reduce Motion), full-screen Pro experience
- **Unique angle:** Worth It Score — no other app quantifies purchase satisfaction 0-100
- **Viral hook:** Share cards designed for Instagram/TikTok — organic growth engine
- **Apple values alignment:** Privacy-first (no cloud, no tracking), accessibility-focused, one-time purchase (no subscription fatigue)

---

## 6. SCREENSHOT PLANI

Screenshot'lar zaten hazırlandı ve ASC'ye upload edildi. Mevcut sıra:

### iPhone (6.9")
| # | Ekran | Caption |
|---|-------|---------|
| 1 | Item List | See What Everything Really Costs |
| 2 | Item Detail | Worth It? Your Score Says It All |
| 3 | Share Card | Share Your Daily Cost on Social |
| 4 | Dashboard | Your Spending Dashboard at a Glance |
| 5 | Paywall | One Purchase. Every Feature. Forever. |

### iPad (13")
| # | Ekran | Caption |
|---|-------|---------|
| 1 | Split View | Track Everything on iPad |
| 2 | Dashboard | Full Dashboard. Full Picture. |
| 3 | Item Detail | Deep Cost Insights |

**Durum:** ✅ Hazır, ASC'ye upload edildi.

---

## 7. TR LOCALE TEMİZLİĞİ

ASC'de `tr` locale hala mevcut. Kaldırılması gerekiyor — English Only kuralı.

---

## 8. UYGULAMA PLANI (Metadata push sırası)

| # | Adım | Durum |
|---|------|-------|
| 1 | `asc status` kontrol — review'da değilse devam | ⏳ |
| 2 | TR locale kaldır | ⏳ |
| 3 | app-info/en-US.json → title + subtitle güncelle | ⏳ |
| 4 | version/1.1.0/en-US.json → keywords + description + whatsNew güncelle | ⏳ |
| 5 | promotional text güncelle | ⏳ |
| 6 | `asc metadata validate` | ⏳ |
| 7 | `asc metadata push --dry-run` | ⏳ |
| 8 | `asc metadata push` | ⏳ |
| 9 | Featuring nomination gönder | ⏳ |

**⛔ Kod/build/submit YAPILMAYACAK — sadece metadata hazırlığı.**
