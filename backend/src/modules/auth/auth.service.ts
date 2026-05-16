import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import type { SignOptions } from 'jsonwebtoken';
import { env } from '../../config/env';
import {
  AuthResponse,
  AuthTokenPayload,
  LoginInput,
  PublicUsuario,
  RegisterInput
} from './auth.types';
import {
  createUsuario,
  findUsuarioByEmail,
  findUsuarioById
} from './auth.repository';

const SALT_ROUNDS = 10;

const toPublicUsuario = (usuario: {
  id: number;
  nombre: string;
  email: string;
  telefono: string | null;
  rol: 'CLIENTE' | 'OPERADOR' | 'ADMIN';
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}): PublicUsuario => ({
  id: usuario.id,
  nombre: usuario.nombre,
  email: usuario.email,
  telefono: usuario.telefono,
  rol: usuario.rol,
  estado: usuario.estado,
  createdAt: usuario.createdAt,
  updatedAt: usuario.updatedAt
});

const signToken = (payload: AuthTokenPayload): string => {
  const options: SignOptions = {
    expiresIn: env.JWT_EXPIRES_IN as SignOptions['expiresIn']
  };

  return jwt.sign(payload, env.JWT_SECRET, options);
};

export const registerUsuarioService = async (input: RegisterInput): Promise<AuthResponse> => {
  const existingUsuario = await findUsuarioByEmail(input.email);

  if (existingUsuario) {
    throw new Error('EMAIL_ALREADY_EXISTS');
  }

  const passwordHash = await bcrypt.hash(input.password, SALT_ROUNDS);
  const usuario = await createUsuario(input, passwordHash);

  const token = signToken({
    id: usuario.id,
    email: usuario.email,
    rol: usuario.rol
  });

  return {
    token,
    usuario: toPublicUsuario(usuario)
  };
};

export const loginUsuarioService = async (input: LoginInput): Promise<AuthResponse> => {
  const usuario = await findUsuarioByEmail(input.email);

  if (!usuario) {
    throw new Error('INVALID_CREDENTIALS');
  }

  const passwordMatches = await bcrypt.compare(input.password, usuario.passwordHash);

  if (!passwordMatches) {
    throw new Error('INVALID_CREDENTIALS');
  }

  const token = signToken({
    id: usuario.id,
    email: usuario.email,
    rol: usuario.rol
  });

  return {
    token,
    usuario: toPublicUsuario(usuario)
  };
};

export const getAuthenticatedUsuarioService = async (usuarioId: number): Promise<PublicUsuario> => {
  const usuario = await findUsuarioById(usuarioId);

  if (!usuario) {
    throw new Error('USER_NOT_FOUND');
  }

  return toPublicUsuario(usuario);
};
