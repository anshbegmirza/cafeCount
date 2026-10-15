import ExcelJS from 'exceljs';
import PDFDocument from 'pdfkit';
import { PassThrough } from 'stream';
import { listProducts } from './productService';
import { listHistory } from './stockService';

export async function inventoryExcel(shopId: number): Promise<Buffer> {
  const products = await listProducts(shopId);
  const wb = new ExcelJS.Workbook();
  const sheet = wb.addWorksheet('Inventory');
  sheet.columns = [
    { header: 'Name', key: 'name', width: 28 },
    { header: 'Category', key: 'categoryName', width: 18 },
    { header: 'Unit', key: 'unit', width: 10 },
    { header: 'Qty', key: 'currentQty', width: 12 },
    { header: 'Min', key: 'minStock', width: 12 },
    { header: 'Status', key: 'stockStatus', width: 10 },
  ];
  products.forEach((p) => sheet.addRow(p));
  const buf = await wb.xlsx.writeBuffer();
  return Buffer.from(buf);
}

export async function inventoryPdf(shopId: number): Promise<Buffer> {
  const products = await listProducts(shopId);
  const history = await listHistory(shopId, 20);

  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ margin: 40 });
    const stream = new PassThrough();
    const chunks: Buffer[] = [];
    stream.on('data', (c) => chunks.push(c as Buffer));
    stream.on('end', () => resolve(Buffer.concat(chunks)));
    stream.on('error', reject);
    doc.pipe(stream);

    doc.fontSize(18).text('CafeCount Inventory Report', { underline: true });
    doc.moveDown();
    doc.fontSize(12).text(`Generated: ${new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' })}`);
    doc.moveDown();

    products.forEach((p) => {
      doc.text(
        `${p.name} — ${p.currentQty} ${p.unit} (min ${p.minStock}) [${p.stockStatus}]`,
      );
    });

    doc.moveDown().fontSize(14).text('Recent transactions', { underline: true });
    doc.fontSize(11);
    history.forEach((h) => {
      doc.text(
        `${h.createdAt} | ${h.type} | ${h.productName} | qty ${h.quantity} | by ${h.userName}`,
      );
    });

    doc.end();
  });
}
