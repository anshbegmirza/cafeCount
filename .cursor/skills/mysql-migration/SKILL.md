---
name: mysql-migration
description: Creates a safe MySQL migration with up SQL and rollback notes for the coffee shop schema. Use when changing schema, adding tables/indexes, seeding, or when the user asks for a database migration.
---

# MySQL migration

## Rules

- Use **Knex** migrations under `backend/migrations/` (locked for this MVP).
- Shop-scoped tables include `shop_id` NOT NULL (+ FK to `shops`).
- Never alter `stock_transactions` to allow destructive updates as a feature.
- Prefer `knex.schema` or raw SQL inside migration `up`/`down` — keep down working when practical.

## Workflow

1. Create: `npx knex migrate:make <slug>` (from `backend/`).
2. Write **up** + **down** in the generated file.
3. Users table must support email, username, password_hash (nullable), optional google_sub.
4. Update Knex seed for local/dev only.
5. Document any data backfill risk.

## Checklist

- [ ] FKs and indexes for new filter paths
- [ ] Charset/collation utf8mb4
- [ ] No drop of history table
- [ ] Seed remains idempotent for local

## References

- Conventions: [conventions.md](conventions.md)
