import ExcelJS from 'exceljs';
import PDFDocument from 'pdfkit';
import { PassThrough } from 'stream';
import { listProducts } from './productService';

const FOREST = '#212621';
const CREAM = '#E6E3DB';
const MUTED = '#666666';
const RULE = '#D0D0D0';

function exportDateLabel(): string {
  return new Date().toLocaleDateString('en-GB', { timeZone: 'Asia/Kolkata' });
}

function fmtQty(n: unknown): string {
  const v = Number(n);
  if (!Number.isFinite(v)) return String(n ?? '');
  if (Number.isInteger(v)) return String(v);
  return String(parseFloat(v.toFixed(3)));
}

export async function inventoryExcel(shopId: number): Promise<Buffer> {
  const products = await listProducts(shopId);
  const wb = new ExcelJS.Workbook();
  wb.creator = 'Hidden Room';
  const sheet = wb.addWorksheet('Inventory');

  sheet.mergeCells('A1:F1');
  const title = sheet.getCell('A1');
  title.value = 'Hidden Room';
  title.font = { bold: true, size: 14, color: { argb: 'FFE6E3DB' } };
  title.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF212621' } };
  title.alignment = { vertical: 'middle', horizontal: 'left', indent: 1 };
  sheet.getRow(1).height = 28;

  sheet.getCell('A2').value = `Export date: ${exportDateLabel()}`;
  sheet.getCell('A2').font = { size: 11, color: { argb: 'FF666666' } };

  sheet.getCell('A3').value = 'Stock Inventory Report';
  sheet.getCell('A3').font = { bold: true, size: 12, color: { argb: 'FF212621' } };

  const headerRow = sheet.getRow(5);
  const headers = ['Name', 'Category', 'Unit', 'Qty', 'Min', 'Status'];
  headers.forEach((h, i) => {
    const cell = headerRow.getCell(i + 1);
    cell.value = h;
    cell.font = { bold: true, color: { argb: 'FF212621' } };
    cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFE6E3DB' } };
    cell.border = {
      top: { style: 'thin', color: { argb: 'FFD0D0D0' } },
      left: { style: 'thin', color: { argb: 'FFD0D0D0' } },
      bottom: { style: 'thin', color: { argb: 'FFD0D0D0' } },
      right: { style: 'thin', color: { argb: 'FFD0D0D0' } },
    };
  });

  products.forEach((p, idx) => {
    const row = sheet.getRow(6 + idx);
    const values = [
      p.name,
      p.categoryName ?? '',
      p.unit,
      Number(p.currentQty),
      Number(p.minStock),
      p.stockStatus,
    ];
    values.forEach((v, i) => {
      const cell = row.getCell(i + 1);
      cell.value = v as ExcelJS.CellValue;
      cell.border = {
        top: { style: 'thin', color: { argb: 'FFD0D0D0' } },
        left: { style: 'thin', color: { argb: 'FFD0D0D0' } },
        bottom: { style: 'thin', color: { argb: 'FFD0D0D0' } },
        right: { style: 'thin', color: { argb: 'FFD0D0D0' } },
      };
    });
  });

  sheet.columns = [
    { key: 'name', width: 28 },
    { key: 'category', width: 18 },
    { key: 'unit', width: 10 },
    { key: 'qty', width: 12 },
    { key: 'min', width: 12 },
    { key: 'status', width: 12 },
  ];
  sheet.views = [{ state: 'frozen', ySplit: 5 }];

  const buf = await wb.xlsx.writeBuffer();
  return Buffer.from(buf);
}

/** Same Hidden Room table layout — unchanged look. */
export async function inventoryPdf(shopId: number): Promise<Buffer> {
  const products = await listProducts(shopId);

  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ margin: 48, size: 'A4' });
    const stream = new PassThrough();
    const chunks: Buffer[] = [];
    stream.on('data', (c) => chunks.push(c as Buffer));
    stream.on('end', () => resolve(Buffer.concat(chunks)));
    stream.on('error', reject);
    doc.pipe(stream);

    const pageW = doc.page.width - doc.page.margins.left - doc.page.margins.right;
    const cols = [
      { key: 'name', label: 'Name', w: pageW * 0.28 },
      { key: 'category', label: 'Category', w: pageW * 0.18 },
      { key: 'unit', label: 'Unit', w: pageW * 0.1 },
      { key: 'qty', label: 'Qty', w: pageW * 0.12 },
      { key: 'min', label: 'Min', w: pageW * 0.12 },
      { key: 'status', label: 'Status', w: pageW * 0.2 },
    ] as const;

    const drawHeaderBlock = () => {
      doc.fillColor(FOREST).font('Helvetica-Bold').fontSize(20).text('Hidden Room', { continued: false });
      doc.moveDown(0.35);
      doc.fillColor(MUTED).font('Helvetica').fontSize(10).text(`Export date: ${exportDateLabel()}`);
      doc.moveDown(0.25);
      doc.fillColor(FOREST).font('Helvetica-Bold').fontSize(16).text('Stock Inventory Report');
      doc.moveDown(0.8);
    };

    const drawTableHeader = () => {
      const y = doc.y;
      const h = 22;
      doc.save();
      doc.rect(doc.page.margins.left, y, pageW, h).fill(CREAM);
      doc.restore();
      let x = doc.page.margins.left;
      doc.fillColor(FOREST).font('Helvetica-Bold').fontSize(10);
      for (const c of cols) {
        doc.text(c.label, x + 4, y + 6, { width: c.w - 8, lineBreak: false });
        x += c.w;
      }
      doc.y = y + h + 4;
    };

    drawHeaderBlock();
    drawTableHeader();

    doc.font('Helvetica').fontSize(10).fillColor(FOREST);
    for (const p of products) {
      const rowH = 20;
      if (doc.y + rowH > doc.page.height - doc.page.margins.bottom) {
        doc.addPage();
        drawHeaderBlock();
        drawTableHeader();
        doc.font('Helvetica').fontSize(10).fillColor(FOREST);
      }
      const y = doc.y;
      const vals = [
        String(p.name ?? ''),
        String(p.categoryName ?? ''),
        String(p.unit ?? ''),
        fmtQty(p.currentQty),
        fmtQty(p.minStock),
        String(p.stockStatus ?? ''),
      ];
      let x = doc.page.margins.left;
      vals.forEach((v, i) => {
        doc.fillColor(FOREST).text(v, x + 4, y + 4, { width: cols[i].w - 8, lineBreak: false });
        x += cols[i].w;
      });
      doc
        .moveTo(doc.page.margins.left, y + rowH)
        .lineTo(doc.page.margins.left + pageW, y + rowH)
        .strokeColor(RULE)
        .lineWidth(0.5)
        .stroke();
      doc.y = y + rowH;
    }

    doc.end();
  });
}
