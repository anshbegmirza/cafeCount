import { db } from '../db';
import { AppError } from '../errors';

export async function listUnits(shopId: number) {
  return db('units')
    .where({ shop_id: shopId })
    .select('id', 'name', 'symbol')
    .orderBy('name', 'asc');
}

export async function createUnit(shopId: number, name: string, symbol: string) {
  const trimmedName = name.trim();
  const trimmedSymbol = symbol.trim();
  if (!trimmedName || !trimmedSymbol) {
    throw new AppError(400, 'VALIDATION', 'Unit name and symbol are required');
  }
  try {
    const [id] = await db('units').insert({
      shop_id: shopId,
      name: trimmedName,
      symbol: trimmedSymbol,
    });
    return { id, name: trimmedName, symbol: trimmedSymbol };
  } catch {
    throw new AppError(409, 'CONFLICT', 'A unit with this symbol already exists');
  }
}

/** Ensure symbol exists for this shop (products store symbol as unit). */
export async function assertUnitSymbol(shopId: number, symbol: string) {
  const row = await db('units').where({ shop_id: shopId, symbol }).first();
  if (!row) throw new AppError(400, 'INVALID_UNIT', 'Select a valid unit');
  return row as { id: number; name: string; symbol: string };
}
