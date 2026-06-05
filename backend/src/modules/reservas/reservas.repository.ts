import { prisma } from '../../config/prisma';
import { CreateReservaInput } from './reservas.types';

export const findClienteByUsuarioIdRepository = (usuarioId: number) => {
  return prisma.cliente.findUnique({
    where: { usuarioId },
  });
};

export const createClienteByUsuarioIdRepository = (usuarioId: number) => {
  return prisma.cliente.upsert({
    where: { usuarioId },
    update: {},
    create: { usuarioId },
  });
};

export const findVehiculoByIdRepository = (vehiculoId: number) => {
  return prisma.vehiculo.findUnique({
    where: { id: vehiculoId },
  });
};

export const findParqueoByIdRepository = (parqueoId: number) => {
  return prisma.parqueo.findUnique({
    where: { id: parqueoId },
  });
};

export const findReservasRepository = (clienteId?: number) => {
  return prisma.reserva.findMany({
    where: {
      ...(clienteId ? { clienteId } : {}),
    },
    include: {
      parqueo: {
        select: {
          id: true,
          nombre: true,
          direccion: true,
        },
      },
      vehiculo: {
        select: {
          id: true,
          placa: true,
          tipo: true,
        },
      },
      espacio: {
        select: {
          id: true,
          codigo: true,
          tipo: true,
        },
      },
    },
    orderBy: { id: 'desc' },
  });
};

export const findReservasByOperadorRepository = (operadorId: number) => {
  return prisma.reserva.findMany({
    where: {
      parqueo: {
        operadorId,
      },
    },
    include: {
      parqueo: {
        select: {
          id: true,
          nombre: true,
          direccion: true,
        },
      },
      vehiculo: {
        select: {
          id: true,
          placa: true,
          tipo: true,
        },
      },
      espacio: {
        select: {
          id: true,
          codigo: true,
          tipo: true,
          estado: true,
        },
      },
    },
    orderBy: { id: 'desc' },
  });
};

export const findReservaByIdRepository = (id: number) => {
  return prisma.reserva.findUnique({
    where: { id },
    include: {
      parqueo: {
        select: {
          id: true,
          nombre: true,
          direccion: true,
        },
      },
      vehiculo: {
        select: {
          id: true,
          placa: true,
          tipo: true,
        },
      },
      espacio: {
        select: {
          id: true,
          codigo: true,
          tipo: true,
        },
      },
    },
  });
};

export const createReservaConEspacioRepository = async (
  clienteId: number,
  input: CreateReservaInput,
  tipoVehiculo: 'AUTO' | 'MOTO' | 'CAMIONETA'
) => {
  return prisma.$transaction(async (tx) => {
    const tipoEspacio = tipoVehiculo === 'CAMIONETA' ? 'AUTO' : tipoVehiculo;

    const espacioDisponible = input.espacioId
      ? await tx.espacio.findFirst({
          where: {
            id: input.espacioId,
            parqueoId: input.parqueoId,
            estado: 'DISPONIBLE',
            tipo: tipoEspacio,
            parqueo: {
              estado: 'ACTIVO',
            },
          },
        })
      : await tx.espacio.findFirst({
          where: {
            parqueoId: input.parqueoId,
            estado: 'DISPONIBLE',
            tipo: tipoEspacio,
            parqueo: {
              estado: 'ACTIVO',
            },
          },
          orderBy: {
            codigo: 'asc',
          },
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
        estado: 'ACTIVA',
      },
    });

    await tx.espacio.update({
      where: { id: espacioDisponible.id },
      data: { estado: 'OCUPADO' },
    });

    return reserva;
  });
};

export const cancelReservaRepository = (id: number) => {
  return prisma.$transaction(async (tx) => {
    const reserva = await tx.reserva.findUnique({
      where: { id },
    });

    if (!reserva) {
      throw new Error('RESERVA_NOT_FOUND');
    }

    const reservaCancelada = await tx.reserva.update({
      where: { id },
      data: { estado: 'CANCELADA' },
    });

    if (reserva.espacioId) {
      await tx.espacio.update({
        where: { id: reserva.espacioId },
        data: { estado: 'DISPONIBLE' },
      });
    }

    return reservaCancelada;
  });
};
