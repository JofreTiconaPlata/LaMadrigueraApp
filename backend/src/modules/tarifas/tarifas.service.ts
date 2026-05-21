import {
  CreateTarifaInput,
  TarifaResponse,
  UpdateTarifaInput
} from './tarifas.types';
import {
  createTarifaRepository,
  findTarifaByIdRepository,
  findTarifaByParqueoAndTipoRepository,
  findTarifasRepository,
  updateTarifaRepository
} from './tarifas.repository';

const toTarifaResponse = (tarifa: {
  id: number;
  parqueoId: number;
  tipoVehiculo: string;
  montoHora: unknown;
  montoFraccion: unknown | null;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}): TarifaResponse => ({
  id: tarifa.id,
  parqueoId: tarifa.parqueoId,
  tipoVehiculo: tarifa.tipoVehiculo,
  montoHora: Number(tarifa.montoHora),
  montoFraccion: tarifa.montoFraccion === null ? null : Number(tarifa.montoFraccion),
  estado: tarifa.estado,
  createdAt: tarifa.createdAt,
  updatedAt: tarifa.updatedAt
});

export const getTarifasService = async (
  parqueoId?: number,
  tipoVehiculo?: 'AUTO' | 'MOTO' | 'CAMIONETA'
): Promise<TarifaResponse[]> => {
  const tarifas = await findTarifasRepository(parqueoId, tipoVehiculo);

  return tarifas.map(toTarifaResponse);
};

export const getTarifaByIdService = async (id: number): Promise<TarifaResponse> => {
  const tarifa = await findTarifaByIdRepository(id);

  if (!tarifa) {
    throw new Error('TARIFA_NOT_FOUND');
  }

  return toTarifaResponse(tarifa);
};

export const createTarifaService = async (
  input: CreateTarifaInput
): Promise<TarifaResponse> => {
  const existingTarifa = await findTarifaByParqueoAndTipoRepository(
    input.parqueoId,
    input.tipoVehiculo
  );

  if (existingTarifa) {
    throw new Error('TARIFA_ALREADY_EXISTS');
  }

  const tarifa = await createTarifaRepository(input);

  return toTarifaResponse(tarifa);
};

export const updateTarifaService = async (
  id: number,
  input: UpdateTarifaInput
): Promise<TarifaResponse> => {
  const tarifa = await findTarifaByIdRepository(id);

  if (!tarifa) {
    throw new Error('TARIFA_NOT_FOUND');
  }

  const updatedTarifa = await updateTarifaRepository(id, input);

  return toTarifaResponse(updatedTarifa);
};
