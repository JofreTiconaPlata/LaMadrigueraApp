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

export const createParqueoRepository = async (
  input: CreateParqueoInput
) => {
  return prisma.$transaction(async (tx) => {
    // Crear parqueo
    const parqueo = await tx.parqueo.create({
      data: {
        nombre: input.nombre,
        direccion: input.direccion,
        latitud: input.latitud,
        longitud: input.longitud,
        espaciosAutos: input.espaciosAutos,
        espaciosMotos: input.espaciosMotos,
        capacidadTotal: input.espaciosAutos + input.espaciosMotos,
        estado: 'ACTIVO',
        operadorId: input.operadorId
      }
    });

    // Crear espacios AUTO
    for (let i = 1; i <= input.espaciosAutos; i++) {
      await tx.espacio.create({
        data: {
          parqueoId: parqueo.id,
          codigo: `A${i}`,
          tipo: 'AUTO',
          estado: 'DISPONIBLE'
        }
      });
    }

    // Crear espacios MOTO
    for (let i = 1; i <= input.espaciosMotos; i++) {
      await tx.espacio.create({
        data: {
          parqueoId: parqueo.id,
          codigo: `M${i}`,
          tipo: 'MOTO',
          estado: 'DISPONIBLE'
        }
      });
    }

    return parqueo;
  });
};