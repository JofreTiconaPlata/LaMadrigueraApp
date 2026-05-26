import { prisma } from '../../config/prisma';
import { CreateReservaInput } from './reservas.types';

export const findClienteByUsuarioIdRepository = (usuarioId: number) => {
  return prisma.cliente.findUnique({
    where: {
      usuarioId
    }
  });
};

export const findVehiculoByIdRepository = (vehiculoId: number) => {
  return prisma.vehiculo.findUnique({
    where: {
      id: vehiculoId
    }
  });
};

export const findParqueoByIdRepository = (parqueoId: number) => {
  return prisma.parqueo.findUnique({
    where: {
      id: parqueoId
    }
  });
};

export const findReservasRepository = (clienteId?: number) => {
  return prisma.reserva.findMany({
    where: {
      ...(clienteId ? { clienteId } : {})
    },
    orderBy: {
      id: 'desc'
    }
  });
};

export const findReservaByIdRepository = (id: number) => {
  return prisma.reserva.findUnique({
    where: {
      id
    }
  });
};

export const createReservaConEspacioRepository = async (
  clienteId: number,
  input: CreateReservaInput,
  tipoVehiculo: 'AUTO' | 'MOTO' | 'CAMIONETA'
) => {
  return prisma.$transaction(async (tx) => {
    const espacioDisponible = await tx.espacio.findFirst({
      where: {
        parqueoId: input.parqueoId,
        estado: 'DISPONIBLE',
        tipo: tipoVehiculo === 'CAMIONETA' ? 'AUTO' : tipoVehiculo,
        parqueo: {
          estado: 'ACTIVO'
        }
      },
      orderBy: {
        codigo: 'asc'
      }
    });

    if (!espacioDisponible) {
      throw new Error('ESPACIO_DISPONIBLE_NOT_FOUND');
    }

    const reserva = await tx.reserva.create({
      data: {
        clienteId,
        parqueoId: input.parqueoId,
        espacioId: espacioDisponible.id,
        vehiculoId: input.vehiculoId,
        fechaInicio: input.fechaInicio,
        fechaFin: input.fechaFin,
        estado: 'ACTIVA'
      }
    });

    await tx.espacio.update({
      where: {
        id: espacioDisponible.id
      },
      data: {
        estado: 'RESERVADO'
      }
    });

    return reserva;
  });
};
