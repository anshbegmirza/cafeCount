# Hidden Room — Design System (V1)

**Status:** Source of truth for UI redesign. Flutter implementation in progress (light theme, EN+AR).  
**Brand:** Hidden Room only (no CafeCount, no Lerno Cafe).  
**Logo file:** `lerno cafe logo.png` at repo root (asset name legacy; visual = Hidden Room).

**Blend intent:** Keep the *friendly, readable, stock-app UX* from `redesign-branding-work/final-mock-design/` (3-tab shell, hamburger modules, list cards, bottom sheets, big type). Restyle surfaces, type, and chrome to match the Hidden Room logo (quiet boutique cafe — dark forest + cream).

---

## 1. Brand

| Item | Rule |
|------|------|
| App name | **Hidden Room** |
| Tagline (splash/about) | Stock for the room — short, stock-focused |
| Logo | Stacked serif wordmark **Hidden / Room** + double-dot mark. Prefer official PNG. Do not redraw dots as letters. |
| Mark in app bar | Compact: double-dot colon **:** motif in a soft circle, *or* cropped wordmark. Never a cup icon. |
| Voice | Calm, clear, short labels. No slang. Ages ~20–55. |

**Logo do / don't**

```text
✅ Use official PNG on splash / about / empty brand moments
✅ Cream (#E6E3DB) wordmark on Forest (#212621) only for full logo lockups
✅ Double-dot as tiny brand motif (loading, dividers, toast accent — sparingly)
❌ Cup / saucer / coffee bean as brand mark
❌ “Lerno”, “CafeCount”, teal cup-circle from old mocks
❌ Stretch, recolor cream→pure white, or drop the double-dot from the wordmark
```

---

## 2. Color tokens

Sampled from logo + inventory needs from prior mocks.

### Core (from logo)

| Token | Hex | Use |
|-------|-----|-----|
| `forest` | `#212621` | Brand ink, primary buttons, key titles, top icons |
| `cream` | `#E6E3DB` | Logo text; light-theme page wash; dark-theme text |
| `forestLift` | `#2E3530` | Slightly lighter forest (drawer header, dark cards) |
| `mist` | `#F4F1EC` | Light app background (cream lifted for all-day reading) |
| `paper` | `#FFFEFA` | Cards / sheets on mist |
| `ink` | `#1C1F1C` | Body text on light (near-forest, not pure black) |
| `muted` | `#6B716B` | Secondary labels, hints |
| `line` | `#D8D4CC` | Borders, hairlines |

### Status (stock — keep prior clarity)

| Token | Hex | Use |
|-------|-----|-----|
| `ok` | `#2F6B4F` | In-stock / success (green that fits forest family) |
| `low` | `#C4A035` | Low stock chip / warning |
| `out` | `#C45C4A` | Out of stock / danger / deactivate |
| `toastOkEdge` | `#2F6B4F` | Success toast left edge + tick circle |
| `toastErrEdge` | `#C45C4A` | Error toast left edge + X circle |

### Theme strategy (locked for redesign mocks)

| Surface | Rule |
|---------|------|
| **Daily app (V1)** | **Light:** `mist` bg, `paper` cards, `forest` actions, `ink` text — same UX density as final-mock-design, new palette. |
| **Brand moments** | Splash + optional login hero: full `forest` + cream wordmark (logo as-is). |
| **Dark theme** | Deferred (“Dark soon” in Settings). When built: `forest` scaffold, `cream` text, `forestLift` cards. |

Teal `#1AA6A0` from Lerno mocks is **retired**. Do not mix teal into Hidden Room screens.

---

## 3. Typography

| Role | Style | Notes |
|------|--------|------|
| Brand wordmark | High-contrast **serif** (match logo; e.g. Playfair / Cormorant family) | Splash, About, empty brand only |
| Screen titles | **Sans** semibold/bold ~26–30pt | `ink` / `forest` — readable first |
| Section labels | Sans medium ~14–16pt | `muted`, uppercase optional sparingly |
| Body / list | Sans regular ≥16pt | Never &lt;15pt for primary content |
| Buttons | Sans semibold ≥17pt | |
| Chips | Sans medium ~14–15pt | |

Serif is brand jewelry. **All operational UI is sans** so staff can scan stock fast.

---

## 4. Layout & density

| Rule | Value |
|------|--------|
| Phone frame | Same portrait ratio as prior mocks (~9:16) |
| Side padding | 16–20pt |
| Card radius | 16pt |
| Sheet top radius | 24pt (top corners only) |
| Button height | ≥56pt primary; ≥48pt secondary |
| List row / card min tap | ≥64pt tall |
| +/- controls | ≥56–64pt circles |
| Bottom nav height | ~64–72pt + safe area |

Whitespace: calm boutique feel, but **not sparse** — stock apps need dense-enough lists. Aim for final-mock-design density, not fashion-landing emptiness.

---

## 5. App shell (UX locked — keep from final mocks)

```text
TOP BAR (every post-login screen)
  [hamburger]     [brand mark]     [optional trailing]

BOTTOM NAV — exactly 3 — never a 4th
  1. Home      — house
  2. Products  — LIST icon (lines), not cube/grid
  3. Settings  — gear

Active tab: soft pill using forestLift/cream wash + forest icon/label
Inactive: muted ink
Menu screens (Withdraw, History, Staff, Reports): all 3 tabs inactive

HAMBURGER (top-left)
  Admin:    Withdraw | Products | Stock history | Staff | Reports
  Employee: Withdraw | Products | Stock history
            (no Staff, no Reports)

Login / Splash: no bottom nav, no hamburger
```

