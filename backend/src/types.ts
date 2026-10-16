export type Role = 'super_admin' | 'shop_admin' | 'employee';
export type StockType = 'add' | 'withdraw' | 'adjust';
/** Product unit is a free-form symbol from the shop `units` table. */
export type Unit = string;

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
