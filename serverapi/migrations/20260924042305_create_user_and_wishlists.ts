import type { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  // สร้างตาราง users
  await knex.schema.createTable('users', (table) => {
    table.increments('id').primary();
    table.string('email', 255).notNullable().unique();
    table.string('password', 255).notNullable();
    table.timestamp('created_at').defaultTo(knex.fn.now());
  });

  // สร้างตาราง wishlists
  await knex.schema.createTable('wishlists', (table) => {
    table.increments('id').primary();
    table.integer('user_id').unsigned().notNullable()
      .references('id').inTable('users')
      .onDelete('CASCADE');
    table.string('game_id', 100).notNullable();
    table.string('title', 255).notNullable();
    table.decimal('sale_price', 10, 2).notNullable();
    table.decimal('normal_price', 10, 2).notNullable();
    table.string('thumb', 500).nullable();
    table.timestamp('saved_at').defaultTo(knex.fn.now());
  });
}

export async function down(knex: Knex): Promise<void> {
  // คำสั่งย้อนกลับเมื่อต้องการ rollback
  await knex.schema.dropTableIfExists('wishlists');
  await knex.schema.dropTableIfExists('users');
}
