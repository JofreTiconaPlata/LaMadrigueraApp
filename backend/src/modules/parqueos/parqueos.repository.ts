import { prisma } from '../../config/prisma';
import { CreateParqueoInput } from './parqueos.types';

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

export const countParqueosActivosByOperadorRepository = (operadorId: number) => {
  return prisma.parqueo.count({
    where: {
      operadorId,
      estado: 'ACTIVO'
    }
  });
};

export const createParqueoRepository = (input: CreateParqueoInput) => {
  return prisma.parqueo.create({
    data: {
      operadorId: input.operadorId,
      nombre: input.nombre,
      direccion: input.direccion,
      latitud: input.latitud,
      longitud: input.longitud,
      espaciosAutos: input.espaciosAutos,
      espaciosMotos: input.espaciosMotos,
      capacidadTotal: input.espaciosAutos + input.espaciosMotos,
      qrPagoUrl: input.qrPagoUrl ?? null,
      estado: 'ACTIVO'
    }
  });
};
