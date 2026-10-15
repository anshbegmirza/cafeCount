---
name: architecture-review
description: Reviews code changes against Coffee Shop Stock Management architecture ADRs and layered conventions. Use when reviewing PRs, diffs, architecture fit, monorepo structure, Riverpod/Express layering, or when the user asks for an architecture review.
---

# Architecture review

## Steps

1. Read `AGENTS.md` ADRs and `.cursor/rules/architecture.mdc`.
2. Inspect the change set (diff or named paths).
3. Check against the checklist below.
4. Report findings in the output format.

## Checklist

- [ ] Paths under `mobile/` or `backend/` (no alternate roots)
- [ ] Flutter: feature-first + presentation/domain/data; Riverpod only
- [ ] Backend: routes → controllers → services → repositories
- [ ] API under `/api/v1`; Zod at boundary
- [ ] `shop_id` scoping; no cross-shop leaks
- [ ] Stock history append-only; mutations transactional
- [ ] Reports in services (`exceljs`/`pdfkit`), not controllers
- [ ] No V1 out-of-scope features (POS, offline sync, push, web dashboard)
- [ ] No speculative abstractions / unused layers
- [ ] Error shape matches ADR-005

## Output format

```markdown
## Architecture review

### Verdict
Pass | Pass with notes | Fail

### Findings
- 🔴 Critical: ...
- 🟡 Should fix: ...
- 🟢 Note: ...

### ADR conflicts
- ADR-00X: ...

### Suggested follow-ups
- ...
```

## References

- Detailed checks: [checklist.md](checklist.md)
- Project ADRs: `AGENTS.md`
