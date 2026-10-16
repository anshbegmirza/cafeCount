import { Response, NextFunction } from 'express';
import { AuthedRequest, shopScope } from '../middleware/auth';
import * as reportService from '../services/reportService';

export async function excel(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const buf = await reportService.inventoryExcel(shopId);
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename="hidden-room-inventory.xlsx"');
    res.send(buf);
  } catch (e) {
    next(e);
  }
}

export async function pdf(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const shopId = shopScope(req.user!);
    const buf = await reportService.inventoryPdf(shopId);
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'attachment; filename="hidden-room-inventory.pdf"');
    res.send(buf);
  } catch (e) {
    next(e);
  }
}
