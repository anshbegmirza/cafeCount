import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { db } from '../db';
import { AppError } from '../errors';
import { AuthUser, Role } from '../types';

function hashToken(token: string) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

function signAccess(user: AuthUser) {
  return jwt.sign(
    {
      sub: user.id,
      shop_id: user.shopId,
      role: user.role,
      username: user.username,
      email: user.email,
    },
    config.jwt.accessSecret,
    { expiresIn: config.jwt.accessExpires as jwt.SignOptions['expiresIn'] },
  );
}

function signRefresh(userId: number) {
  return jwt.sign({ sub: userId, typ: 'refresh' }, config.jwt.refreshSecret, {
    expiresIn: config.jwt.refreshExpires as jwt.SignOptions['expiresIn'],
  });
}

async function storeRefresh(userId: number, refreshToken: string) {
  const decoded = jwt.decode(refreshToken) as { exp?: number };
  const expiresAt = decoded?.exp
    ? new Date(decoded.exp * 1000)
    : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
  await db('refresh_tokens').insert({
    user_id: userId,
    token_hash: hashToken(refreshToken),
    expires_at: expiresAt,
  });
}

function mapUser(row: {
  id: number;
  shop_id: number | null;
  role: Role;
  username: string;
  email: string;
}): AuthUser {
  return {
    id: row.id,
    shopId: row.shop_id,
    role: row.role,
    username: row.username,
    email: row.email,
  };
}

export async function login(identifier: string, password: string) {
  const row = await db('users')
    .where({ username: identifier })
    .orWhere({ email: identifier })
    .first();

  if (!row || !row.is_active) {
    throw new AppError(401, 'INVALID_CREDENTIALS', 'Invalid username/email or password');
  }

  const ok = await bcrypt.compare(password, row.password_hash);
  if (!ok) {
    throw new AppError(401, 'INVALID_CREDENTIALS', 'Invalid username/email or password');
  }

  const user = mapUser(row);
  const accessToken = signAccess(user);
  const refreshToken = signRefresh(user.id);
  await storeRefresh(user.id, refreshToken);

  return { user, accessToken, refreshToken };
}

export async function refresh(refreshToken: string) {
  let payload: { sub: number; typ?: string };
  try {
    payload = jwt.verify(refreshToken, config.jwt.refreshSecret) as unknown as { sub: number; typ?: string };
  } catch {
    throw new AppError(401, 'UNAUTHORIZED', 'Invalid refresh token');
  }

  const tokenHash = hashToken(refreshToken);
  const stored = await db('refresh_tokens').where({ token_hash: tokenHash }).first();
  if (!stored || new Date(stored.expires_at) < new Date()) {
    throw new AppError(401, 'UNAUTHORIZED', 'Refresh token expired or revoked');
  }

  await db('refresh_tokens').where({ id: stored.id }).del();

  const row = await db('users').where({ id: payload.sub, is_active: true }).first();
  if (!row) throw new AppError(401, 'UNAUTHORIZED', 'User not found');

  const user = mapUser(row);
  const accessToken = signAccess(user);
  const newRefresh = signRefresh(user.id);
  await storeRefresh(user.id, newRefresh);
  return { user, accessToken, refreshToken: newRefresh };
}

export async function logout(refreshToken?: string) {
  if (!refreshToken) return;
  await db('refresh_tokens').where({ token_hash: hashToken(refreshToken) }).del();
}

export async function getMe(userId: number) {
  const row = await db('users').where({ id: userId }).first();
  if (!row) throw new AppError(404, 'NOT_FOUND', 'User not found');
  return mapUser(row);
}
