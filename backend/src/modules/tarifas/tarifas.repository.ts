import { prisma } from '../../config/prisma';
import {
  CreateTarifaInput,
  UpdateTarifaInput
} from './tarifas.types';

export const findTarifasRepository = (
  parqueoId?: number,
  tipoVehiculo?: 'AUTO' | 'MOTO' | 'CAMIONETA'
) => {
  return prisma.tarifa.findMany({
    where: {
      ...(parqueoId ? { parqueoId } : {}),
      ...(tipoVehiculo ? { tipoVehiculo } : {})
    },
    orderBy: [
      { parqueoId: 'asc' },
      { tipoVehiculo: 'asc' }
    ]
  });
};

export const findTarifaByIdRepository = (id: number) => {
  return prisma.tarifa.findUnique({
    where: {
      id
    }
  });
};

export const findTarifaByParqueoAndTipoRepository = (
  parqueoId: number,
  tipoVehiculo: 'AUTO' | 'MOTO' | 'CAMIONETA'
) => {
  return prisma.tarifa.findUnique({
    where: {
      parqueoId_tipoVehiculo: {
        parqueoId,
        tipoVehiculo
      }
    }
  });
};

export const createTarifaRepository = (input: CreateTarifaInput) => {
  return prisma.tarifa.create({
    data: {
      parqueoId: input.parqueoId,
      tipoVehiculo: input.tipoVehiculo,
      montoHora: input.montoHora,
      montoFraccion: input.montoFraccion
    }
  });
};

export const updateTarifaRepository = (
  id: number,
  input: UpdateTarifaInput
) => {
  return prisma.tarifa.update({
    where: {
      id
    },
    data: input
  });
};
