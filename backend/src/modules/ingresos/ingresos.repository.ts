import { prisma } from '../../config/prisma';
import { CreateIngresoInput } from './ingresos.types';

const ingresoDetalleInclude = {
  parqueo: {
    select: {
      id: true,
      nombre: true,
      direccion: true,
      operadorId: true
    }
  },
  espacio: {
    select: {
      id: true,
      codigo: true,
      tipo: true,
      estado: true
    }
  },
  vehiculo: {
    select: {
      id: true,
      placa: true,
      tipo: true,
      marca: true,
      modelo: true,
      color: true
    }
  },
  operador: {
    select: {
      id: true,
      nombre: true,
      email: true,
      rol: true
    }
  }
};

export const findIngresosRepository = (
  parqueoId?: number,
  estado?: 'ACTIVO' | 'FINALIZADO' | 'CANCELADO',
  operadorId?: number
) => {
  return prisma.ingreso.findMany({
    where: {
      ...(parqueoId ? { parqueoId } : {}),
      ...(estado ? { estado } : {}),
      ...(operadorId
        ? {
            parqueo: {
              operadorId
            }
          }
        : {})
    },
    include: ingresoDetalleInclude,
    orderBy: {
      fechaIngreso: 'desc'
    }
  });
};

export const findIngresoByIdRepository = (id: number) => {
  return prisma.ingreso.findUnique({
    where: {
      id
    },
    include: ingresoDetalleInclude
  });
};

export const createIngresoRepository = (
  input: CreateIngresoInput,
  operadorId: number
) => {
  return prisma.$transaction(async (tx) => {
    const operador = await tx.usuario.findUnique({
      where: {
        id: operadorId
      }
    });

    if (!operador) {
      throw new Error('OPERADOR_NOT_FOUND');
    }

    if (operador.rol !== 'OPERADOR' && operador.rol !== 'ADMIN') {
      throw new Error('USER_NOT_ALLOWED');
    }

    const parqueo = await tx.parqueo.findUnique({
      where: {
        id: input.parqueoId
      }
    });

    if (!parqueo || parqueo.estado !== 'ACTIVO') {
      throw new Error('PARQUEO_NOT_FOUND');
    }

    if (operador.rol === 'OPERADOR' && parqueo.operadorId !== operadorId) {
      throw new Error('PARQUEO_FORBIDDEN');
    }

    const espacio = await tx.espacio.findUnique({
      where: {
        id: input.espacioId
      }
    });

    if (!espacio) {
      throw new Error('ESPACIO_NOT_FOUND');
    }

    if (espacio.parqueoId !== input.parqueoId) {
      throw new Error('ESPACIO_NOT_IN_PARQUEO');
    }

    const vehiculo = await tx.vehiculo.findUnique({
      where: {
        id: input.vehiculoId
      }
    });

    if (!vehiculo) {
      throw new Error('VEHICULO_NOT_FOUND');
    }

    if (input.reservaId) {
      const reserva = await tx.reserva.findUnique({
        where: {
          id: input.reservaId
        }
      });

      if (!reserva) {
        throw new Error('RESERVA_NOT_FOUND');
      }

      if (reserva.estado !== 'ACTIVA') {
        throw new Error('RESERVA_NOT_ACTIVE');
      }

      if (
        reserva.parqueoId !== input.parqueoId ||
        reserva.espacioId !== input.espacioId ||
        reserva.vehiculoId !== input.vehiculoId
      ) {
        throw new Error('RESERVA_NOT_MATCH');
      }

      const ingresoReserva = await tx.ingreso.findFirst({
        where: {
          reservaId: input.reservaId
        }
      });

      if (ingresoReserva) {
        throw new Error('RESERVA_ALREADY_USED');
      }

      if (espacio.estado !== 'RESERVADO') {
        throw new Error('ESPACIO_NOT_AVAILABLE');
      }
    } else if (espacio.estado !== 'DISPONIBLE') {
      throw new Error('ESPACIO_NOT_AVAILABLE');
    }

    const ingresoActivo = await tx.ingreso.findFirst({
      where: {
        vehiculoId: input.vehiculoId,
        estado: 'ACTIVO'
      }
    });

    if (ingresoActivo) {
      throw new Error('VEHICULO_ALREADY_INSIDE');
    }

    const ingreso = await tx.ingreso.create({
      data: {
        reservaId: input.reservaId ?? null,
        parqueoId: input.parqueoId,
        espacioId: input.espacioId,
        vehiculoId: input.vehiculoId,
        operadorId
      }
    });

    await tx.espacio.update({
      where: {
        id: input.espacioId
      },
      data: {
        estado: 'DISPONIBLE'
      }
    });

    if (input.reservaId) {
      await tx.reserva.update({
        where: {
          id: input.reservaId
        },
        data: {
          estado: 'COMPLETADA'
        }
      });
    }

    const ingresoDetalle = await tx.ingreso.findUnique({
      where: {
        id: ingreso.id
      },
      include: ingresoDetalleInclude
    });

    if (!ingresoDetalle) {
      throw new Error('INGRESO_NOT_FOUND');
    }

    return ingresoDetalle;
  });
};

export const cancelarIngresoRepository = (id: number) => {
  return prisma.$transaction(async (tx) => {
    const ingreso = await tx.ingreso.findUnique({
      where: {
        id
      }
    });

    if (!ingreso) {
      throw new Error('INGRESO_NOT_FOUND');
    }

    if (ingreso.estado !== 'ACTIVO') {
      throw new Error('INGRESO_NOT_ACTIVE');
    }

    const updatedIngreso = await tx.ingreso.update({
      where: {
        id
      },
      data: {
        estado: 'CANCELADO'
      },
      include: ingresoDetalleInclude
    });

    await tx.espacio.update({
      where: {
        id: ingreso.espacioId
      },
      data: {
        estado: 'DISPONIBLE'
      }
    });

    return updatedIngreso;
  });
};
