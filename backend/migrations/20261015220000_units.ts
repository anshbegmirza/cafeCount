import type { Knex } from 'knex';

const DEFAULT_UNITS: { name: string; symbol: string }[] = [
  { name: 'Pieces', symbol: 'pcs' },
  { name: 'Kilogram', symbol: 'kg' },
  { name: 'Gram', symbol: 'g' },
  { name: 'Litre', symbol: 'L' },
  { name: 'Bottles', symbol: 'bottles' },
  { name: 'Boxes', symbol: 'boxes' },
];

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('units', (t) => {
    t.increments('id').primary();
    t.integer('shop_id').unsigned().notNullable().references('id').inTable('shops').onDelete('CASCADE');
    t.string('name', 80).notNullable();
    t.string('symbol', 32).notNullable();
    t.timestamp('created_at').defaultTo(knex.fn.now());
    t.unique(['shop_id', 'symbol']);
  });

  // Enum → varchar so custom symbols work.
  await knex.schema.raw(
    'ALTER TABLE products MODIFY COLUMN unit VARCHAR(32) NOT NULL',
  );

  const shops = await knex('shops').select('id');
  for (const shop of shops) {
    for (const u of DEFAULT_UNITS) {
      await knex('units').insert({ shop_id: shop.id, name: u.name, symbol: u.symbol });
    }
  }
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('units');
  await knex.schema.raw(
    "ALTER TABLE products MODIFY COLUMN unit ENUM('pcs','kg','g','L','bottles','boxes') NOT NULL",
  );
}
