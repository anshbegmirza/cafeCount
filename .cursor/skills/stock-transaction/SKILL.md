---
name: stock-transaction
description: Implements add, withdraw, and adjust stock mutations with append-only history, row locking, and shop-scoped authorization. Use when building or fixing stock add/withdraw/adjust, inventory races, stock history, or negative-stock prevention.
---

# Stock transaction

## Invariants

1. One DB transaction per mutation.
2. Lock stock row → compute → update qty → INSERT history.
3. History never updated/deleted.
4. Withdraw: reject if `stock_after < 0`.
5. Always set `shop_id`, `user_id`, `stock_before`, `stock_after`, `type`, `quantity` (delta).

## Types

| type | Who | Delta |
|------|-----|-------|
| `add` | Shop Admin | +qty |
| `withdraw` | Shop Admin, Employee | −qty |
| `adjust` | Shop Admin | set to target; delta = target − before |

## Algorithm

```text
BEGIN
  lock stock_levels for product_id + shop_id
  stock_before = current
  stock_after = f(type, qty_or_target)
  if type=withdraw and stock_after < 0 → ROLLBACK + STOCK_INSUFFICIENT
  update stock_levels.quantity = stock_after
  insert stock_transactions (...)
COMMIT
```

## Authz

- Resolve product in caller's shop (Super Admin stock ops not default in V1).
- Employee: withdraw only.

## Tests required

- add increases qty + history row
- withdraw decreases; insufficient → 409/400 with `STOCK_INSUFFICIENT`
- adjust sets absolute qty + history
- concurrent withdraws cannot both overdraw (transaction/lock test if feasible)
- IDOR: other shop's productId → 404/403

## References

- Field reference: [history-fields.md](history-fields.md)
