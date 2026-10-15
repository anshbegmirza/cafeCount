import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import * as authController from '../controllers/authController';
import * as productController from '../controllers/productController';
import * as stockController from '../controllers/stockController';
import * as userController from '../controllers/userController';
import * as reportController from '../controllers/reportController';
import { requireAuth, requireAdmin } from '../middleware/auth';

export const v1 = Router();

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
});

v1.post('/auth/login', loginLimiter, authController.login);
v1.post('/auth/refresh', authController.refresh);
v1.post('/auth/logout', authController.logout);
v1.get('/auth/me', requireAuth, authController.me);

v1.get('/dashboard', requireAuth, productController.dashboard);

v1.get('/products', requireAuth, productController.list);
v1.post('/products', requireAuth, requireAdmin, productController.create);
v1.patch('/products/:id', requireAuth, requireAdmin, productController.update);

v1.get('/categories', requireAuth, productController.categories);
v1.post('/categories', requireAuth, requireAdmin, productController.createCategory);

v1.post('/stock/add', requireAuth, requireAdmin, stockController.add);
v1.post('/stock/withdraw', requireAuth, stockController.withdraw);
v1.post('/stock/adjust', requireAuth, requireAdmin, stockController.adjust);
v1.get('/stock/history', requireAuth, stockController.history);

v1.get('/users', requireAuth, requireAdmin, userController.list);
v1.post('/users', requireAuth, requireAdmin, userController.create);
v1.patch('/users/:id/active', requireAuth, requireAdmin, userController.setActive);

v1.get('/reports/inventory.xlsx', requireAuth, requireAdmin, reportController.excel);
v1.get('/reports/inventory.pdf', requireAuth, requireAdmin, reportController.pdf);

v1.get('/health', (_req, res) => res.json({ ok: true, app: 'CafeCount' }));
