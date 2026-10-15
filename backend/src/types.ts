export type Role = 'super_admin' | 'shop_admin' | 'employee';
export type StockType = 'add' | 'withdraw' | 'adjust';
export type Unit = 'pcs' | 'kg' | 'g' | 'L' | 'bottles' | 'boxes';

export interface AuthUser {
  id: number;
  shopId: number | null;
  role: Role;
  username: string;
  email: string;
}

export const ADMIN_ROLES: Role[] = ['super_admin', 'shop_admin'];

export function isAdmin(role: Role): boolean {
  return ADMIN_ROLES.includes(role);
}
