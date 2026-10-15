import { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { AppError } from '../errors';
import { AuthUser, Role, isAdmin } from '../types';

export interface AuthedRequest extends Request {
  user?: AuthUser;
}

interface AccessPayload {
  sub: number;
  shop_id: number | null;
  role: Role;
  username: string;
  email: string;
}

export function requireAuth(req: AuthedRequest, _res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return next(new AppError(401, 'UNAUTHORIZED', 'Missing bearer token'));
  }
  try {
    const payload = jwt.verify(header.slice(7), config.jwt.accessSecret) as AccessPayload;
    req.user = {
      id: payload.sub,
      shopId: payload.shop_id,
      role: payload.role,
      username: payload.username,
      email: payload.email,
    };
    next();
  } catch {
    next(new AppError(401, 'UNAUTHORIZED', 'Invalid or expired token'));
  }
}

export function requireAdmin(req: AuthedRequest, _res: Response, next: NextFunction) {
  if (!req.user || !isAdmin(req.user.role)) {
    return next(new AppError(403, 'FORBIDDEN', 'Admin access required'));
  }
  next();
}

export function shopScope(user: AuthUser): number {
  if (user.shopId == null) {
    throw new AppError(403, 'FORBIDDEN', 'User is not assigned to a shop');
  }
  return user.shopId;
}
