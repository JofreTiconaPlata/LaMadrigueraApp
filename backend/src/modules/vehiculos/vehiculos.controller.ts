import { Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import {
  createVehiculoSchema,
  vehiculoIdParamsSchema,
  vehiculosQuerySchema
} from './vehiculos.schema';
import {
  createVehiculoService,
  deleteVehiculoService,
  getVehiculoByIdService,
  getVehiculosService
} from './vehiculos.service';

const ensureAuthenticated = (
  req: AuthenticatedRequest,
  res: Response
): boolean => {
  if (!req.user) {
    res.status(401).json({
      ok: false,
      message: 'Usuario no autenticado'
    });
    return false;
  }

  return true;
};

const handleVehiculoError = (
  error: unknown,
  res: Response
): boolean => {
  if (error instanceof Error && error.message === 'VEHICULO_NOT_FOUND') {
    res.status(404).json({
      ok: false,
      message: 'Vehículo no encontrado'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'VEHICULO_FORBIDDEN') {
    res.status(403).json({
      ok: false,
      message: 'No puede acceder o modificar vehículos de otro cliente'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'CLIENTE_PROFILE_NOT_FOUND') {
    res.status(404).json({
      ok: false,
      message: 'Perfil de cliente no encontrado'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'VEHICULO_ALREADY_EXISTS') {
    res.status(409).json({
      ok: false,
      message: 'Ya existe un vehículo registrado con esa placa'
    });
    return true;
  }

  return false;
};

export const getVehiculosController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedQuery = vehiculosQuerySchema.safeParse(req.query);

  if (!parsedQuery.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros de consulta inválidos',
      errors: parsedQuery.error.flatten().fieldErrors
    });
    return;
  }

  if (!ensureAuthenticated(req, res)) {
    return;
  }

  try {
    const vehiculos = await getVehiculosService(parsedQuery.data.clienteId, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      data: vehiculos
    });
  } catch (error) {
    if (handleVehiculoError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener vehículos'
    });
  }
};

export const getVehiculoByIdController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedParams = vehiculoIdParamsSchema.safeParse(req.params);

  if (!parsedParams.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros inválidos',
      errors: parsedParams.error.flatten().fieldErrors
    });
    return;
  }

  if (!ensureAuthenticated(req, res)) {
    return;
  }

  try {
    const vehiculo = await getVehiculoByIdService(parsedParams.data.id, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      data: vehiculo
    });
  } catch (error) {
    if (handleVehiculoError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener vehículo'
    });
  }
};

export const createVehiculoController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedBody = createVehiculoSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de vehículo inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  if (!ensureAuthenticated(req, res)) {
    return;
  }

  try {
    const vehiculo = await createVehiculoService(parsedBody.data, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(201).json({
      ok: true,
      message: 'Vehículo creado correctamente',
      data: vehiculo
    });
  } catch (error) {
    if (handleVehiculoError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al crear vehículo'
    });
  }
};

export const deleteVehiculoController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedParams = vehiculoIdParamsSchema.safeParse(req.params);

  if (!parsedParams.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros inválidos',
      errors: parsedParams.error.flatten().fieldErrors
    });
    return;
  }

  if (!ensureAuthenticated(req, res)) {
    return;
  }

  try {
    const vehiculo = await deleteVehiculoService(parsedParams.data.id, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      message: 'Vehículo eliminado correctamente',
      data: vehiculo
    });
  } catch (error) {
    if (handleVehiculoError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al eliminar vehículo'
    });
  }
};
