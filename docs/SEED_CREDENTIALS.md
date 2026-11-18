# Stock Room — seed credentials

**Local / demo only.** Share privately if needed. Rotate after client review.

| Username | Password | Role |
|----------|----------|------|
| superadmin | `test123` | super_admin |
| shopadmin | `test123` | shop_admin |
| employee | `test123` | employee |

Shop: **Stock Room**  
Emails: `@cafecount.local` (seed only)

## Fresh DB (local)

```bash
cd backend
npm run db:setup
```

That runs migrations + seed (shop + 3 users + 5 units: pcs, kg, g, L, bottles).  
**No products** — add inventory in the app.
