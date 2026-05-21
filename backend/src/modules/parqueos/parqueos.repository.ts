import { prisma } from '../../config/prisma';

export const findParqueosActivosRepository = () => {
  return prisma.parqueo.findMany({
    where: {
      estado: 'ACTIVO'
    },
    orderBy: {
      id: 'asc'
    }
  });
};

export const findParqueoByIdRepository = (id: number) => {
  return prisma.parqueo.findUnique({
    where: {
      id
    }
  });
};
