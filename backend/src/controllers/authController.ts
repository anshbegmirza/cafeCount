import { Response, NextFunction } from 'express';
import { z } from 'zod';
import { AuthedRequest } from '../middleware/auth';
import * as authService from '../services/authService';

const loginSchema = z.object({
  identifier: z.string().min(1),
  password: z.string().min(1),
});

export async function login(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const body = loginSchema.parse(req.body);
    const result = await authService.login(body.identifier, body.password);
    res.json(result);
  } catch (e) {
    next(e);
  }
}

export async function refresh(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const token = z.object({ refreshToken: z.string().min(1) }).parse(req.body).refreshToken;
    const result = await authService.refresh(token);
    res.json(result);
  } catch (e) {
    next(e);
  }
}

export async function logout(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const token = typeof req.body?.refreshToken === 'string' ? req.body.refreshToken : undefined;
    await authService.logout(token);
    res.status(204).send();
  } catch (e) {
    next(e);
  }
}

export async function me(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const user = await authService.getMe(req.user!.id);
    res.json({ user });
  } catch (e) {
    next(e);
  }
}
