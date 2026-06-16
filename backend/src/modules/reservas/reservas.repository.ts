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
      ingreso: {
        select: {
          id: true,
          fechaIngreso: true,
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
    const reservaActiva = await tx.reserva.findFirst({
      where: {
        clienteId,
        estado: {
          in: ['PENDIENTE', 'ACTIVA']
        }
      }
    });

    if (reservaActiva) {
      throw new Error('RESERVA_ACTIVA_EXISTS');
    }

    const tipoEspacio = tipoVehiculo === 'CAMIONETA' ? 'AUTO' : tipoVehiculo;

    const espacioDisponible = input.espacioId
      ? await tx.espacio.findFirst({
          where: {
            id: input.espacioId,
            parqueoId: input.parqueoId,
            estado: 'DISPONIBLE',
            tipo: tipoEspacio,
            parqueo: {
              estado: 'ACTIVO'
            }
          }
        })
      : await tx.espacio.findFirst({
          where: {
            parqueoId: input.parqueoId,
            estado: 'DISPONIBLE',
            tipo: tipoEspacio,
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

    const espacioReservado = await tx.espacio.updateMany({
      where: {
        id: espacioDisponible.id,
        estado: 'DISPONIBLE'
      },
      data: {
        estado: 'RESERVADO'
      }
    });

    if (espacioReservado.count !== 1) {
      throw new Error('ESPACIO_DISPONIBLE_NOT_FOUND');
    }

    return tx.reserva.create({
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
  });
};

export const cancelReservaRepository = (id: number) => {
  return prisma.$transaction(async (tx) => {
    const reserva = await tx.reserva.findUnique({
      where: { id },
      include: {
        ingreso: {
          select: {
            id: true,
            estado: true
          }
        },
        espacio: {
          select: {
            id: true,
            estado: true
          }
        }
      }
    });

    if (!reserva) {
      throw new Error('RESERVA_NOT_FOUND');
    }

    if (reserva.ingreso) {
      throw new Error('RESERVA_ALREADY_IN_USE');
    }

    const reservaCancelada = await tx.reserva.update({
      where: { id },
      data: { estado: 'CANCELADA' }
    });

    if (
      reserva.espacioId &&
      reserva.espacio?.estado === 'RESERVADO'
    ) {
      await tx.espacio.update({
        where: { id: reserva.espacioId },
        data: { estado: 'DISPONIBLE' }
      });
    }

    return reservaCancelada;
  });
};
