import { prisma } from '../../config/prisma';
import { CreateParqueoInput } from './parqueos.types';

const buildEspaciosParqueo = (
  parqueoId: number,
  espaciosAutos: number,
  espaciosMotos: number
) => {
  const espaciosAuto = Array.from({ length: espaciosAutos }, (_, index) => ({
    parqueoId,
    codigo: `A${index + 1}`,
    tipo: 'AUTO' as const,
    estado: 'DISPONIBLE' as const
  }));

  const espaciosMoto = Array.from({ length: espaciosMotos }, (_, index) => ({
    parqueoId,
    codigo: `M${index + 1}`,
    tipo: 'MOTO' as const,
    estado: 'DISPONIBLE' as const
  }));

  return [...espaciosAuto, ...espaciosMoto];
};

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

export const findParqueosByOperadorRepository = (operadorId: number) => {
  return prisma.parqueo.findMany({
    where: {
      operadorId,
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

export const createParqueoRepository = async (input: CreateParqueoInput) => {
  return prisma.$transaction(async (tx) => {
    const parqueo = await tx.parqueo.create({
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

    const espacios = buildEspaciosParqueo(
      parqueo.id,
      input.espaciosAutos,
      input.espaciosMotos
    );

    if (espacios.length > 0) {
      await tx.espacio.createMany({
        data: espacios
      });
    }

    return parqueo;
  });
};
