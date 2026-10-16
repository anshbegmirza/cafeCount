import { Knex } from 'knex';
import { db } from '../db';
import { AppError } from '../errors';
import { StockType } from '../types';

async function mutateStock(
  trx: Knex.Transaction,
  opts: {
    shopId: number;
    productId: number;
    userId: number;
    type: StockType;
    quantity: number;
    note?: string;
    /** For adjust: absolute new quantity */
    newQty?: number;
  },
) {
  const product = await trx('products')
    .where({ id: opts.productId, shop_id: opts.shopId, is_active: true })
    .forUpdate()
    .first();

  if (!product) {
    throw new AppError(404, 'NOT_FOUND', 'Product not found');
  }

  const before = Number(product.current_qty);
  let after: number;
  let delta: number;

  if (opts.type === 'adjust') {
    if (opts.newQty == null || Number.isNaN(opts.newQty)) {
      throw new AppError(400, 'VALIDATION_ERROR', 'newQty required for adjust');
    }
    after = Number(opts.newQty);
    if (after < 0) throw new AppError(400, 'VALIDATION_ERROR', 'Stock cannot be negative');
    delta = after - before;
  } else if (opts.type === 'add') {
    if (opts.quantity <= 0) throw new AppError(400, 'VALIDATION_ERROR', 'Quantity must be > 0');
    delta = opts.quantity;
    after = before + delta;
  } else {
    if (opts.quantity <= 0) throw new AppError(400, 'VALIDATION_ERROR', 'Quantity must be > 0');
    delta = -opts.quantity;
    after = before + delta;
    if (after < 0) {
      throw new AppError(409, 'STOCK_INSUFFICIENT', 'Not enough stock for this withdrawal', {
        available: before,
        requested: opts.quantity,
      });
    }
  }

  await trx('products').where({ id: opts.productId }).update({
    current_qty: after,
    updated_at: trx.fn.now(),
  });

  const [txId] = await trx('stock_transactions').insert({
    shop_id: opts.shopId,
    product_id: opts.productId,
    user_id: opts.userId,
    type: opts.type,
    quantity: delta,
    stock_before: before,
    stock_after: after,
    note: opts.note ?? null,
  });

  return {
    id: txId,
    productId: opts.productId,
    type: opts.type,
    quantity: delta,
    stockBefore: before,
    stockAfter: after,
  };
}

export async function addStock(shopId: number, productId: number, userId: number, quantity: number, note?: string) {
  return db.transaction((trx) =>
    mutateStock(trx, { shopId, productId, userId, type: 'add', quantity, note }),
  );
}

export async function withdrawStock(
  shopId: number,
  productId: number,
  userId: number,
  quantity: number,
  note?: string,
) {
  return db.transaction((trx) =>
    mutateStock(trx, { shopId, productId, userId, type: 'withdraw', quantity, note }),
  );
}

export async function adjustStock(
  shopId: number,
  productId: number,
  userId: number,
  newQty: number,
  note?: string,
) {
  return db.transaction((trx) =>
    mutateStock(trx, { shopId, productId, userId, type: 'adjust', quantity: 0, newQty, note }),
  );
}

export async function listHistory(shopId: number, limit = 50, productId?: number) {
  const q = db('stock_transactions as t')
    .join('products as p', 'p.id', 't.product_id')
    .join('users as u', 'u.id', 't.user_id')
    .where('t.shop_id', shopId)
    .select(
      't.id',
      't.product_id as productId',
      'p.name as productName',
      'p.unit',
      't.type',
      't.quantity',
      't.stock_before as stockBefore',
      't.stock_after as stockAfter',
      't.note',
      't.created_at as createdAt',
      'u.username as userName',
    )
    .orderBy('t.created_at', 'desc')
    .limit(Math.min(limit, 200));

  if (productId) q.andWhere('t.product_id', productId);
  const rows = await q;
  return rows.map((r) => ({
    ...r,
    quantity: Number(r.quantity),
    stockBefore: Number(r.stockBefore),
    stockAfter: Number(r.stockAfter),
  }));
}
