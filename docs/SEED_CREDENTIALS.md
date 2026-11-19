# Stock Room — seed credentials

**Local / demo only.** Share privately if needed. Rotate after client review.

| Username | Password | Role |
|----------|----------|------|
| superuser | `123!Test` | super_admin (locked) |
| superadmin | `SuperAdmin@123` | super_admin |
| shopadmin | `ShopAdmin@123` | shop_admin |
| employee | `emp@123!` | employee |

Shop: **Stock Room**  
Emails: `superuser` → `captainmaverick010@gmail.com`; others `@cafecount.local`

## Fresh DB (local)

```bash
cd backend
npm run db:setup
```

That runs migrations + seed (shop + 4 users + 5 units: pcs, kg, g, L, bottles).  
**No products** — add inventory in the app.
