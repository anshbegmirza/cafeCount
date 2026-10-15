# CafeCount V1 acceptance checklist

Based on `CLIENT REQUIREMENTS FOR MR ABDULLA.pdf` + locked V1 decisions.

- [ ] Login works for Super Admin, Shop Admin, Employee
- [ ] Single shop data scope (shop_id on records)
- [ ] Super Admin and Shop Admin share same permissions (V1)
- [ ] Shop Admin can manage products, categories, units, min stock
- [ ] Add / withdraw / adjust stock
- [ ] Manage employees
- [ ] Employee can view stock and withdraw only
- [ ] Stock updates after every transaction
- [ ] Stock history full details; no delete/silent edit
- [ ] Mistakes fixed only via new adjustment
- [ ] Low / out-of-stock indicators
- [ ] Dashboard shows inventory overview + recent transactions
- [ ] PDF and Excel export (admin)
- [ ] English + Arabic with RTL
- [ ] Light + dark theme with `#28C8FF`

## Deferred (not V1)

- Multi-shop create / activate / suspend UI
- Distinct Super Admin-only shop management
- iOS build on Windows
- Web dashboard, POS, suppliers, offline, push