**Home**

- Admin: denser dashboard (counts, needs attention).
- Employee: simpler; fast path to Withdraw.
- “Needs attention” → Products with Low/Out filter applied.

**Settings rows**

Language · Theme (Light now / “Dark soon”) · About · Logout

---

## 6. Components

### Buttons

| Kind | Look |
|------|------|
| Primary | Filled `forest`, label `cream`, full width in sheets, 16pt side inset |
| Secondary | Outline `forest` on `paper` |
| Danger | Outline or filled `out` (deactivate) |
| Cancel | Outline or text — never competing with primary |

### Inputs

White/`paper` fields, `line` border, 56pt tall, 16pt label above. Reject unknown / empty with inline hint — no center alert dialogs.

### Chips (filters, units, period)

Pill; unselected = `paper` + `line`; selected = filled `forest` + `cream` text. Units: `pcs` `kg` `g` `L` `bottles` `boxes`.

### List cards (products, staff, history)

`paper` on `mist`, soft shadow or 1pt `line`, left content + right status chip. **No photo grid.** Product cards show name, qty + unit, min, OK/LOW/OUT.

### History cards

Must show **product name**, type, qty, before→after, user, time. From / To date filter on screen.

### Bottom sheets (only modal pattern)

```text
✅ Flush to bottom, full width, top corners 24pt, grab handle, covers bottom nav
✅ Outlined circular X close (forms) or Cancel row (action menus)
❌ Center dialogs, floating “card dialogs” with side gaps
```

Sheets we need: product actions, add/edit product, add/adjust stock, staff actions, add/edit staff, deactivate confirm.

### Toasts

Full card width (−16pt margins), under top bar: white/`paper`, colored left edge, circle + ✓ or ✗, short title + one detail line. Success = `ok`; error = `out`.

### FAB

Admin Products / Staff only (add). Forest circle, cream icon. Never on Reports/History/Withdraw unless product asks later.

---

## 7. Screens map (modules = PDF + current app only)

| Screen | Who | Notes |
|--------|-----|--------|
| Splash | all | Forest + official logo |
| Login | all | Email/username + password; brand calm, readable |
| Home | admin / employee | Role density differs |
| Products (+ Low filter) | admin edit; employee view | List cards |
| Settings | all | |
| Hamburger | role-based | |
| Withdraw + toasts | both | Confirm withdraw + big +/- |
| History + empty | both | Empty CTA → Withdraw |
| Staff + sheets | admin | ⋮ → sheet only |
| Reports + export toast | admin | PDF + Excel |
| Product sheets | admin | actions / add / edit / add stock / adjust |

**Out of V1 UI:** POS, suppliers/POs, offline, push, web dashboard, multi-shop switcher, Arabic mocks, dark theme screens.

---

## 8. Role matrix (visual)

| Affordance | Admin | Employee |
|------------|:-----:|:--------:|
| Products FAB / edit / stock sheets | ✅ | ❌ |
| Withdraw | ✅ | ✅ |
| History | ✅ | ✅ |
| Staff | ✅ | ❌ |
| Reports export | ✅ | ❌ |
| Settings | ✅ | ✅ |

---

## 9. Motion (light)

- Sheet: slide up ~250ms ease-out.
- Toast: fade + slight drop, auto-dismiss ~3s.
- Tab: soft pill cross-fade — no bounce spam.
- Prefer 2–3 calm motions total; no glitter.

---

## 10. Accessibility & readability

- Contrast: `ink`/`forest` on `mist`/`paper` ≥ WCAG AA for body.
- Primary actions ≥56pt; icons with text labels on bottom nav.
- Status never color-only — chip text OK / LOW / OUT.
- English only for this redesign pass; RTL later without breaking shell.

---

## 11. What we keep vs change from `final-mock-design/`

| Keep (UX) | Change (look) |
|-----------|----------------|
| 3-tab shell + hamburger IA | Brand → Hidden Room |
| Bottom sheets, toasts, list cards | Palette → forest / cream / mist |
| Big type, Confirm withdraw, history names | Logo → wordmark + double-dot (no cup) |
| Same screen list / RBAC | Accent teal → forest |
| Light-first daily use | Splash can go full forest |

Old JPGs stay as **UX wire references**. New mocks / code must follow **this** file for color and brand.

---

## 12. File & handoff

| Artifact | Path |
|----------|------|
| This system | `docs/DESIGN_SYSTEM.md` |
| UX shell checklist | `redesign-branding-work/final-mock-design/UX_SHELL_LOCKED.txt` (update brand lines when regenerating) |
| Logo PNG | `lerno cafe logo.png` (root) |
| Prior UX mocks | `redesign-branding-work/final-mock-design/*.jpg` |

**Next (when you say go):** regenerate mocks under a new folder (e.g. `redesign-branding-work/hidden-room-mocks/`) using this system — still no Dart until you sign off.

---

## 13. One-line checklist for every new screen

```text
Hidden Room? · mist/paper/forest? · 3 tabs or auth chrome? · sheet not dialog?
· ≥16pt body? · product name on history? · admin/employee right? · no teal/cup/Lerno?
```
