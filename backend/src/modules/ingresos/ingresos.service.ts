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
  parqueo: ingreso.parqueo,
  espacio: ingreso.espacio,
  vehiculo: ingreso.vehiculo,
  operador: ingreso.operador
});

export const getIngresosService = async (
  parqueoId?: number,
  estado?: 'ACTIVO' | 'FINALIZADO' | 'CANCELADO'
): Promise<IngresoDetalleResponse[]> => {
  const ingresos = await findIngresosRepository(parqueoId, estado);

  return ingresos.map(toIngresoDetalleResponse);
};

export const getIngresosActivosService = async (
  parqueoId?: number
): Promise<IngresoDetalleResponse[]> => {
  const ingresos = await findIngresosRepository(parqueoId, 'ACTIVO');

  return ingresos.map(toIngresoDetalleResponse);
};

export const getIngresoByIdService = async (
  id: number
): Promise<IngresoDetalleResponse> => {
  const ingreso = await findIngresoByIdRepository(id);

  if (!ingreso) {
    throw new Error('INGRESO_NOT_FOUND');
  }

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
  id: number
): Promise<IngresoDetalleResponse> => {
  const ingreso = await cancelarIngresoRepository(id);

  return toIngresoDetalleResponse(ingreso);
};
