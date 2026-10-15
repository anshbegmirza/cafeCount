# Migration conventions

## Baseline entities (V1)

- `shops` — id, name, status (active/suspended), timestamps
- `users` — id, shop_id NULLABLE, email unique, username unique, password_hash NULLABLE, google_sub NULLABLE unique, role, status
- `categories` — id, shop_id, name
- `products` — id, shop_id, category_id, name, unit, min_stock, active
- `stock_levels` — product_id PK/unique, shop_id, quantity
- `stock_transactions` — append-only audit rows
- `refresh_tokens` — hashed token, user_id, expires_at, revoked

## Rollback notes example

```text
Up: add products.min_stock DECIMAL(12,3) NOT NULL DEFAULT 0
Down: ALTER TABLE products DROP COLUMN min_stock;
Risk: none if column unused in prod yet
```

## Seed

Local seed creates 1 shop + Super Admin. Optional Shop Admin/Employee with known dev passwords documented in `backend/.env.example` comments only (not real prod secrets).
