# CafeCount — Agent Brief

Flutter + Express + MySQL stock app for coffee shops. **Product source of truth:** `CLIENT REQUIREMENTS FOR MR ABDULLA.pdf` + locked decisions below.

## How agents should work

1. Read this file + always-apply rules before coding.
2. Match stack rules by path (`mobile/**`, `backend/**`).
3. Use project skills for scaffolds/reviews (see `.cursor/skills/`).
4. Smallest correct change. No speculative abstractions.
5. Prefer existing patterns. Migrations-only for schema.

## Monorepo layout (locked)

```
/
  mobile/          # Flutter app (CafeCount)
  backend/         # Node.js + Express + TypeScript + MySQL
  docs/            # ADRs, runbooks
  AGENTS.md
  .cursor/
```

## Locked product decisions (V1)

- **App name:** CafeCount
- **Single shop** now; `shop_id` on all shop-scoped tables for later multi-shop
- **Roles:** `super_admin`, `shop_admin`, `employee` — **super_admin and shop_admin have identical permissions in V1**
- **i18n:** English + Arabic, full RTL; default from device locale
- **Theme:** primary `#28C8FF` + shades; light and dark
- **UI:** Admin = dashboard-first; Employee = fast withdraw
- **Timezone:** `Asia/Kolkata`
- **Auth:** username/email + password only (no Google in V1); admin-provisioned users; no public signup
- **Seed:** `superadmin`, `shopadmin`, `employee` + one generic shop
- **Out of V1:** POS, suppliers/POs, full offline, push, custom roles, web dashboard, multi-shop UI, iOS on this Windows machine

---

## Architecture decisions (ADR-style)

### ADR-001 — Auth model

- **No public signup.** Users created by admins only.
- **Password login:** identifier is **email or username** + password.
- **Passwords:** bcrypt cost ≥ 12 (or Argon2id). Never plaintext.
- **Tokens:** Access JWT (~15m) + Refresh JWT (~7d, rotated, hashed server-side).
- **Claims:** `sub`, `shop_id`, `role`. Re-check role/shop from DB for sensitive ops.
- **Flutter:** tokens only in `flutter_secure_storage`.
- **Password policy:** min 8 chars.
- **Rate limit:** `/auth/login`.

### ADR-002 — RBAC matrix (V1)

| Action | Super Admin | Shop Admin | Employee |
|--------|:-----------:|:----------:|:--------:|
| Products/categories/units/min stock | ✅ | ✅ | ❌ |
| Add stock | ✅ | ✅ | ❌ |
| Withdraw stock | ✅ | ✅ | ✅ |
| Adjust stock | ✅ | ✅ | ❌ |
| Manage employees | ✅ | ✅ | ❌ |
| View stock + history | ✅ | ✅ | ✅ (view only) |
| Dashboard | ✅ | ✅ | limited |
| PDF/Excel export | ✅ | ✅ | ❌ |
| Multi-shop create/suspend | deferred | — | — |

Object-level: filter by `shop_id` on all shop data.

### ADR-003 — Multi-shop (`shop_id`)

Present from day one. Seed one generic shop. Super Admin may have `shop_id` set to that shop in V1 (same as shop admin).

### ADR-004 — Stock mutation algorithm

Inside one DB transaction:

1. Lock product/stock row (`SELECT … FOR UPDATE` or atomic update).
2. Compute `stock_after` from `stock_before` + delta.
3. **Withdraw:** reject if `stock_after < 0`.
4. Update quantity.
5. **INSERT** history (append-only). Never UPDATE/DELETE history.
6. Commit.

History: `product_id`, `type` (`add`|`withdraw`|`adjust`), `quantity`, `stock_before`, `stock_after`, `user_id`, `created_at`, optional `note`.

### ADR-005 — API error contract

```json
{
  "error": {
    "code": "STOCK_INSUFFICIENT",
    "message": "Not enough stock for this withdrawal",
    "details": {}
  }
}
```

HTTP: 400 / 401 / 403 / 404 / 409 / 429 / 500. Routes under `/api/v1`.

### ADR-006 — Env / config

Secrets in `.env` only. Ship `backend/.env.example`. Required: DB creds, `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET`, `CORS_ORIGINS`, `NODE_ENV`, `PORT`, `TZ=Asia/Kolkata`.

### ADR-007 — Reports

Excel (`exceljs`) and PDF (`pdfkit`) in service layer. Admin only.

### ADR-008 — Deployment

Local-first. Render for demo later. No K8s/queues in V1.

### ADR-009 — Flutter

Riverpod only. Feature-first + `presentation/` `domain/` `data/`. EN+AR via easy_localization or ARB. Offline not required.

### ADR-010 — Backend

TypeScript. `routes → controllers → services → repositories`. Zod at boundary. `mysql2` + Knex migrations.

### ADR-011 — Migrations

Knex under `backend/migrations/`. Parameterized SQL only.

---

## Skills

| Skill | When |
|-------|------|
| `architecture-review` | Architecture fit |
| `security-review-stock-app` | Auth, IDOR, SQL, stock races |
| `flutter-feature` | New mobile feature |
| `express-endpoint` | New API endpoint |
| `mysql-migration` | Schema change |
| `stock-transaction` | Add/withdraw/adjust |

## Subagents

Role prompts in `.cursor/agents/`.
