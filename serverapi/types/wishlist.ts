export interface WishlistRecord {
  id?: number;
  user_id: number;
  game_id: string;
  title: string;
  sale_price: number;
  normal_price: number;
  thumb?: string;
  saved_at?: Date;
}
