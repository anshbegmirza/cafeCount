# Stock history fields

| Column | Notes |
|--------|--------|
| id | PK |
| shop_id | NOT NULL |
| product_id | NOT NULL |
| type | `add` \| `withdraw` \| `adjust` |
| quantity | Signed delta (withdraw negative or store abs + type; pick one and stay consistent — prefer signed delta) |
| stock_before | Quantity before mutation |
| stock_after | Quantity after mutation |
| user_id | Actor |
| note | Optional reason (esp. adjust) |
| created_at | Server time UTC |

Mistakes: insert a new `adjust` (or compensating withdraw/add). Never edit old rows.

## SQL sketch

```sql
SELECT quantity FROM stock_levels WHERE product_id = ? AND shop_id = ? FOR UPDATE;

UPDATE stock_levels SET quantity = ? WHERE product_id = ? AND shop_id = ?;

INSERT INTO stock_transactions
  (shop_id, product_id, type, quantity, stock_before, stock_after, user_id, note, created_at)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, UTC_TIMESTAMP());
```
