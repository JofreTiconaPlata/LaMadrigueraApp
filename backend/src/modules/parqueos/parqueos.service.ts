import { ParqueoResponse } from './parqueos.types';
import {
  findParqueoByIdRepository,
  findParqueosActivosRepository
} from './parqueos.repository';

const toParqueoResponse = (parqueo: {
  id: number;
  nombre: string;
  direccion: string;
  latitud: unknown;
  longitud: unknown;
  espaciosAutos: number;
  espaciosMotos: number;
  capacidadTotal: number;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}): ParqueoResponse => ({
  id: parqueo.id,
  nombre: parqueo.nombre,
  direccion: parqueo.direccion,
  latitud: Number(parqueo.latitud),
  longitud: Number(parqueo.longitud),
  espaciosAutos: parqueo.espaciosAutos,
  espaciosMotos: parqueo.espaciosMotos,
  capacidadTotal: parqueo.capacidadTotal,
  estado: parqueo.estado,
  createdAt: parqueo.createdAt,
  updatedAt: parqueo.updatedAt
});

export const getParqueosService = async (): Promise<ParqueoResponse[]> => {
  const parqueos = await findParqueosActivosRepository();

  return parqueos.map(toParqueoResponse);
};

export const getParqueoByIdService = async (id: number): Promise<ParqueoResponse> => {
  const parqueo = await findParqueoByIdRepository(id);

  if (!parqueo) {
    throw new Error('PARQUEO_NOT_FOUND');
  }

  return toParqueoResponse(parqueo);
};
