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

That runs migrations + seed:

- Shop **Stock Room**
- 4 users (table above, including locked `superuser`)
- 5 units: pcs, kg, g, L, bottles
- 5 categories: Coffee beans, Dairy, Syrups, Cups & lids, Cleaning
- 5 products with starter stock (Arabica beans, Whole milk, Vanilla syrup, Paper cups 12oz, Surface cleaner)
