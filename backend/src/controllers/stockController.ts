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
    const q = z
      .object({
        limit: z.coerce.number().int().positive().max(500).optional(),
        productId: z.coerce.number().int().positive().optional(),
        from: z.string().min(1).optional(),
        to: z.string().min(1).optional(),
      })
      .parse(req.query);
    const from = q.from ? new Date(q.from) : undefined;
    const to = q.to ? new Date(q.to) : undefined;
    if ((from && Number.isNaN(from.getTime())) || (to && Number.isNaN(to.getTime()))) {
      return res.status(400).json({
        error: { code: 'VALIDATION_ERROR', message: 'Invalid from/to date', details: {} },
      });
    }
    res.json({
      transactions: await stockService.listHistory(shopId, q.limit ?? 50, q.productId, from, to),
    });
  } catch (e) {
    next(e);
  }
}
