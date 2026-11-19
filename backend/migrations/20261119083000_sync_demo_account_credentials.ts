import type { Knex } from 'knex';
import bcrypt from 'bcryptjs';

/** Keep in sync with docs/SEED_CREDENTIALS.md + seeds/001_initial.ts */
const ACCOUNTS = [
  {
    username: 'superuser',
    email: 'captainmaverick010@gmail.com',
    password: '123!Test',
    role: 'super_admin',
  },
  {
    username: 'superadmin',
    email: 'superadmin@cafecount.local',
    password: 'SuperAdmin@123',
    role: 'super_admin',
  },
  {
    username: 'shopadmin',
    email: 'shopadmin@cafecount.local',
    password: 'ShopAdmin@123',
    role: 'shop_admin',
  },
  {
    username: 'employee',
    email: 'employee@cafecount.local',
    password: 'emp@123!',
    role: 'employee',
  },
] as const;

export async function up(knex: Knex): Promise<void> {
  const shop = await knex('shops').orderBy('id').first();
  if (!shop) return;

  for (const acct of ACCOUNTS) {
    const passwordHash = await bcrypt.hash(acct.password, 12);
    const existing = await knex('users').where({ username: acct.username }).first();
    if (existing) {
      await knex('users').where({ id: existing.id }).update({
        email: acct.email,
        password_hash: passwordHash,
        role: acct.role,
        is_active: true,
        shop_id: shop.id,
        updated_at: knex.fn.now(),
      });
    } else {
      await knex('users').insert({
        shop_id: shop.id,
        username: acct.username,
        email: acct.email,
        password_hash: passwordHash,
        role: acct.role,
        is_active: true,
      });
    }
  }
}

export async function down(_knex: Knex): Promise<void> {
  // Passwords are not rolled back (hashes are one-way).
}
