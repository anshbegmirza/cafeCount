---
name: express-endpoint
description: Scaffolds a secure Express /api/v1 endpoint with Zod validation, authz, and layered architecture for the coffee shop backend. Use when adding API routes, controllers, services, or when the user asks to create a backend endpoint.
---

# Express endpoint scaffold

## Preconditions

- Code under `backend/` in **TypeScript**. Follow `.cursor/rules/express.mdc` and RBAC in `AGENTS.md`.
- Never add a public signup route.

## Workflow

1. Define method + path under `/api/v1/...`.
2. Write Zod schema (whitelist fields; strip unknown).
3. Add route with `requireAuth`, `requireRole(...)`, and shop scope as needed.
4. Controller: validate → service → response.
5. Service: business rules; start DB transaction if mutating stock.
6. Repository: parameterized SQL only.
7. Register in router index.
8. Add supertest coverage for happy path + 401/403 + IDOR.

## Response / errors

Success: resource JSON or `{ data: ... }` (pick one style and stay consistent once codebase exists).

Errors: ADR-005 shape via central handler (`throw AppError(code, status)`).

## Checklist

- [ ] Role middleware matches matrix
- [ ] `shop_id` from auth context, not trusted body
- [ ] No SQL in controller
- [ ] Rate limit if auth-sensitive
- [ ] Export endpoints use service-layer generators

## References

- Skeleton: [skeleton.md](skeleton.md)
