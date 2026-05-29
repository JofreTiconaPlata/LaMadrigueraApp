import {
  EspacioResponse,
  UpdateEstadoEspacioInput
} from './espacios.types';
import {
  findEspacioByIdRepository,
  findEspaciosByOperadorRepository,
  findEspaciosRepository,
  updateEstadoEspacioRepository
} from './espacios.repository';

type RolUsuario = 'CLIENTE' | 'OPERADOR' | 'ADMIN';

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
  parqueoId: number | undefined,
  usuario: { id: number; rol: RolUsuario }
): Promise<EspacioResponse[]> => {
  const espacios =
    usuario.rol === 'OPERADOR'
      ? await findEspaciosByOperadorRepository(usuario.id, parqueoId)
      : await findEspaciosRepository(parqueoId);

  return espacios.map(toEspacioResponse);
};

export const getEspacioByIdService = async (
  id: number,
  usuario: { id: number; rol: RolUsuario }
): Promise<EspacioResponse> => {
  const espacio = await findEspacioByIdRepository(id);

  if (!espacio || espacio.parqueo.estado !== 'ACTIVO') {
    throw new Error('ESPACIO_NOT_FOUND');
  }

  if (
    usuario.rol === 'OPERADOR' &&
    espacio.parqueo.operadorId !== usuario.id
  ) {
    throw new Error('ESPACIO_FORBIDDEN');
  }

  return toEspacioResponse(espacio);
};

export const updateEstadoEspacioService = async (
  id: number,
  input: UpdateEstadoEspacioInput,
  usuario: { id: number; rol: RolUsuario }
): Promise<EspacioResponse> => {
  const espacio = await findEspacioByIdRepository(id);

  if (!espacio || espacio.parqueo.estado !== 'ACTIVO') {
    throw new Error('ESPACIO_NOT_FOUND');
  }

  if (usuario.rol !== 'OPERADOR' && usuario.rol !== 'ADMIN') {
    throw new Error('ESPACIO_FORBIDDEN');
  }

  if (
    usuario.rol === 'OPERADOR' &&
    espacio.parqueo.operadorId !== usuario.id
  ) {
    throw new Error('ESPACIO_FORBIDDEN');
  }

  const updatedEspacio = await updateEstadoEspacioRepository(id, input);

  return toEspacioResponse(updatedEspacio);
};
