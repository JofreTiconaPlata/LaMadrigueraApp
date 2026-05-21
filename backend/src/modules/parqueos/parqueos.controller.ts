import { Request, Response } from 'express';
import { parqueoIdParamsSchema } from './parqueos.schema';
import {
  getParqueoByIdService,
  getParqueosService
} from './parqueos.service';

export const getParqueosController = async (_req: Request, res: Response): Promise<void> => {
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

export const getParqueoByIdController = async (req: Request, res: Response): Promise<void> => {
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
