import bcrypt from 'bcryptjs';
import { db } from '../db';
import { AppError } from '../errors';
import { Role } from '../types';

export async function listUsers(shopId: number) {
  return db('users')
    .where({ shop_id: shopId })
    .select('id', 'username', 'email', 'role', 'is_active as isActive', 'created_at as createdAt')
    .orderBy('username');
}

export async function createUser(
  shopId: number,
  data: { username: string; email: string; password: string; role: Role },
) {
  if (data.role === 'super_admin') {
    throw new AppError(403, 'FORBIDDEN', 'Cannot create super_admin via this endpoint');
  }
  if (data.password.length < 8) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Password must be at least 8 characters');
  }
  try {
    const [id] = await db('users').insert({
      shop_id: shopId,
      username: data.username,
      email: data.email,
      password_hash: await bcrypt.hash(data.password, 12),
      role: data.role,
    });
    return { id };
  } catch {
    throw new AppError(409, 'CONFLICT', 'Username or email already exists');
  }
}

export async function setUserActive(shopId: number, userId: number, isActive: boolean) {
  const user = await db('users').where({ id: userId, shop_id: shopId }).first();
  if (!user) throw new AppError(404, 'NOT_FOUND', 'User not found');
  if (user.role === 'super_admin') {
    throw new AppError(403, 'FORBIDDEN', 'Cannot deactivate super_admin');
  }
  await db('users').where({ id: userId }).update({ is_active: isActive, updated_at: db.fn.now() });
  return { id: userId, isActive };
}
