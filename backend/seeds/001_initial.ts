import type { Knex } from 'knex';
import bcrypt from 'bcryptjs';

/** Local/demo seed passwords. Share privately; rotate after client review. */
export const SEED_PASSWORDS = {
  superadmin: 'test123',
  shopadmin: 'test123',
  employee: 'test123',
} as const;

const DEFAULT_UNITS: { name: string; symbol: string }[] = [
  { name: 'Pieces', symbol: 'pcs' },
  { name: 'Kilogram', symbol: 'kg' },
  { name: 'Gram', symbol: 'g' },
  { name: 'Litre', symbol: 'L' },
  { name: 'Bottles', symbol: 'bottles' },
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
}
