import { prisma } from '../../config/prisma';
import { CreateVehiculoInput } from './vehiculos.types';

export const findVehiculosRepository = (clienteId?: number) => {
  return prisma.vehiculo.findMany({
    where: {
      ...(clienteId ? { clienteId } : {})
    },
    orderBy: {
      id: 'asc'
    }
  });
};

export const findVehiculoByIdRepository = (id: number) => {
  return prisma.vehiculo.findUnique({
    where: {
      id
    }
  });
};

export const findVehiculoByPlacaRepository = (placa: string) => {
  return prisma.vehiculo.findUnique({
    where: {
      placa
    }
  });
};

export const createVehiculoRepository = (input: CreateVehiculoInput) => {
  return prisma.vehiculo.create({
    data: {
      clienteId: input.clienteId,
      placa: input.placa,
      tipo: input.tipo,
      marca: input.marca,
      modelo: input.modelo,
      color: input.color
    }
  });
};

export const deleteVehiculoRepository = (id: number) => {
  return prisma.vehiculo.delete({
    where: {
      id
    }
  });
};
