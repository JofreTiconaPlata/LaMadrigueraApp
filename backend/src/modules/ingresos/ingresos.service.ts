import {
  CreateIngresoInput,
  IngresoDetalleResponse
} from './ingresos.types';
import {
  cancelarIngresoRepository,
  createIngresoRepository,
  findIngresoByIdRepository,
  findIngresosRepository
} from './ingresos.repository';

type RolUsuario = 'CLIENTE' | 'OPERADOR' | 'ADMIN';

const toIngresoDetalleResponse = (ingreso: {
  id: number;
  reservaId: number | null;
  parqueoId: number;
  espacioId: number;
  vehiculoId: number;
  operadorId: number;
  fechaIngreso: Date;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
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
  operador: {
    id: number;
    nombre: string;
    email: string;
    rol: string;
  };
}): IngresoDetalleResponse => ({
  id: ingreso.id,
  reservaId: ingreso.reservaId,
  parqueoId: ingreso.parqueoId,
  espacioId: ingreso.espacioId,
  vehiculoId: ingreso.vehiculoId,
  operadorId: ingreso.operadorId,
  fechaIngreso: ingreso.fechaIngreso,
  estado: ingreso.estado,
  createdAt: ingreso.createdAt,
  updatedAt: ingreso.updatedAt,
  parqueo: {
    id: ingreso.parqueo.id,
    nombre: ingreso.parqueo.nombre,
    direccion: ingreso.parqueo.direccion
  },
  espacio: ingreso.espacio,
  vehiculo: ingreso.vehiculo,
  operador: ingreso.operador
});

const assertCanAccessIngreso = (
  ingreso: {
    parqueo: {
      operadorId?: number;
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

  if (ingreso.parqueo.operadorId !== usuario.id) {
    throw new Error('INGRESO_FORBIDDEN');
  }
};

export const getIngresosService = async (
  parqueoId: number | undefined,
  estado: 'ACTIVO' | 'FINALIZADO' | 'CANCELADO' | undefined,
  usuario: { id: number; rol: RolUsuario }
): Promise<IngresoDetalleResponse[]> => {
  if (usuario.rol === 'ADMIN') {
    const ingresos = await findIngresosRepository(parqueoId, estado);

    return ingresos.map(toIngresoDetalleResponse);
  }

  if (usuario.rol === 'OPERADOR') {
    const ingresos = await findIngresosRepository(parqueoId, estado, usuario.id);

    return ingresos.map(toIngresoDetalleResponse);
  }

  throw new Error('USER_NOT_ALLOWED');
};

export const getIngresosActivosService = async (
  parqueoId: number | undefined,
  usuario: { id: number; rol: RolUsuario }
): Promise<IngresoDetalleResponse[]> => {
  return getIngresosService(parqueoId, 'ACTIVO', usuario);
};

export const getIngresoByIdService = async (
  id: number,
  usuario: { id: number; rol: RolUsuario }
): Promise<IngresoDetalleResponse> => {
  const ingreso = await findIngresoByIdRepository(id);

  if (!ingreso) {
    throw new Error('INGRESO_NOT_FOUND');
  }

  assertCanAccessIngreso(ingreso, usuario);

  return toIngresoDetalleResponse(ingreso);
};

export const createIngresoService = async (
  input: CreateIngresoInput,
  operadorId: number
): Promise<IngresoDetalleResponse> => {
  const ingreso = await createIngresoRepository(input, operadorId);

  return toIngresoDetalleResponse(ingreso);
};

export const cancelarIngresoService = async (
  id: number,
  usuario: { id: number; rol: RolUsuario }
): Promise<IngresoDetalleResponse> => {
  const ingreso = await findIngresoByIdRepository(id);

  if (!ingreso) {
    throw new Error('INGRESO_NOT_FOUND');
  }

  assertCanAccessIngreso(ingreso, usuario);

  const ingresoCancelado = await cancelarIngresoRepository(id);

  return toIngresoDetalleResponse(ingresoCancelado);
};
