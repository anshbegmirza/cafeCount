import type { Knex } from 'knex';
import bcrypt from 'bcryptjs';

/** Temp seed passwords for local/demo — change before any real deploy. */
export const SEED_PASSWORDS = {
  superadmin: 'super@123',
  shopadmin: 'test123',
  employee: 'EmpTest123',
} as const;

type TxType = 'add' | 'withdraw' | 'adjust';

type ProductSeed = {
  name: string;
  unit: 'pcs' | 'kg' | 'g' | 'L' | 'bottles' | 'boxes';
  min_stock: number;
  opening: number;
  category: string;
};

const PRODUCTS: ProductSeed[] = [
  { name: 'Espresso Beans', unit: 'kg', min_stock: 2, opening: 12, category: 'Coffee' },
  { name: 'Filter Coffee', unit: 'kg', min_stock: 1.5, opening: 8, category: 'Coffee' },
  { name: 'Decaf Beans', unit: 'kg', min_stock: 1, opening: 4, category: 'Coffee' },
  { name: 'Whole Milk', unit: 'L', min_stock: 8, opening: 40, category: 'Dairy' },
  { name: 'Oat Milk', unit: 'L', min_stock: 4, opening: 20, category: 'Dairy' },
  { name: 'Almond Milk', unit: 'L', min_stock: 2, opening: 10, category: 'Dairy' },
  { name: 'Vanilla Syrup', unit: 'bottles', min_stock: 2, opening: 8, category: 'Syrups' },
  { name: 'Caramel Syrup', unit: 'bottles', min_stock: 2, opening: 6, category: 'Syrups' },
  { name: 'Hazelnut Syrup', unit: 'bottles', min_stock: 1, opening: 4, category: 'Syrups' },
  { name: 'Chocolate Sauce', unit: 'bottles', min_stock: 1, opening: 5, category: 'Syrups' },
  { name: 'Paper Cups 8oz', unit: 'pcs', min_stock: 100, opening: 500, category: 'Packaging' },
  { name: 'Paper Cups 12oz', unit: 'pcs', min_stock: 100, opening: 600, category: 'Packaging' },
  { name: 'Lids', unit: 'pcs', min_stock: 150, opening: 800, category: 'Packaging' },
  { name: 'Napkins', unit: 'boxes', min_stock: 2, opening: 10, category: 'Packaging' },
  { name: 'Sugar Packets', unit: 'boxes', min_stock: 1, opening: 6, category: 'Packaging' },
  { name: 'Croissant Dough', unit: 'pcs', min_stock: 10, opening: 40, category: 'Pastry' },
];

function daysAgo(n: number): Date {
  const d = new Date();
  d.setHours(9, 0, 0, 0);
  d.setDate(d.getDate() - n);
  return d;
}

function atOffset(base: Date, hourOffset: number): Date {
  const d = new Date(base);
  d.setHours(d.getHours() + hourOffset, (d.getMinutes() + Math.abs(hourOffset) * 7) % 60, 0, 0);
  return d;
}

function round3(n: number): number {
  return Math.round(n * 1000) / 1000;
}

const DEFAULT_UNITS: { name: string; symbol: string }[] = [
  { name: 'Pieces', symbol: 'pcs' },
  { name: 'Kilogram', symbol: 'kg' },
  { name: 'Gram', symbol: 'g' },
  { name: 'Litre', symbol: 'L' },
  { name: 'Bottles', symbol: 'bottles' },
  { name: 'Boxes', symbol: 'boxes' },
];

