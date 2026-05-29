import {
  CreateParqueoInput,
  ParqueoResponse,
  UpdateParqueoInput
} from './parqueos.types';
import {
  countParqueosActivosByOperadorRepository,
  createParqueoRepository,
  deactivateParqueoRepository,
  findParqueoByIdRepository,
  findParqueosActivosRepository,
  findParqueosByOperadorRepository,
  updateParqueoRepository
} from './parqueos.repository';

const MAX_PARQUEOS_POR_OPERADOR = 20;

const toParqueoResponse = (parqueo: {
  id: number;
  operadorId: number;
  nombre: string;
  direccion: string;
  latitud: unknown;
  longitud: unknown;
  espaciosAutos: number;
  espaciosMotos: number;
  capacidadTotal: number;
  qrPagoUrl: string | null;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}): ParqueoResponse => ({
  id: parqueo.id,
  operadorId: parqueo.operadorId,
  nombre: parqueo.nombre,
  direccion: parqueo.direccion,
  latitud: Number(parqueo.latitud),
  longitud: Number(parqueo.longitud),
  espaciosAutos: parqueo.espaciosAutos,
  espaciosMotos: parqueo.espaciosMotos,
  capacidadTotal: parqueo.capacidadTotal,
  qrPagoUrl: parqueo.qrPagoUrl,
  estado: parqueo.estado,
  createdAt: parqueo.createdAt,
  updatedAt: parqueo.updatedAt
});

const assertParqueoBelongsToOperador = async (
  parqueoId: number,
  operadorId: number
) => {
  const parqueo = await findParqueoByIdRepository(parqueoId);

  if (!parqueo || parqueo.estado !== 'ACTIVO') {
    throw new Error('PARQUEO_NOT_FOUND');
  }

  if (parqueo.operadorId !== operadorId) {
    throw new Error('PARQUEO_FORBIDDEN');
  }

  return parqueo;
};

export const getParqueosService = async (): Promise<ParqueoResponse[]> => {
  const parqueos = await findParqueosActivosRepository();

  return parqueos.map(toParqueoResponse);
};

export const getMisParqueosService = async (
  operadorId: number
): Promise<ParqueoResponse[]> => {
  const parqueos = await findParqueosByOperadorRepository(operadorId);

  return parqueos.map(toParqueoResponse);
};

export const getParqueoByIdService = async (
  id: number
): Promise<ParqueoResponse> => {
  const parqueo = await findParqueoByIdRepository(id);

  if (!parqueo || parqueo.estado !== 'ACTIVO') {
    throw new Error('PARQUEO_NOT_FOUND');
  }

  return toParqueoResponse(parqueo);
};

export const createParqueoService = async (
  input: CreateParqueoInput
): Promise<ParqueoResponse> => {
  const parqueosActivos = await countParqueosActivosByOperadorRepository(
    input.operadorId
  );

  if (parqueosActivos >= MAX_PARQUEOS_POR_OPERADOR) {
    throw new Error('MAX_PARQUEOS_OPERADOR');
  }

  const parqueo = await createParqueoRepository(input);

  return toParqueoResponse(parqueo);
};

export const updateParqueoService = async (
  id: number,
  operadorId: number,
  input: UpdateParqueoInput
): Promise<ParqueoResponse> => {
  await assertParqueoBelongsToOperador(id, operadorId);

  const parqueo = await updateParqueoRepository(id, input);

  return toParqueoResponse(parqueo);
};

export const deactivateParqueoService = async (
  id: number,
  operadorId: number
): Promise<ParqueoResponse> => {
  await assertParqueoBelongsToOperador(id, operadorId);

  const parqueo = await deactivateParqueoRepository(id);

  return toParqueoResponse(parqueo);
};
