import { Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import {
  espacioIdParamsSchema,
  espaciosQuerySchema,
  updateEstadoEspacioSchema
} from './espacios.schema';
import {
  getEspacioByIdService,
  getEspaciosService,
  updateEstadoEspacioService
} from './espacios.service';

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

const handleEspacioAccessError = (
  error: unknown,
  res: Response
): boolean => {
  if (error instanceof Error && error.message === 'ESPACIO_NOT_FOUND') {
    res.status(404).json({
      ok: false,
      message: 'Espacio no encontrado'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'ESPACIO_FORBIDDEN') {
    res.status(403).json({
      ok: false,
      message: 'No puede acceder o modificar espacios de otro operador'
    });
    return true;
  }

  return false;
};

export const getEspaciosController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedQuery = espaciosQuerySchema.safeParse(req.query);

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
    const espacios = await getEspaciosService(parsedQuery.data.parqueoId, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      data: espacios
    });
  } catch (error) {
    if (handleEspacioAccessError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener espacios'
    });
  }
};

export const getEspacioByIdController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedParams = espacioIdParamsSchema.safeParse(req.params);

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
    const espacio = await getEspacioByIdService(parsedParams.data.id, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      data: espacio
    });
  } catch (error) {
    if (handleEspacioAccessError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener espacio'
    });
  }
};

export const updateEstadoEspacioController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedParams = espacioIdParamsSchema.safeParse(req.params);
  const parsedBody = updateEstadoEspacioSchema.safeParse(req.body);

  if (!parsedParams.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros inválidos',
      errors: parsedParams.error.flatten().fieldErrors
    });
    return;
  }

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de estado inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  if (!ensureAuthenticated(req, res)) {
    return;
  }

  try {
    const espacio = await updateEstadoEspacioService(
      parsedParams.data.id,
      parsedBody.data,
      {
        id: req.user!.id,
        rol: req.user!.rol
      }
    );

    res.status(200).json({
      ok: true,
      message: 'Estado de espacio actualizado correctamente',
      data: espacio
    });
  } catch (error) {
    if (handleEspacioAccessError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al actualizar espacio'
    });
  }
};
