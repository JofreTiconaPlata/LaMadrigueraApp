import {
  EspacioResponse,
  UpdateEstadoEspacioInput
} from './espacios.types';
import {
  findEspacioByIdRepository,
  findEspaciosRepository,
  updateEstadoEspacioRepository
} from './espacios.repository';

const toEspacioResponse = (espacio: {
  id: number;
  parqueoId: number;
  codigo: string;
  tipo: string;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}): EspacioResponse => ({
  id: espacio.id,
  parqueoId: espacio.parqueoId,
  codigo: espacio.codigo,
  tipo: espacio.tipo,
  estado: espacio.estado,
  createdAt: espacio.createdAt,
  updatedAt: espacio.updatedAt
});

export const getEspaciosService = async (
  parqueoId?: number
): Promise<EspacioResponse[]> => {
  const espacios = await findEspaciosRepository(parqueoId);

  return espacios.map(toEspacioResponse);
};

export const getEspacioByIdService = async (
  id: number
): Promise<EspacioResponse> => {
  const espacio = await findEspacioByIdRepository(id);

  if (!espacio) {
    throw new Error('ESPACIO_NOT_FOUND');
  }

  return toEspacioResponse(espacio);
};

export const updateEstadoEspacioService = async (
  id: number,
  input: UpdateEstadoEspacioInput
): Promise<EspacioResponse> => {
  const espacio = await findEspacioByIdRepository(id);

  if (!espacio) {
    throw new Error('ESPACIO_NOT_FOUND');
  }

  const updatedEspacio = await updateEstadoEspacioRepository(id, input);

  return toEspacioResponse(updatedEspacio);
};
