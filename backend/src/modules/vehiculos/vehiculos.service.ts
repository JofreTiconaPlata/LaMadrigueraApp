import {
  CreateVehiculoInput,
  VehiculoResponse
} from './vehiculos.types';
import {
  createVehiculoRepository,
  deleteVehiculoRepository,
  findVehiculoByIdRepository,
  findVehiculoByPlacaRepository,
  findVehiculosRepository
} from './vehiculos.repository';

const toVehiculoResponse = (vehiculo: {
  id: number;
  clienteId: number;
  placa: string;
  tipo: string;
  marca: string | null;
  modelo: string | null;
  color: string | null;
  createdAt: Date;
  updatedAt: Date;
}): VehiculoResponse => ({
  id: vehiculo.id,
  clienteId: vehiculo.clienteId,
  placa: vehiculo.placa,
  tipo: vehiculo.tipo,
  marca: vehiculo.marca,
  modelo: vehiculo.modelo,
  color: vehiculo.color,
  createdAt: vehiculo.createdAt,
  updatedAt: vehiculo.updatedAt
});

export const getVehiculosService = async (
  clienteId?: number
): Promise<VehiculoResponse[]> => {
  const vehiculos = await findVehiculosRepository(clienteId);

  return vehiculos.map(toVehiculoResponse);
};

export const getVehiculoByIdService = async (
  id: number
): Promise<VehiculoResponse> => {
  const vehiculo = await findVehiculoByIdRepository(id);

  if (!vehiculo) {
    throw new Error('VEHICULO_NOT_FOUND');
  }

  return toVehiculoResponse(vehiculo);
};

export const createVehiculoService = async (
  input: CreateVehiculoInput
): Promise<VehiculoResponse> => {
  const existingVehiculo = await findVehiculoByPlacaRepository(input.placa);

  if (existingVehiculo) {
    throw new Error('VEHICULO_ALREADY_EXISTS');
  }

  const vehiculo = await createVehiculoRepository(input);

  return toVehiculoResponse(vehiculo);
};

export const deleteVehiculoService = async (id: number): Promise<VehiculoResponse> => {
  const vehiculo = await findVehiculoByIdRepository(id);

  if (!vehiculo) {
    throw new Error('VEHICULO_NOT_FOUND');
  }

  const deletedVehiculo = await deleteVehiculoRepository(id);

  return toVehiculoResponse(deletedVehiculo);
};
