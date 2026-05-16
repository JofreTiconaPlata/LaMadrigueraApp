export type AuthRole = 'CLIENTE' | 'OPERADOR' | 'ADMIN';

export interface RegisterInput {
  nombre: string;
  email: string;
  password: string;
  telefono?: string;
  rol?: AuthRole;
}

export interface LoginInput {
  email: string;
  password: string;
}

export interface AuthTokenPayload {
  id: number;
  email: string;
  rol: AuthRole;
}

export interface PublicUsuario {
  id: number;
  nombre: string;
  email: string;
  telefono: string | null;
  rol: AuthRole;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface AuthResponse {
  token: string;
  usuario: PublicUsuario;
}
