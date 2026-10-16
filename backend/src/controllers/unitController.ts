import { Response, NextFunction } from 'express';
import { z } from 'zod';
import { AuthedRequest, shopScope } from '../middleware/auth';
import * as unitService from '../services/unitService';

export async function list(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    res.json({ units: await unitService.listUnits(shopId) });
  } catch (e) {
    next(e);
  }
}

export async function create(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const body = z
      .object({
        name: z.string().min(1).max(80),
        symbol: z.string().min(1).max(32),
      })
      .strict()
      .parse(req.body);
    const unit = await unitService.createUnit(shopId, body.name, body.symbol);
    res.status(201).json(unit);
  } catch (e) {
    next(e);
  }
}
