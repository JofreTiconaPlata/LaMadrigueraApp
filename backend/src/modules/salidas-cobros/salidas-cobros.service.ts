import {
  CreateSalidaCobroInput,
  SalidaCobroDetalleResponse
} from './salidas-cobros.types';
import {
  createSalidaCobroRepository,
  findSalidaCobroByIdRepository,
  findSalidasCobrosRepository
} from './salidas-cobros.repository';

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
  ingreso: salidaCobro.ingreso,
  operador: salidaCobro.operador,
  pago: salidaCobro.pago
    ? {
        ...salidaCobro.pago,
        monto: Number(salidaCobro.pago.monto)
      }
    : null
});

export const getSalidasCobrosService = async (
  ingresoId?: number,
  estadoPago?: 'PENDIENTE' | 'PAGADO' | 'ANULADO'
): Promise<SalidaCobroDetalleResponse[]> => {
  const salidasCobros = await findSalidasCobrosRepository(ingresoId, estadoPago);

  return salidasCobros.map(toSalidaCobroDetalleResponse);
};

export const getSalidaCobroByIdService = async (
  id: number
): Promise<SalidaCobroDetalleResponse> => {
  const salidaCobro = await findSalidaCobroByIdRepository(id);

  if (!salidaCobro) {
    throw new Error('SALIDA_COBRO_NOT_FOUND');
  }

  return toSalidaCobroDetalleResponse(salidaCobro);
};

export const createSalidaCobroService = async (
  input: CreateSalidaCobroInput,
  operadorId: number
): Promise<SalidaCobroDetalleResponse> => {
  const salidaCobro = await createSalidaCobroRepository(input, operadorId);

  return toSalidaCobroDetalleResponse(salidaCobro);
};