export async function seed(knex: Knex): Promise<void> {
  await knex('stock_transactions').del();
  await knex('products').del();
  await knex('units').del();
  await knex('categories').del();
  await knex('refresh_tokens').del();
  await knex('users').del();
  await knex('shops').del();

  const [shopId] = await knex('shops').insert({
    name: 'Hidden Room',
    status: 'active',
  });

  await knex('units').insert(DEFAULT_UNITS.map((u) => ({ shop_id: shopId, ...u })));

  const hash = async (p: string) => bcrypt.hash(p, 12);

  await knex('users').insert([
    {
      shop_id: shopId,
      username: 'superadmin',
      email: 'superadmin@cafecount.local',
      password_hash: await hash(SEED_PASSWORDS.superadmin),
      role: 'super_admin',
    },
    {
      shop_id: shopId,
      username: 'shopadmin',
      email: 'shopadmin@cafecount.local',
      password_hash: await hash(SEED_PASSWORDS.shopadmin),
      role: 'shop_admin',
    },
    {
      shop_id: shopId,
      username: 'employee',
      email: 'employee@cafecount.local',
      password_hash: await hash(SEED_PASSWORDS.employee),
      role: 'employee',
    },
  ]);

  const users = await knex('users').where({ shop_id: shopId }).select('id', 'username');
  const adminId = users.find((u) => u.username === 'shopadmin')!.id as number;
  const empId = users.find((u) => u.username === 'employee')!.id as number;

  const catNames = [...new Set(PRODUCTS.map((p) => p.category))];
  const catIds = new Map<string, number>();
  for (const name of catNames) {
    const [id] = await knex('categories').insert({ shop_id: shopId, name });
    catIds.set(name, id);
  }

  const qtyByKey = new Map<string, number>();
  const productIds = new Map<string, number>();

  for (const p of PRODUCTS) {
    const [id] = await knex('products').insert({
      shop_id: shopId,
      category_id: catIds.get(p.category)!,
      name: p.name,
      unit: p.unit,
      min_stock: p.min_stock,
      current_qty: 0,
    });
    productIds.set(p.name, id);
    qtyByKey.set(p.name, 0);
  }

  type TxRow = {
    shop_id: number;
    product_id: number;
    user_id: number;
    type: TxType;
    quantity: number;
    stock_before: number;
    stock_after: number;
    note: string | null;
    created_at: Date;
  };

  const txs: TxRow[] = [];

  const pushTx = (
    name: string,
    type: TxType,
    quantity: number,
    userId: number,
    when: Date,
    note: string | null,
  ) => {
    if (type !== 'adjust' && quantity <= 0) return;

    const before = qtyByKey.get(name)!;
    let after = before;
    if (type === 'add') after = round3(before + quantity);
    else if (type === 'withdraw') after = round3(before - quantity);
    else after = round3(quantity);

    if (type === 'withdraw' && after < 0) return;

    const qtyLogged = type === 'adjust' ? Math.abs(round3(after - before)) : quantity;
    if (type === 'adjust' && qtyLogged === 0) return;

    qtyByKey.set(name, after);
    txs.push({
      shop_id: shopId,
      product_id: productIds.get(name)!,
      user_id: userId,
      type,
      quantity: qtyLogged,
      stock_before: before,
      stock_after: after,
      note,
      created_at: when,
    });
  };

  const openDay = daysAgo(30);
  for (const p of PRODUCTS) {
    pushTx(p.name, 'add', p.opening, adminId, atOffset(openDay, 0), 'Opening stock');
  }

  for (let day = 29; day >= 0; day--) {
    const d = daysAgo(day);
    const isWeekend = d.getDay() === 0 || d.getDay() === 6;
    const isDeliveryDay = d.getDay() === 1 || d.getDay() === 4;
    const busy = isWeekend ? 1.25 : 1;

    if (isDeliveryDay) {
      pushTx('Espresso Beans', 'add', 5, adminId, atOffset(d, -1), 'Supplier delivery');
      pushTx('Filter Coffee', 'add', 3, adminId, atOffset(d, -1), 'Supplier delivery');
      pushTx('Whole Milk', 'add', 40, adminId, atOffset(d, -1), 'Dairy delivery');
      pushTx('Oat Milk', 'add', 15, adminId, atOffset(d, -1), 'Dairy delivery');
      pushTx('Almond Milk', 'add', 8, adminId, atOffset(d, -1), 'Dairy delivery');
      pushTx('Paper Cups 8oz', 'add', 400, adminId, atOffset(d, -1), 'Packaging order');
      pushTx('Paper Cups 12oz', 'add', 500, adminId, atOffset(d, -1), 'Packaging order');
      pushTx('Lids', 'add', 600, adminId, atOffset(d, -1), 'Packaging order');
      pushTx('Croissant Dough', 'add', 30, adminId, atOffset(d, -1), 'Bakery order');
      if (day % 14 < 7) {
        pushTx('Vanilla Syrup', 'add', 4, adminId, atOffset(d, -1), 'Syrup restock');
        pushTx('Caramel Syrup', 'add', 3, adminId, atOffset(d, -1), 'Syrup restock');
        pushTx('Chocolate Sauce', 'add', 3, adminId, atOffset(d, -1), 'Syrup restock');
      }
    }

    pushTx('Espresso Beans', 'withdraw', round3(0.45 * busy), empId, atOffset(d, 0), 'Morning brew');
    pushTx('Filter Coffee', 'withdraw', round3(0.25 * busy), empId, atOffset(d, 0), 'Batch brew');
    if (day % 5 === 0) pushTx('Decaf Beans', 'withdraw', 0.15, empId, atOffset(d, 0), 'Decaf');

    pushTx('Whole Milk', 'withdraw', round3(5 * busy), empId, atOffset(d, 1), 'Service');
    pushTx('Oat Milk', 'withdraw', round3(2 * busy), empId, atOffset(d, 1), 'Alt milk');
    if (day % 3 === 0) pushTx('Almond Milk', 'withdraw', 1, empId, atOffset(d, 1), 'Alt milk');

    pushTx('Paper Cups 8oz', 'withdraw', Math.round(45 * busy), empId, atOffset(d, 1), null);
    pushTx('Paper Cups 12oz', 'withdraw', Math.round(60 * busy), empId, atOffset(d, 1), null);
    pushTx('Lids', 'withdraw', Math.round(90 * busy), empId, atOffset(d, 1), null);

    if (day % 2 === 0) pushTx('Croissant Dough', 'withdraw', Math.round(8 * busy), empId, atOffset(d, 2), 'Pastry');
    if (day % 4 === 0) pushTx('Napkins', 'withdraw', 1, empId, atOffset(d, 2), null);
    if (day % 7 === 0) pushTx('Sugar Packets', 'withdraw', 1, empId, atOffset(d, 2), null);

    pushTx('Espresso Beans', 'withdraw', round3(0.35 * busy), empId, atOffset(d, 5), 'Afternoon');
    pushTx('Whole Milk', 'withdraw', round3(3 * busy), empId, atOffset(d, 5), 'Afternoon');
    if (day % 3 === 0) pushTx('Chocolate Sauce', 'withdraw', 1, empId, atOffset(d, 5), 'Mocha');

    if (day % 6 === 0) pushTx('Vanilla Syrup', 'withdraw', 1, empId, atOffset(d, 3), 'New bottle');
    if (day % 8 === 0) pushTx('Caramel Syrup', 'withdraw', 1, empId, atOffset(d, 3), 'New bottle');
    if (day % 10 === 0) pushTx('Hazelnut Syrup', 'withdraw', 1, empId, atOffset(d, 3), 'New bottle');

    if (d.getDay() === 3 && day < 28) {
      const milk = qtyByKey.get('Whole Milk')!;
      pushTx('Whole Milk', 'adjust', round3(Math.max(0, milk - 0.5)), adminId, atOffset(d, 8), 'Weekly count variance');
    }
  }

  // Leave a couple of items near low-stock for dashboard testing
  const cups = qtyByKey.get('Paper Cups 8oz')!;
  if (cups > 80) {
    pushTx('Paper Cups 8oz', 'withdraw', cups - 60, empId, atOffset(daysAgo(0), 6), 'Busy evening');
  }
  const almond = qtyByKey.get('Almond Milk')!;
  if (almond > 1) {
    pushTx('Almond Milk', 'withdraw', almond - 1, empId, atOffset(daysAgo(1), 4), 'Low stock path');
  }

  if (txs.length) {
    await knex.batchInsert('stock_transactions', txs, 100);
  }

  for (const p of PRODUCTS) {
    await knex('products')
      .where({ id: productIds.get(p.name)! })
      .update({ current_qty: qtyByKey.get(p.name)! });
  }
}
