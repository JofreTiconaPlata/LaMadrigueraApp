import { prisma } from '../../config/prisma';
import { UpdateEstadoEspacioInput } from './espacios.types';

export const findEspaciosRepository = (parqueoId?: number) => {
  return prisma.espacio.findMany({
    where: {
      ...(parqueoId ? { parqueoId } : {})
    },
    orderBy: [
      { parqueoId: 'asc' },
      { codigo: 'asc' }
    ]
  });
};

export const findEspacioByIdRepository = (id: number) => {
  return prisma.espacio.findUnique({
    where: {
      id
    }
  });
};

export const updateEstadoEspacioRepository = (
  id: number,
  input: UpdateEstadoEspacioInput
) => {
  return prisma.espacio.update({
    where: {
      id
    },
    data: {
      estado: input.estado
    }
  });
};
