---
name: flutter-feature
description: Scaffolds a Flutter feature using feature-first clean architecture and Riverpod for the coffee shop mobile app. Use when adding a mobile feature, screen, repository, provider, or when the user asks to scaffold Flutter code under mobile/.
---

# Flutter feature scaffold

## Preconditions

- App lives in `mobile/`. Follow `.cursor/rules/flutter.mdc`.
- Do not add offline sync or a second state library.

## Workflow

1. Name the feature (`auth`, `products`, `stock`, `dashboard`, `reports`, `shops`, …).
2. Create folders:

```text
mobile/lib/features/<feature>/
  presentation/
  domain/
  data/
```

3. Add:
   - Domain entity + repository interface
   - Data DTO + API source + repository impl
   - Riverpod providers (presentation)
   - Screen/widgets; gate by role if needed
4. Wire route in `mobile/lib/app/` router only if navigation is required.
5. Add unit test for domain logic and/or widget test for the critical path.

## Naming

- Files: `stock_repository.dart`, `withdraw_stock.dart`, `stock_controller.dart` (or `*Notifier`)
- Providers: `stockRepositoryProvider`, `withdrawStockProvider`

## Checklist

- [ ] No HTTP from widgets
- [ ] Tokens via secure storage helper in `core/`
- [ ] Errors mapped from API error contract
- [ ] Employee/Shop Admin/Super Admin UI gating matches RBAC
- [ ] No new dependency without need

## References

- Templates: [templates.md](templates.md)
