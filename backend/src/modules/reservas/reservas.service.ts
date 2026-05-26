import { CreateReservaInput, ReservaResponse } from './reservas.types';
import {
  createReservaConEspacioRepository,
  findClienteByUsuarioIdRepository,
  findParqueoByIdRepository,
  findVehiculoByIdRepository
} from './reservas.repository';

type RolUsuario = 'CLIENTE' | 'OPERADOR' | 'ADMIN';

const toReservaResponse = (reserva: {
  id: number;
  clienteId: number;
  parqueoId: number;
  espacioId: number | null;
  vehiculoId: number;
  fechaInicio: Date;
  fechaFin: Date;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}): ReservaResponse => ({
  id: reserva.id,
  clienteId: reserva.clienteId,
  parqueoId: reserva.parqueoId,
  espacioId: reserva.espacioId,
  vehiculoId: reserva.vehiculoId,
  fechaInicio: reserva.fechaInicio,
  fechaFin: reserva.fechaFin,
  estado: reserva.estado,
  createdAt: reserva.createdAt,
  updatedAt: reserva.updatedAt
});

export const createReservaService = async (
  input: CreateReservaInput,
  usuario: { id: number; rol: RolUsuario }
): Promise<ReservaResponse> => {
  if (usuario.rol !== 'CLIENTE') {
    throw new Error('RESERVA_FORBIDDEN');
  }

  const cliente = await findClienteByUsuarioIdRepository(usuario.id);

  if (!cliente) {
    throw new Error('CLIENTE_PROFILE_NOT_FOUND');
  }

  const vehiculo = await findVehiculoByIdRepository(input.vehiculoId);

  if (!vehiculo || vehiculo.clienteId !== cliente.id) {
    throw new Error('VEHICULO_NOT_FOUND');
  }

  const parqueo = await findParqueoByIdRepository(input.parqueoId);

  if (!parqueo || parqueo.estado !== 'ACTIVO') {
    throw new Error('PARQUEO_NOT_FOUND');
  }

  const reserva = await createReservaConEspacioRepository(
    cliente.id,
    input,
    vehiculo.tipo as 'AUTO' | 'MOTO' | 'CAMIONETA'
  );

  return toReservaResponse(reserva);
};
