import { Request, Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import {
  createParqueoBodySchema,
  parqueoIdParamsSchema,
  updateParqueoBodySchema
} from './parqueos.schema';
import {
  createParqueoService,
  deactivateParqueoService,
  getMisParqueosService,
  getParqueoByIdService,
  getParqueosService,
  updateParqueoService
} from './parqueos.service';

const ensureOperador = (
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

  if (req.user.rol !== 'OPERADOR') {
    res.status(403).json({
      ok: false,
      message: 'Solo un operador puede realizar esta acción'
    });
    return false;
  }

  return true;
};

const handleParqueoOwnershipError = (
  error: unknown,
  res: Response
): boolean => {
  if (error instanceof Error && error.message === 'PARQUEO_NOT_FOUND') {
    res.status(404).json({
      ok: false,
      message: 'Parqueo no encontrado'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'PARQUEO_FORBIDDEN') {
    res.status(403).json({
      ok: false,
      message: 'No puede modificar un parqueo de otro operador'
    });
    return true;
  }

  return false;
};

export const getParqueosController = async (
  _req: Request,
  res: Response
): Promise<void> => {
  try {
    const parqueos = await getParqueosService();

    res.status(200).json({
      ok: true,
      data: parqueos
    });
  } catch {
    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener parqueos'
    });
  }
};

export const getMisParqueosController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  if (!ensureOperador(req, res)) {
    return;
  }

  try {
    const parqueos = await getMisParqueosService(req.user!.id);

    res.status(200).json({
      ok: true,
      data: parqueos
    });
  } catch {
    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener los parqueos del operador'
    });
  }
};

export const getParqueoByIdController = async (
  req: Request,
  res: Response
): Promise<void> => {
  const parsedParams = parqueoIdParamsSchema.safeParse(req.params);

  if (!parsedParams.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros inválidos',
      errors: parsedParams.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const parqueo = await getParqueoByIdService(parsedParams.data.id);

    res.status(200).json({
      ok: true,
      data: parqueo
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'PARQUEO_NOT_FOUND') {
      res.status(404).json({
        ok: false,
        message: 'Parqueo no encontrado'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener parqueo'
    });
  }
};

export const createParqueoController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedBody = createParqueoBodySchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  if (!ensureOperador(req, res)) {
    return;
  }

  try {
    const parqueo = await createParqueoService({
      ...parsedBody.data,
      operadorId: req.user!.id
    });

    res.status(201).json({
      ok: true,
      message: 'Parqueo creado correctamente',
      data: parqueo
    });
  } catch (error) {
    if (
      error instanceof Error &&
      error.message === 'MAX_PARQUEOS_OPERADOR'
    ) {
      res.status(409).json({
        ok: false,
        message: 'El operador no puede tener más de 3 parqueos activos'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al crear parqueo'
    });
  }
};

export const updateParqueoController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedParams = parqueoIdParamsSchema.safeParse(req.params);
  const parsedBody = updateParqueoBodySchema.safeParse(req.body);

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
      message: 'Datos inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  if (!ensureOperador(req, res)) {
    return;
  }

  try {
    const parqueo = await updateParqueoService(
      parsedParams.data.id,
      req.user!.id,
      parsedBody.data
    );

    res.status(200).json({
      ok: true,
      message: 'Parqueo actualizado correctamente',
      data: parqueo
    });
  } catch (error) {
    if (handleParqueoOwnershipError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al actualizar parqueo'
    });
  }
};

export const deactivateParqueoController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedParams = parqueoIdParamsSchema.safeParse(req.params);

  if (!parsedParams.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros inválidos',
      errors: parsedParams.error.flatten().fieldErrors
    });
    return;
  }

  if (!ensureOperador(req, res)) {
    return;
  }

  try {
    const parqueo = await deactivateParqueoService(
      parsedParams.data.id,
      req.user!.id
    );

    res.status(200).json({
      ok: true,
      message: 'Parqueo desactivado correctamente',
      data: parqueo
    });
  } catch (error) {
    if (handleParqueoOwnershipError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al desactivar parqueo'
    });
  }
};
