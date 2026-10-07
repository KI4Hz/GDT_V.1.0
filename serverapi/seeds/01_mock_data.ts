import type { Knex } from 'knex';
import bcrypt from 'bcrypt';

export async function seed(knex: Knex): Promise<void> {
  // ลบข้อมูลเดิมออกเพื่อความสะอาด
  await knex('wishlists').del();
  await knex('users').del();

  const hashedPassword = await bcrypt.hash('123456', 10);

  // เพิ่ม User จำลองพร้อม Profile
  const [userId] = await knex('users').insert({
    email: 'gamer@test.com',
    password: hashedPassword,
    gamer_tag: 'CyberPro',
    avatar_index: 1,
    bio: 'Hunter of the steepest Steam discounts! 🎮🚀',
    favorite_store: 'Steam',
  });

  // เพิ่ม Wishlist จำลอง
  await knex('wishlists').insert([
    {
      user_id: userId,
      game_id: '1447',
      title: 'Cyberpunk 2077',
      sale_price: 29.99,
      normal_price: 59.99,
      thumb: 'https://images.greenmangaming.com/c636f455e7144e13b302c38d6df72a15/b7aeef39a9c1417a80b6fc7096d26d84.jpg',
    },
    {
      user_id: userId,
      game_id: '154',
      title: 'The Witcher 3: Wild Hunt',
      sale_price: 9.99,
      normal_price: 39.99,
      thumb: 'https://images.greenmangaming.com/15291f09e8a74e5cb42a781b43343355/ca5957b44d3246ebbfbe2a13ee4cfbd0.jpg',
    },
  ]);
}
