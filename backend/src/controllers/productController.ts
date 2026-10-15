import { Response, NextFunction } from 'express';
import { z } from 'zod';
import { AuthedRequest, shopScope } from '../middleware/auth';
import * as productService from '../services/productService';

const unitEnum = z.enum(['pcs', 'kg', 'g', 'L', 'bottles', 'boxes']);

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
        unit: unitEnum,
        minStock: z.number().min(0),
        categoryId: z.number().int().positive().nullable().optional(),
      })
      .parse(req.body);
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
        unit: unitEnum.optional(),
        minStock: z.number().min(0).optional(),
        categoryId: z.number().int().positive().nullable().optional(),
        isActive: z.boolean().optional(),
      })
      .parse(req.body);
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
