import {
  CreateSalidaCobroInput,
  SalidaCobroDetalleResponse
} from './salidas-cobros.types';
import {
  createSalidaCobroRepository,
  findSalidaCobroByIdRepository,
  findSalidasCobrosRepository
} from './salidas-cobros.repository';

type RolUsuario = 'CLIENTE' | 'OPERADOR' | 'ADMIN';

const toSalidaCobroDetalleResponse = (salidaCobro: {
  id: number;
  ingresoId: number;
  operadorId: number;
  fechaSalida: Date;
  tiempoTotalMinutos: number;
  montoTotal: unknown;
  estadoPago: string;
  createdAt: Date;
  updatedAt: Date;
  ingreso: {
    id: number;
    fechaIngreso: Date;
    estado: string;
    parqueo: {
      id: number;
      nombre: string;
      direccion: string;
      operadorId?: number;
    };
    espacio: {
      id: number;
      codigo: string;
      tipo: string;
      estado: string;
    };
    vehiculo: {
      id: number;
      placa: string;
      tipo: string;
      marca: string | null;
      modelo: string | null;
      color: string | null;
    };
  };
  operador: {
    id: number;
    nombre: string;
    email: string;
    rol: string;
  };
  pago: {
    id: number;
    metodoPago: string;
    monto: unknown;
    referencia: string | null;
    estado: string;
    fechaPago: Date;
  } | null;
}): SalidaCobroDetalleResponse => ({
  id: salidaCobro.id,
  ingresoId: salidaCobro.ingresoId,
  operadorId: salidaCobro.operadorId,
  fechaSalida: salidaCobro.fechaSalida,
  tiempoTotalMinutos: salidaCobro.tiempoTotalMinutos,
  montoTotal: Number(salidaCobro.montoTotal),
  estadoPago: salidaCobro.estadoPago,
  createdAt: salidaCobro.createdAt,
  updatedAt: salidaCobro.updatedAt,
  ingreso: {
    id: salidaCobro.ingreso.id,
    fechaIngreso: salidaCobro.ingreso.fechaIngreso,
    estado: salidaCobro.ingreso.estado,
    parqueo: {
      id: salidaCobro.ingreso.parqueo.id,
      nombre: salidaCobro.ingreso.parqueo.nombre,
      direccion: salidaCobro.ingreso.parqueo.direccion
    },
    espacio: salidaCobro.ingreso.espacio,
    vehiculo: salidaCobro.ingreso.vehiculo
  },
  operador: salidaCobro.operador,
  pago: salidaCobro.pago
    ? {
        ...salidaCobro.pago,
        monto: Number(salidaCobro.pago.monto)
      }
    : null
});

const assertCanAccessSalidaCobro = (
  salidaCobro: {
    ingreso: {
      parqueo: {
        operadorId?: number;
      };
    };
  },
  usuario: { id: number; rol: RolUsuario }
): void => {
  if (usuario.rol === 'ADMIN') {
    return;
  }

  if (usuario.rol !== 'OPERADOR') {
    throw new Error('USER_NOT_ALLOWED');
  }

  if (salidaCobro.ingreso.parqueo.operadorId !== usuario.id) {
    throw new Error('SALIDA_COBRO_FORBIDDEN');
  }
};

export const getSalidasCobrosService = async (
  ingresoId: number | undefined,
  estadoPago: 'PENDIENTE' | 'PAGADO' | 'ANULADO' | undefined,
  usuario: { id: number; rol: RolUsuario }
): Promise<SalidaCobroDetalleResponse[]> => {
  if (usuario.rol === 'ADMIN') {
    const salidasCobros = await findSalidasCobrosRepository(ingresoId, estadoPago);

    return salidasCobros.map(toSalidaCobroDetalleResponse);
  }

  if (usuario.rol === 'OPERADOR') {
    const salidasCobros = await findSalidasCobrosRepository(
      ingresoId,
      estadoPago,
      usuario.id
    );

    return salidasCobros.map(toSalidaCobroDetalleResponse);
  }

  throw new Error('USER_NOT_ALLOWED');
};

export const getSalidaCobroByIdService = async (
  id: number,
  usuario: { id: number; rol: RolUsuario }
): Promise<SalidaCobroDetalleResponse> => {
  const salidaCobro = await findSalidaCobroByIdRepository(id);

  if (!salidaCobro) {
    throw new Error('SALIDA_COBRO_NOT_FOUND');
  }

  assertCanAccessSalidaCobro(salidaCobro, usuario);

  return toSalidaCobroDetalleResponse(salidaCobro);
};

export const createSalidaCobroService = async (
  input: CreateSalidaCobroInput,
  operadorId: number
): Promise<SalidaCobroDetalleResponse> => {
  const salidaCobro = await createSalidaCobroRepository(input, operadorId);

  return toSalidaCobroDetalleResponse(salidaCobro);
};
