import { Request, Response } from 'express';
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
  } catch (error) {
    console.error('ERROR AL OBTENER PARQUEOS:', error);

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
    console.error('ERROR AL OBTENER PARQUEO POR ID:', error);

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
  req: Request,
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

  try {
    const usuarioAuth =
      (req as any).user ??
      (req as any).usuario ??
      (req as any).auth ??
      (req as any).authUser;

    const operadorId = Number(
      usuarioAuth?.id ??
        usuarioAuth?.userId ??
        usuarioAuth?.usuarioId ??
        usuarioAuth?.idUsuario ??
        usuarioAuth?.sub ??
        (req as any).userId ??
        (req as any).usuarioId ??
        (req as any).idUsuario
    );

    console.log('OPERADOR ID DETECTADO:', operadorId);

    if (!Number.isInteger(operadorId) || operadorId <= 0) {
      res.status(401).json({
        ok: false,
        message: 'No se pudo identificar al operador autenticado'
      });
      return;
    }

    const parqueo = await createParqueoService({
      ...parsedBody.data,
      operadorId
    });

    res.status(201).json({
      ok: true,
      message: 'Parqueo creado correctamente',
      data: parqueo
    });
  } catch (error) {
    console.error('ERROR AL CREAR PARQUEO:', error);

    res.status(500).json({
      ok: false,
      message: 'Error interno al crear parqueo'
    });
  }
};