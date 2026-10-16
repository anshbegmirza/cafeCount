import { db } from '../db';
import { AppError } from '../errors';
import { Unit } from '../types';

export async function listProducts(shopId: number, search?: string) {
  const q = db('products as p')
    .leftJoin('categories as c', 'c.id', 'p.category_id')
    .where('p.shop_id', shopId)
    .andWhere('p.is_active', true)
    .select(
      'p.id',
      'p.name',
      'p.unit',
      'p.min_stock as minStock',
      'p.current_qty as currentQty',
      'p.category_id as categoryId',
      'c.name as categoryName',
    )
    .orderBy('p.name', 'asc');

  if (search?.trim()) {
    q.andWhere('p.name', 'like', `%${search.trim()}%`);
  }
  const rows = await q;
  return rows.map((r) => ({
    ...r,
    minStock: Number(r.minStock),
    currentQty: Number(r.currentQty),
    stockStatus:
      Number(r.currentQty) <= 0 ? 'out' : Number(r.currentQty) <= Number(r.minStock) ? 'low' : 'ok',
  }));
}

export async function createProduct(
  shopId: number,
  data: { name: string; unit: Unit; minStock: number; categoryId?: number | null },
) {
  const [id] = await db('products').insert({
    shop_id: shopId,
    category_id: data.categoryId ?? null,
    name: data.name,
    unit: data.unit,
    min_stock: data.minStock,
    current_qty: 0,
  });
  return { id };
}

export async function updateProduct(
  shopId: number,
  id: number,
  data: Partial<{ name: string; unit: Unit; minStock: number; categoryId: number | null; isActive: boolean }>,
) {
  const existing = await db('products').where({ id, shop_id: shopId }).first();
  if (!existing) throw new AppError(404, 'NOT_FOUND', 'Product not found');

  await db('products')
    .where({ id })
    .update({
      name: data.name ?? existing.name,
      unit: data.unit ?? existing.unit,
      min_stock: data.minStock ?? existing.min_stock,
      category_id: data.categoryId === undefined ? existing.category_id : data.categoryId,
      is_active: data.isActive ?? existing.is_active,
      updated_at: db.fn.now(),
    });
  return { id };
}

export async function listCategories(shopId: number) {
  return db('categories').where({ shop_id: shopId }).select('id', 'name').orderBy('name');
}

export async function createCategory(shopId: number, name: string) {
  try {
    const [id] = await db('categories').insert({ shop_id: shopId, name });
    return { id, name };
  } catch {
    throw new AppError(409, 'CONFLICT', 'Category already exists');
  }
}

export async function dashboard(shopId: number) {
  const products = await listProducts(shopId);
  const lowStock = products.filter((p) => p.stockStatus !== 'ok');
  const recent = await db('stock_transactions as t')
    .join('products as p', 'p.id', 't.product_id')
    .join('users as u', 'u.id', 't.user_id')
    .where('t.shop_id', shopId)
    .select(
      't.id',
      'p.name as productName',
      'p.unit',
      't.type',
      't.quantity',
      't.stock_after as stockAfter',
      't.created_at as createdAt',
      'u.username as userName',
    )
    .orderBy('t.created_at', 'desc')
    .limit(10);

  return {
    totals: {
      products: products.length,
      lowStock: lowStock.filter((p) => p.stockStatus === 'low').length,
      outOfStock: lowStock.filter((p) => p.stockStatus === 'out').length,
    },
    lowStock,
    recent: recent.map((r) => ({
      ...r,
      quantity: Number(r.quantity),
      stockAfter: Number(r.stockAfter),
    })),
  };
}
