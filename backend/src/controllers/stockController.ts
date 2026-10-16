import { Response, NextFunction } from 'express';
import { z } from 'zod';
import { AuthedRequest, shopScope } from '../middleware/auth';
import * as stockService from '../services/stockService';

export async function add(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const body = z
      .object({
        productId: z.coerce.number().int().positive(),
        quantity: z.coerce.number().positive(),
        note: z.string().max(255).optional(),
      })
      .parse(req.body);
    res.status(201).json(await stockService.addStock(shopId, body.productId, req.user!.id, body.quantity, body.note));
  } catch (e) {
    next(e);
  }
}

export async function withdraw(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const body = z
      .object({
        productId: z.coerce.number().int().positive(),
        quantity: z.coerce.number().positive(),
        note: z.string().max(255).optional(),
      })
      .parse(req.body);
    res
      .status(201)
      .json(await stockService.withdrawStock(shopId, body.productId, req.user!.id, body.quantity, body.note));
  } catch (e) {
    next(e);
  }
}

export async function adjust(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const body = z
      .object({
        productId: z.number().int().positive(),
        newQty: z.number().min(0),
        note: z.string().max(255).optional(),
      })
      .parse(req.body);
    res
      .status(201)
      .json(await stockService.adjustStock(shopId, body.productId, req.user!.id, body.newQty, body.note));
  } catch (e) {
    next(e);
  }
}

export async function history(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const limit = req.query.limit ? Number(req.query.limit) : 50;
    const productId = req.query.productId ? Number(req.query.productId) : undefined;
    res.json({ transactions: await stockService.listHistory(shopId, limit, productId) });
  } catch (e) {
    next(e);
  }
}
