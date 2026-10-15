# OWASP-oriented checklist (this stack)

## A01 Broken access control

- Every product/stock/user/history route confirms resource `shop_id` matches caller (or Super Admin shop-mgmt exception)
- Employee cannot hit add/adjust/product-mutate endpoints (403)
- Export routes not open to Employee
- IDs in URL/body never authorize by themselves

## A02 Cryptographic failures

- TLS in prod
- Argon2id/bcrypt for passwords
- Strong JWT secrets (≥ 32 random bytes)
- Refresh tokens stored hashed at rest

## A03 Injection

- Bound parameters for all SQL
- No shell calls with user input for PDF/Excel paths
- Zod schemas reject unexpected types

## A04 Insecure design

- Negative stock rejected
- Append-only history
- Atomic stock transaction with row lock

## A05 Security misconfiguration

- Helmet on
- CORS not `*`
- Stack traces hidden in production responses
- `.env` gitignored

## A07 Identification & auth failures

- Rate limit password login and Google auth
- No public signup; admin-provisioned users only
- Google ID token verified server-side; no user auto-create
- Short access token TTL
- Refresh rotation + reuse detection (flag/revoke family if reuse)

## Mass assignment

- Whitelist updatable fields per role
- Never accept `role`, `shop_id`, `password_hash` from client on profile/product updates unless Super Admin shop assignment flows with explicit service checks

## Stock races

- Concurrent withdraws cannot both succeed past zero
- Prefer `SELECT FOR UPDATE` or single `UPDATE … WHERE quantity >= ?`

## Logging

- No Authorization headers, tokens, passwords, or full card-like secrets in logs
- Log `request_id`, user id, shop id, error code
