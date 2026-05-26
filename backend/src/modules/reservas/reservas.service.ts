import { CreateReservaInput, ReservaResponse } from './reservas.types';
import {
  cancelReservaRepository,
  createReservaConEspacioRepository,
  findClienteByUsuarioIdRepository,
  findParqueoByIdRepository,
  findReservaByIdRepository,
  findReservasRepository,
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

const getClienteIdFromUsuario = async (usuarioId: number): Promise<number> => {
  const cliente = await findClienteByUsuarioIdRepository(usuarioId);

  if (!cliente) {
    throw new Error('CLIENTE_PROFILE_NOT_FOUND');
  }

  return cliente.id;
};

const assertReservaBelongsToCliente = async (
  reservaId: number,
  clienteId: number
) => {
  const reserva = await findReservaByIdRepository(reservaId);

  if (!reserva) {
    throw new Error('RESERVA_NOT_FOUND');
  }

  if (reserva.clienteId !== clienteId) {
    throw new Error('RESERVA_FORBIDDEN');
  }

  return reserva;
};

export const getReservasService = async (
  clienteId: number | undefined,
  usuario: { id: number; rol: RolUsuario }
): Promise<ReservaResponse[]> => {
  if (usuario.rol !== 'ADMIN') {
    throw new Error('RESERVA_FORBIDDEN');
  }

  const reservas = await findReservasRepository(clienteId);

  return reservas.map(toReservaResponse);
};

export const getMisReservasService = async (
  usuario: { id: number; rol: RolUsuario }
): Promise<ReservaResponse[]> => {
  if (usuario.rol !== 'CLIENTE') {
    throw new Error('RESERVA_FORBIDDEN');
  }

  const clienteId = await getClienteIdFromUsuario(usuario.id);
  const reservas = await findReservasRepository(clienteId);

  return reservas.map(toReservaResponse);
};

export const getReservaByIdService = async (
  id: number,
  usuario: { id: number; rol: RolUsuario }
): Promise<ReservaResponse> => {
  if (usuario.rol === 'CLIENTE') {
    const clienteId = await getClienteIdFromUsuario(usuario.id);
    const reserva = await assertReservaBelongsToCliente(id, clienteId);

    return toReservaResponse(reserva);
  }

  if (usuario.rol === 'ADMIN') {
    const reserva = await findReservaByIdRepository(id);

    if (!reserva) {
      throw new Error('RESERVA_NOT_FOUND');
    }

    return toReservaResponse(reserva);
  }

  throw new Error('RESERVA_FORBIDDEN');
};

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

export const cancelReservaService = async (
  id: number,
  usuario: { id: number; rol: RolUsuario }
): Promise<ReservaResponse> => {
  if (usuario.rol === 'CLIENTE') {
    const clienteId = await getClienteIdFromUsuario(usuario.id);
    const reserva = await assertReservaBelongsToCliente(id, clienteId);

    if (reserva.estado !== 'ACTIVA' && reserva.estado !== 'PENDIENTE') {
      throw new Error('RESERVA_NOT_CANCELABLE');
    }

    const reservaCancelada = await cancelReservaRepository(id);

    return toReservaResponse(reservaCancelada);
  }

  if (usuario.rol === 'ADMIN') {
    const reserva = await findReservaByIdRepository(id);

    if (!reserva) {
      throw new Error('RESERVA_NOT_FOUND');
    }

    if (reserva.estado !== 'ACTIVA' && reserva.estado !== 'PENDIENTE') {
      throw new Error('RESERVA_NOT_CANCELABLE');
    }

    const reservaCancelada = await cancelReservaRepository(id);

    return toReservaResponse(reservaCancelada);
  }

  throw new Error('RESERVA_FORBIDDEN');
};
