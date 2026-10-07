import type { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.alterTable('users', (table) => {
    table.string('gamer_tag', 100).nullable().defaultTo('Gamer');
    table.integer('avatar_index').notNullable().defaultTo(0);
    table.string('bio', 255).nullable().defaultTo('PC Gamer & Deal Hunter 🎮');
    table.string('favorite_store', 50).notNullable().defaultTo('Steam');
    table.timestamp('updated_at').defaultTo(knex.fn.now());
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.alterTable('users', (table) => {
    table.dropColumn('gamer_tag');
    table.dropColumn('avatar_index');
    table.dropColumn('bio');
    table.dropColumn('favorite_store');
    table.dropColumn('updated_at');
  });
}
