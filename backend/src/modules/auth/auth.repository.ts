import { prisma } from '../../config/prisma';
import { RegisterInput } from './auth.types';

export const findUsuarioByEmail = (email: string) => {
  return prisma.usuario.findUnique({
    where: { email }
  });
};

export const findUsuarioById = (id: number) => {
  return prisma.usuario.findUnique({
    where: { id }
  });
};

export const createUsuario = (input: RegisterInput, passwordHash: string) => {
  return prisma.usuario.create({
    data: {
      nombre: input.nombre,
      email: input.email,
      passwordHash,
      telefono: input.telefono,
      rol: input.rol ?? 'CLIENTE'
    }
  });
};
