# Architecture review — detailed checklist

## Monorepo

- New packages only under `mobile/`, `backend/`, `docs/`
- Shared code: prefer duplication over premature `packages/` monorepo tooling in V1 unless human asks

## Flutter

- No Bloc/GetX/MobX as primary state
- Widgets do not call HTTP directly
- Tokens not in SharedPreferences
- Role gating in UI matches RBAC but does not replace API checks
- No offline-first frameworks (Hive-as-SoT, sync queues) in V1

## Express

- TypeScript only under `backend/`
- Knex for migrations; parameterized SQL in repos
- No SQL in controllers/routes
- No public signup; Google maps to existing users only
- No business rules only in repositories
- Middleware order: helmet/cors/rateLimit → auth → validate → controller
- Refresh token rotation present for auth changes

## Data

- Migrations for schema diffs
- Stock path uses transaction + history insert
- Indexes considered for new list/filter endpoints

## Scope creep flags

Reject or flag: billing, suppliers, PO, push notifications, custom roles, web admin SPA, multi-tenant beyond shops table design.
