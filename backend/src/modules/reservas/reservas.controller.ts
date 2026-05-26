import { Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import {
  createReservaSchema,
  reservaIdParamsSchema,
  reservasQuerySchema
} from './reservas.schema';
import {
  createReservaService,
  getMisReservasService,
  getReservaByIdService,
  getReservasService
} from './reservas.service';

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

const handleReservaError = (
  error: unknown,
  res: Response
): boolean => {
  if (error instanceof Error && error.message === 'RESERVA_FORBIDDEN') {
    res.status(403).json({
      ok: false,
      message: 'No puede acceder o modificar reservas no autorizadas'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'RESERVA_NOT_FOUND') {
    res.status(404).json({
      ok: false,
      message: 'Reserva no encontrada'
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

  if (error instanceof Error && error.message === 'VEHICULO_NOT_FOUND') {
    res.status(404).json({
      ok: false,
      message: 'Vehículo no encontrado para el cliente autenticado'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'PARQUEO_NOT_FOUND') {
    res.status(404).json({
      ok: false,
      message: 'Parqueo no encontrado'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'ESPACIO_DISPONIBLE_NOT_FOUND') {
    res.status(409).json({
      ok: false,
      message: 'No hay espacios disponibles para el tipo de vehículo'
    });
    return true;
  }

  return false;
};

export const getReservasController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedQuery = reservasQuerySchema.safeParse(req.query);

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
    const reservas = await getReservasService(parsedQuery.data.clienteId, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      data: reservas
    });
  } catch (error) {
    if (handleReservaError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener reservas'
    });
  }
};

export const getMisReservasController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  if (!ensureAuthenticated(req, res)) {
    return;
  }

  try {
    const reservas = await getMisReservasService({
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      data: reservas
    });
  } catch (error) {
    if (handleReservaError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener mis reservas'
    });
  }
};

export const getReservaByIdController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedParams = reservaIdParamsSchema.safeParse(req.params);

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
    const reserva = await getReservaByIdService(parsedParams.data.id, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      data: reserva
    });
  } catch (error) {
    if (handleReservaError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener reserva'
    });
  }
};

export const createReservaController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedBody = createReservaSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de reserva inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  if (!ensureAuthenticated(req, res)) {
    return;
  }

  try {
    const reserva = await createReservaService(parsedBody.data, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(201).json({
      ok: true,
      message: 'Reserva creada correctamente',
      data: reserva
    });
  } catch (error) {
    if (handleReservaError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al crear reserva'
    });
  }
};
