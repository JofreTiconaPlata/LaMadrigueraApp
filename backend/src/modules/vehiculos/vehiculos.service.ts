import {
  CreateVehiculoBody,
  CreateVehiculoInput,
  VehiculoResponse,
} from './vehiculos.types';

import {
  createClienteByUsuarioIdRepository,
  createVehiculoRepository,
  deleteVehiculoRepository,
  findClienteByUsuarioIdRepository,
  findVehiculoByIdRepository,
  findVehiculoByPlacaRepository,
  findVehiculosRepository,
} from './vehiculos.repository';

type RolUsuario = 'CLIENTE' | 'OPERADOR' | 'ADMIN';

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
  updatedAt: vehiculo.updatedAt,
});

const getOrCreateClienteIdFromUsuario = async (
  usuarioId: number
): Promise<number> => {
  const cliente = await findClienteByUsuarioIdRepository(usuarioId);

  if (cliente) {
    return cliente.id;
  }

  const nuevoCliente = await createClienteByUsuarioIdRepository(usuarioId);
  return nuevoCliente.id;
};

const assertVehiculoBelongsToCliente = async (
  vehiculoId: number,
  clienteId: number
) => {
  const vehiculo = await findVehiculoByIdRepository(vehiculoId);

  if (!vehiculo) {
    throw new Error('VEHICULO_NOT_FOUND');
  }

  if (vehiculo.clienteId !== clienteId) {
    throw new Error('VEHICULO_FORBIDDEN');
  }

  return vehiculo;
};

export const getVehiculosService = async (
  clienteId: number | undefined,
  usuario: { id: number; rol: RolUsuario }
): Promise<VehiculoResponse[]> => {
  if (usuario.rol === 'CLIENTE') {
    const authenticatedClienteId = await getOrCreateClienteIdFromUsuario(
      usuario.id
    );

    const vehiculos = await findVehiculosRepository(authenticatedClienteId);
    return vehiculos.map(toVehiculoResponse);
  }

  if (usuario.rol === 'ADMIN') {
    const vehiculos = await findVehiculosRepository(clienteId);
    return vehiculos.map(toVehiculoResponse);
  }

  throw new Error('VEHICULO_FORBIDDEN');
};

export const getVehiculoByIdService = async (
  id: number,
  usuario: { id: number; rol: RolUsuario }
): Promise<VehiculoResponse> => {
  if (usuario.rol === 'CLIENTE') {
    const clienteId = await getOrCreateClienteIdFromUsuario(usuario.id);
    const vehiculo = await assertVehiculoBelongsToCliente(id, clienteId);
    return toVehiculoResponse(vehiculo);
  }

  if (usuario.rol === 'ADMIN') {
    const vehiculo = await findVehiculoByIdRepository(id);

    if (!vehiculo) {
      throw new Error('VEHICULO_NOT_FOUND');
    }

    return toVehiculoResponse(vehiculo);
  }

  throw new Error('VEHICULO_FORBIDDEN');
};

export const createVehiculoService = async (
  input: CreateVehiculoBody,
  usuario: { id: number; rol: RolUsuario }
): Promise<VehiculoResponse> => {
  if (usuario.rol !== 'CLIENTE') {
    throw new Error('VEHICULO_FORBIDDEN');
  }

  const clienteId = await getOrCreateClienteIdFromUsuario(usuario.id);

  const existingVehiculo = await findVehiculoByPlacaRepository(input.placa);

  if (existingVehiculo) {
    throw new Error('VEHICULO_ALREADY_EXISTS');
  }

  const createInput: CreateVehiculoInput = {
    ...input,
    clienteId,
  };

  const vehiculo = await createVehiculoRepository(createInput);
  return toVehiculoResponse(vehiculo);
};

export const deleteVehiculoService = async (
  id: number,
  usuario: { id: number; rol: RolUsuario }
): Promise<VehiculoResponse> => {
  if (usuario.rol === 'CLIENTE') {
    const clienteId = await getOrCreateClienteIdFromUsuario(usuario.id);
    const vehiculo = await assertVehiculoBelongsToCliente(id, clienteId);
    const deletedVehiculo = await deleteVehiculoRepository(vehiculo.id);
    return toVehiculoResponse(deletedVehiculo);
  }

  if (usuario.rol === 'ADMIN') {
    const vehiculo = await findVehiculoByIdRepository(id);

    if (!vehiculo) {
      throw new Error('VEHICULO_NOT_FOUND');
    }

    const deletedVehiculo = await deleteVehiculoRepository(id);
    return toVehiculoResponse(deletedVehiculo);
  }

  throw new Error('VEHICULO_FORBIDDEN');
};
