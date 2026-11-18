# Hidden Room — iOS build costs & selling prices (USD)

Research snapshot: **Oct 2026**. Prices move over time.

This note covers:

1. Cost to **build and ship iOS** (no MacBook)
2. **Apple account** fees
3. **Database** and **backend** hosting costs
4. Suggested **selling prices** (per users / per cafe)

---

## 1. iOS build costs (no Mac)

You need a Mac in the cloud to compile and sign a Flutter iOS app, plus an Apple Developer account to put it on TestFlight / App Store.

### A. Apple Developer Program (required)

| Item | Price (USD) | Notes |
|------|-------------|--------|
| **Apple Developer Program** | **$99 / year** | Needed for TestFlight + App Store. Individual or Organization. |
| Apple Developer Enterprise | $299 / year | Only for private in-house distribution. **Not needed** for selling to cafes via App Store. |

### B. Mac access — cloud build minutes

Good if you mostly develop on Windows and only need Mac minutes to produce an `.ipa`.

| Plan | Price (USD) | What you get |
|------|-------------|--------------|
| Free tier (typical) | **$0** | about **500 build minutes / month** |
| Extra minutes | about **$0.10 / minute** | After free quota |

Rough math for Flutter iOS release builds: often **15–40 minutes** each.  
Example: 4 release builds/month ≈ **60–160 min** → usually **inside free tier**.

| Goal | Suggested spend |
|------|-----------------|
| First iOS ship + rare updates | Apple **$99/yr** + free/extra build minutes → **~$99–200 / year** |
| More frequent iOS releases | Apple **$99/yr** + paid minutes as needed (often still under **~$20 / mo**) |

### C. App Store cut (if you bill through Apple)

If cafes pay **inside the iOS app** (IAP / subscription):

| Case | Apple commission |
|------|------------------|
| Standard | **30%** |
| Small Business Program (under ~$1M / year proceeds) | **15%** |

**Better for B2B cafes:** sell a **web/Stripe subscription** (or invoice), and keep the App Store app as a free download that logs into your backend. Then Apple’s cut often does **not** apply the same way (confirm with current Apple rules + your lawyer for your regions).

---

## 2. Database costs (free + paid)

Hidden Room uses **MySQL**.

### Managed MySQL

| Service | Free | Paid (from) | Notes |
|---------|------|-------------|--------|
| **Aiven MySQL** | **$0** (1 GB RAM, 1 GB storage, always-free style) | **~$5 / mo** (small) · **~$19 / mo** (hobby) · **~$75+ / mo** (startup) | Real free MySQL; may power off if idle |
| **DigitalOcean Managed MySQL** | No free tier (promo credit sometimes) | **~$15 / mo** (1 GB) · **~$30 / mo** (2 GB) | Simple flat pricing; backups included |
| **AWS RDS MySQL** | Free credits / legacy free micro (limits apply) | about **~$12–15 / mo** for smallest always-on + storage | Flexible; bill can grow with storage/transfer |
| **Google Cloud SQL MySQL** | Credits for new accounts | about **~$8+ / mo** smallest | Similar to AWS — usage-based |
| **Azure Database for MySQL** | Credits for new accounts | about **~$12+ / mo** smallest | Similar to AWS |

**Practical for this project**

| Stage | Suggested DB spend |
|-------|--------------------|
| Local / demo | **$0** (local MySQL or free managed) |
| Small production (few cafes) | **~$5–15 / mo** managed MySQL |
| Growing production | **~$30–75 / mo** managed MySQL |

---

## 3. Backend deployment costs

### Backend (Express / Node API)

| Option | Free | Paid (from) | Notes |
|--------|------|-------------|--------|
| **Render** web service | **$0** (sleeps after idle; cold start) | **$7 / mo** (always-on starter) · **$25 / mo** (1 CPU / 2 GB) | Fits Node/Docker demos well |
| **Railway** | **$0** + **~$1** credit / mo | Hobby **$5 / mo** + usage | Simple deploys; costs scale with RAM/CPU |
| **Fly.io** | Small free allowance (varies) | often **~$5–15 / mo** for a small always-on app | Good global edge |
| **DigitalOcean Droplet** | Promo credit sometimes | **$4 / mo** · **$6 / mo** · **$12 / mo** | Run API yourself |
| **AWS / Google / Azure** small VM or container | New-account credits | often **~$5–20 / mo** once credits end | More setup |

### Ballpark monthly hosting stacks

| Stack | Demo / hobby | Small production |
|-------|--------------|------------------|
| Free API (sleeps) + free DB | **~$0** | Not reliable for cafes |
| Always-on API **$7** + MySQL **$5–15** | — | **~$12–22 / mo** |
| Stronger managed (API **$25** + MySQL **$30**) | — | **~$55 / mo** |

---

## 4. Market rates — cafe / restaurant inventory apps

