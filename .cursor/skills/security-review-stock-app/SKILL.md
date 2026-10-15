---
name: security-review-stock-app
description: Performs an OWASP-oriented security review for the Flutter + Express + MySQL coffee shop stock app. Use when reviewing auth, IDOR, SQL injection, mass assignment, stock race conditions, secrets, CORS, exports, or when the user asks for a security review of this stack.
---

# Security review (stock app)

## Steps

1. Read `.cursor/rules/security-baseline.mdc` and RBAC in `AGENTS.md`.
2. Review auth, stock mutation, and any new endpoints/UI touching IDs.
3. Apply checklist; prioritize exploitable issues.
4. Output findings with severity and fix direction (not exploit PoCs).

## Checklist (summary)

- [ ] Parameterized SQL only
- [ ] Passwords hashed (Argon2id/bcrypt); no plaintext
- [ ] JWT secrets from env; tokens never logged
- [ ] Login rate-limited
- [ ] Role middleware + **object-level** `shop_id` checks (IDOR)
- [ ] Client cannot set `role` / `shop_id` on create/update
- [ ] Stock updates transactional (no lost updates / double withdraw races)
- [ ] History not mutable via API
- [ ] Export endpoints authorized
- [ ] CORS allowlist; helmet; body limits
- [ ] Flutter secure token storage
- [ ] No secrets in repo

## Output format

```markdown
## Security review

### Verdict
Pass | Pass with notes | Fail

### Findings
- 🔴 Critical — [area]: issue → fix
- 🟡 Medium — ...
- 🟢 Low — ...

### Retest notes
- ...
```

## References

- Full OWASP-oriented list: [owasp-checklist.md](owasp-checklist.md)
