import type { Knex } from 'knex';
import bcrypt from 'bcryptjs';

/** Locked owner account — never editable via staff APIs. */
const SUPERUSER = {
  username: 'superuser',
  email: 'captainmaverick010@gmail.com',
  password: '123!Test',
  role: 'super_admin',
} as const;

export async function up(knex: Knex): Promise<void> {
  const shop = await knex('shops').orderBy('id').first();
  if (!shop) return;

  const passwordHash = await bcrypt.hash(SUPERUSER.password, 12);
  const existing = await knex('users').where({ username: SUPERUSER.username }).first();

  if (existing) {
    await knex('users').where({ id: existing.id }).update({
      email: SUPERUSER.email,
      password_hash: passwordHash,
      role: SUPERUSER.role,
      is_active: true,
      shop_id: shop.id,
      updated_at: knex.fn.now(),
    });
    return;
  }

  await knex('users').insert({
    shop_id: shop.id,
    username: SUPERUSER.username,
    email: SUPERUSER.email,
    password_hash: passwordHash,
    role: SUPERUSER.role,
    is_active: true,
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex('users').where({ username: SUPERUSER.username }).del();
}
