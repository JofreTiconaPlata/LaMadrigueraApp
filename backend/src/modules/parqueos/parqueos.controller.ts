import { Request, Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import {
  createParqueoBodySchema,
  parqueoIdParamsSchema
} from './parqueos.schema';
import {
  createParqueoService,
  getParqueoByIdService,
  getParqueosService
} from './parqueos.service';

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

  if (!req.user) {
    res.status(401).json({
      ok: false,
      message: 'Usuario no autenticado'
    });
    return;
  }

  if (req.user.rol !== 'OPERADOR') {
    res.status(403).json({
      ok: false,
      message: 'Solo un operador puede crear parqueos'
    });
    return;
  }

  try {
    const parqueo = await createParqueoService({
      ...parsedBody.data,
      operadorId: req.user.id
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
