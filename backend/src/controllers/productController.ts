import { Response, NextFunction } from 'express';
import { z } from 'zod';
import { AuthedRequest, shopScope } from '../middleware/auth';
import * as productService from '../services/productService';
import * as unitService from '../services/unitService';

const unitSymbol = z.string().min(1).max(32);

export async function list(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const search = typeof req.query.q === 'string' ? req.query.q : undefined;
    res.json({ products: await productService.listProducts(shopId, search) });
  } catch (e) {
    next(e);
  }
}

export async function create(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const body = z
      .object({
        name: z.string().min(1).max(160),
        unit: unitSymbol,
        minStock: z.number().min(0),
        categoryId: z.number().int().positive().nullable().optional(),
      })
      .strict()
      .parse(req.body);
    await unitService.assertUnitSymbol(shopId, body.unit);
    const result = await productService.createProduct(shopId, body);
    res.status(201).json(result);
  } catch (e) {
    next(e);
  }
}

export async function update(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const id = Number(req.params.id);
    const body = z
      .object({
        name: z.string().min(1).max(160).optional(),
        unit: unitSymbol.optional(),
        minStock: z.number().min(0).optional(),
        categoryId: z.number().int().positive().nullable().optional(),
        isActive: z.boolean().optional(),
      })
      .strict()
      .parse(req.body);
    if (body.unit) await unitService.assertUnitSymbol(shopId, body.unit);
    res.json(await productService.updateProduct(shopId, id, body));
  } catch (e) {
    next(e);
  }
}

export async function categories(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    res.json({ categories: await productService.listCategories(shopId) });
  } catch (e) {
    next(e);
  }
}

export async function createCategory(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const { name } = z.object({ name: z.string().min(1).max(120) }).parse(req.body);
    res.status(201).json(await productService.createCategory(shopId, name));
  } catch (e) {
    next(e);
  }
}

export async function dashboard(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    res.json(await productService.dashboard(shopId));
  } catch (e) {
    next(e);
  }
}
