import type { Knex } from 'knex';
import bcrypt from 'bcryptjs';

/** Local/demo seed passwords. Keep in sync with docs/SEED_CREDENTIALS.md. */
export const SEED_PASSWORDS = {
  superuser: '123!Test',
  superadmin: 'SuperAdmin@123',
  shopadmin: 'ShopAdmin@123',
  employee: 'emp@123!',
} as const;

const DEFAULT_UNITS: { name: string; symbol: string }[] = [
  { name: 'Pieces', symbol: 'pcs' },
  { name: 'Kilogram', symbol: 'kg' },
  { name: 'Gram', symbol: 'g' },
  { name: 'Litre', symbol: 'L' },
  { name: 'Bottles', symbol: 'bottles' },
];

const DEFAULT_CATEGORIES = [
  'Coffee beans',
  'Dairy',
  'Syrups',
  'Cups & lids',
  'Cleaning',
] as const;

/** Demo inventory — names stay English (i18n rule). */
const DEFAULT_PRODUCTS: {
  name: string;
  category: (typeof DEFAULT_CATEGORIES)[number];
  unit: 'pcs' | 'kg' | 'g' | 'L' | 'bottles';
  minStock: number;
  currentQty: number;
}[] = [
  { name: 'Arabica beans', category: 'Coffee beans', unit: 'kg', minStock: 2, currentQty: 12 },
  { name: 'Whole milk', category: 'Dairy', unit: 'L', minStock: 5, currentQty: 18 },
  { name: 'Vanilla syrup', category: 'Syrups', unit: 'bottles', minStock: 2, currentQty: 6 },
  { name: 'Paper cups 12oz', category: 'Cups & lids', unit: 'pcs', minStock: 100, currentQty: 450 },
  { name: 'Surface cleaner', category: 'Cleaning', unit: 'bottles', minStock: 1, currentQty: 3 },
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
    name: 'Stock Room',
    status: 'active',
  });

  await knex('units').insert(DEFAULT_UNITS.map((u) => ({ shop_id: shopId, ...u })));

  const categoryIds = new Map<string, number>();
  for (const name of DEFAULT_CATEGORIES) {
    const [id] = await knex('categories').insert({ shop_id: shopId, name });
    categoryIds.set(name, id);
  }

  await knex('products').insert(
    DEFAULT_PRODUCTS.map((p) => ({
      shop_id: shopId,
      category_id: categoryIds.get(p.category) ?? null,
      name: p.name,
      unit: p.unit,
      min_stock: p.minStock,
      current_qty: p.currentQty,
      is_active: true,
    })),
  );

  const hash = async (p: string) => bcrypt.hash(p, 12);

  await knex('users').insert([
    {
      shop_id: shopId,
      username: 'superuser',
      email: 'captainmaverick010@gmail.com',
      password_hash: await hash(SEED_PASSWORDS.superuser),
      role: 'super_admin',
    },
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
}
