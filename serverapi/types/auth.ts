import { Request } from 'express';

export interface UserPayload {
  id: number;
  email: string;
}

export interface AuthenticatedRequest extends Request {
  user?: UserPayload;
}

export interface UserRecord {
  id: number;
  email: string;
  password: string;
  gamer_tag?: string;
  avatar_index?: number;
  avatar_url?: string | null;
  bio?: string;
  favorite_store?: string;
  created_at?: Date;
  updated_at?: Date;
}

export interface UpdateProfileBody {
  gamer_tag?: string;
  avatar_index?: number;
  avatar_url?: string | null;
  bio?: string;
  favorite_store?: string;
}