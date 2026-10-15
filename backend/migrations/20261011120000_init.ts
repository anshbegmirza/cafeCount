import type { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('shops', (t) => {
    t.increments('id').primary();
    t.string('name', 120).notNullable();
    t.enum('status', ['active', 'suspended']).notNullable().defaultTo('active');
    t.timestamps(true, true);
  });

  await knex.schema.createTable('users', (t) => {
    t.increments('id').primary();
    t.integer('shop_id').unsigned().nullable().references('id').inTable('shops').onDelete('SET NULL');
    t.string('username', 80).notNullable().unique();
    t.string('email', 160).notNullable().unique();
    t.string('password_hash', 255).notNullable();
    t.enum('role', ['super_admin', 'shop_admin', 'employee']).notNullable();
    t.boolean('is_active').notNullable().defaultTo(true);
    t.timestamps(true, true);
    t.index(['shop_id', 'role']);
  });

  await knex.schema.createTable('refresh_tokens', (t) => {
    t.increments('id').primary();
    t.integer('user_id').unsigned().notNullable().references('id').inTable('users').onDelete('CASCADE');
    t.string('token_hash', 255).notNullable().unique();
    t.timestamp('expires_at').notNullable();
    t.timestamp('created_at').defaultTo(knex.fn.now());
  });

  await knex.schema.createTable('categories', (t) => {
    t.increments('id').primary();
    t.integer('shop_id').unsigned().notNullable().references('id').inTable('shops').onDelete('CASCADE');
    t.string('name', 120).notNullable();
    t.timestamps(true, true);
    t.unique(['shop_id', 'name']);
  });

  await knex.schema.createTable('products', (t) => {
    t.increments('id').primary();
    t.integer('shop_id').unsigned().notNullable().references('id').inTable('shops').onDelete('CASCADE');
    t.integer('category_id').unsigned().nullable().references('id').inTable('categories').onDelete('SET NULL');
    t.string('name', 160).notNullable();
    t.enum('unit', ['pcs', 'kg', 'g', 'L', 'bottles', 'boxes']).notNullable();
    t.decimal('min_stock', 12, 3).notNullable().defaultTo(0);
    t.decimal('current_qty', 12, 3).notNullable().defaultTo(0);
    t.boolean('is_active').notNullable().defaultTo(true);
    t.timestamps(true, true);
    t.index(['shop_id', 'name']);
    t.index(['shop_id', 'current_qty']);
  });

  await knex.schema.createTable('stock_transactions', (t) => {
    t.increments('id').primary();
    t.integer('shop_id').unsigned().notNullable().references('id').inTable('shops').onDelete('CASCADE');
    t.integer('product_id').unsigned().notNullable().references('id').inTable('products').onDelete('CASCADE');
    t.integer('user_id').unsigned().notNullable().references('id').inTable('users').onDelete('RESTRICT');
    t.enum('type', ['add', 'withdraw', 'adjust']).notNullable();
    t.decimal('quantity', 12, 3).notNullable();
    t.decimal('stock_before', 12, 3).notNullable();
    t.decimal('stock_after', 12, 3).notNullable();
    t.string('note', 255).nullable();
    t.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    t.index(['shop_id', 'created_at']);
    t.index(['product_id', 'created_at']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('stock_transactions');
  await knex.schema.dropTableIfExists('products');
  await knex.schema.dropTableIfExists('categories');
  await knex.schema.dropTableIfExists('refresh_tokens');
  await knex.schema.dropTableIfExists('users');
  await knex.schema.dropTableIfExists('shops');
}
