# Express endpoint skeleton

```text
backend/src/
  routes/v1/<resource>.routes.ts
  controllers/<resource>.controller.ts
  services/<resource>.service.ts
  repositories/<resource>.repository.ts
  validators/<resource>.schemas.ts
  middleware/auth.ts
  middleware/errorHandler.ts
backend/migrations/   # Knex
```

## Route sketch

```ts
router.post(
  '/products/:productId/withdraw',
  requireAuth,
  requireRole('shop_admin', 'employee'),
  validate(withdrawSchema),
  stockController.withdraw,
);
```

## Service sketch

```ts
async function withdraw(params: {
  shopId: number;
  userId: number;
  productId: number;
  qty: number;
}) {
  return withTransaction(async (tx) => {
    // lock, update, insert history — see stock-transaction skill
  });
}
```