Competitors usually charge **per location (cafe)**, not per phone user. Per-user fees exist but are less common.

| Product | Model | Price (USD) | Rough fit vs Hidden Room |
|---------|--------|-------------|---------------------------|
| Rinvy | Per location | Free → **~$24–58 / mo** (annual) | Broader (recipes, invoices, POS) |
| CafeTally | Per location | **$49 / mo** | Cafe-focused |
| KitchenInvy | Location + users | **$29** (1 user) · **$69** (5 users) · **$129** Pro | Closer “simple ops” band |
| Yumpit | Per location + team caps | **$49 / mo** (1 site, 5 people) | Inventory + more ops |
| Square Inventory by MarketMan | Per location add-on | **+$99 / mo** | Needs Square |
| Thrive / Shopventory | Users + channels | **~$49–229+ / mo** | POS-linked retail |
| Culistock | Per location | **$99–349 / mo** | Full restaurant OS |
| Orca | Per store | **~$179–199 / mo** + setup | Heavy suite |

**Takeaway:** for a **stock withdraw / history / staff** app (Hidden Room V1 — no POS, no suppliers, no recipes), a fair band is **below** Culistock/Orca and near **$29–79 / location / month**, or a **one-time license** if you prefer simple sales.

---

## 5. Suggested selling prices for Hidden Room

All figures are **USD**. These are **recommendations**, not locked product decisions.

### Option A — Per cafe / restaurant (recommended)

Matches how the market sells. One shop = one subscription. Staff logins included up to a cap.

| Plan | Monthly | Yearly (≈2 months free) | Included users | Target |
|------|---------|-------------------------|----------------|--------|
| **Starter** | **$29 / location** | **$290 / year** | up to **5** staff | Small cafe, basic stock |
| **Team** | **$49 / location** | **$490 / year** | up to **15** staff | Typical cafe / small restaurant |
| **Business** | **$79 / location** | **$790 / year** | **unlimited** staff | Busy site / multi-shift |

Extras (optional):

| Add-on | Price |
|--------|--------|
| Extra location | Same as plan × locations |
| Onboarding / data setup | **$99–199** one-time |
| Custom branding / white-label | **Custom** (often **$2,000+** setup + higher monthly) |

### Option B — Per user (if you want seat pricing)

Use when the buyer cares about “how many phones.”

| Seats | Suggested price |
|-------|-----------------|
| 1–3 users | **$19 / user / mo** (min **$39 / mo** per cafe) |
| 4–10 users | **$12 / user / mo** |
| 11+ users | **$8 / user / mo** |

Example: 1 admin + 4 employees = 5 users → **5 × $12 = $60 / mo**.

### Option C — One-time license (sell once to a cafe)

Useful for owners who hate subscriptions.

| License | Price (USD) | Includes |
|---------|-------------|----------|
| Single cafe | **$499–799** | App access for that shop, 1 year of updates |
| Single cafe + setup | **$899–1,200** | License + onboarding |
| Yearly maintenance after year 1 | **$149–249 / year** | Updates + hosting share |

### Option D — Sell the product as a “business in a box”

If you sell to **other developers / agencies** (resell rights), that is different from selling to cafes:

| Package | Ballpark (USD) |
|---------|----------------|
| Source + self-host rights (1 brand) | **$2,500–5,000** one-time |
| White-label + your hosting | **$199–399 / mo** per client brand |

---

## 6. Quick cost vs revenue examples

### Your minimum yearly / monthly run cost

| Item | Low (demo) | Small production |
|------|------------|------------------|
| Apple Developer | $99 / year (~$8 / mo) | $99 / year |
| iOS cloud builds | $0–20 / mo | $0–20 / mo |
| Database (MySQL) | $0 | $5–15 / mo |
| Backend API | $0 (sleeps) | $7–25 / mo |
| **Rough total** | **~$8–30 / mo** | **~$20–70 / mo** |

### Break-even (rough)

At **$49 / mo** per cafe (Team plan):

| Cafes paying | Monthly revenue | Covers hosting + iOS? |
|--------------|-----------------|------------------------|
| 1 | $49 | Yes for a lean stack |
| 5 | $245 | Comfortable |
| 10 | $490 | Strong for a small SaaS |

---

## 7. What we recommend writing on a sales sheet

**For cafes & restaurants (primary):**

> Hidden Room stock app — **$49 / month per location**  
> Up to 15 staff · stock withdraw · history · low-stock alerts · EN + Arabic  
> Or **$490 / year** (save 2 months)

**Budget tier:** **$29 / mo** (≤5 staff)  
**Busy site:** **$79 / mo** (unlimited staff)

**Internal run cost (not for customers):** Apple **$99/year** + cloud iOS builds + about **$12–70 / mo** for API + MySQL.

---

*Document for planning only. Taxes, payment fees (Stripe ~2.9%+), and local Apple pricing may apply.*
