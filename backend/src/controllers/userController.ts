import { Response, NextFunction } from 'express';
import { z } from 'zod';
import { AuthedRequest, shopScope } from '../middleware/auth';
import * as userService from '../services/userService';

export async function list(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    res.json({ users: await userService.listUsers(shopId) });
  } catch (e) {
    next(e);
  }
}

export async function create(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const body = z
      .object({
        username: z.string().min(3).max(80),
        email: z.string().email(),
        password: z
          .string()
          .min(8)
          .regex(/[A-Za-z]/, 'Password must include a letter')
          .regex(/[0-9]/, 'Password must include a number')
          .regex(/[^A-Za-z0-9]/, 'Password must include a special character'),
        role: z.enum(['shop_admin', 'employee']),
      })
      .parse(req.body);
    res.status(201).json(await userService.createUser(shopId, body));
  } catch (e) {
    next(e);
  }
}

export async function setActive(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const id = Number(req.params.id);
    const { isActive } = z.object({ isActive: z.boolean() }).parse(req.body);
    res.json(await userService.setUserActive(shopId, id, isActive));
  } catch (e) {
    next(e);
  }
}

export async function setPassword(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const id = Number(req.params.id);
    const { password } = z
      .object({
        password: z
          .string()
          .min(8)
          .regex(/[A-Za-z]/, 'Password must include a letter')
          .regex(/[0-9]/, 'Password must include a number')
          .regex(/[^A-Za-z0-9]/, 'Password must include a special character'),
      })
      .parse(req.body);
    res.json(await userService.setUserPassword(shopId, id, password, req.user!.role));
  } catch (e) {
    next(e);
  }
}
