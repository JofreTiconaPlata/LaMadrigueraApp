import { Request, Response } from 'express';
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

export const getEspaciosController = async (req: Request, res: Response): Promise<void> => {
  const parsedQuery = espaciosQuerySchema.safeParse(req.query);

  if (!parsedQuery.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros de consulta inválidos',
      errors: parsedQuery.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const espacios = await getEspaciosService(parsedQuery.data.parqueoId);

    res.status(200).json({
      ok: true,
      data: espacios
    });
  } catch {
    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener espacios'
    });
  }
};

export const getEspacioByIdController = async (req: Request, res: Response): Promise<void> => {
  const parsedParams = espacioIdParamsSchema.safeParse(req.params);

  if (!parsedParams.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros inválidos',
      errors: parsedParams.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const espacio = await getEspacioByIdService(parsedParams.data.id);

    res.status(200).json({
      ok: true,
      data: espacio
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'ESPACIO_NOT_FOUND') {
      res.status(404).json({
        ok: false,
        message: 'Espacio no encontrado'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener espacio'
    });
  }
};

export const updateEstadoEspacioController = async (
  req: Request,
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

  try {
    const espacio = await updateEstadoEspacioService(
      parsedParams.data.id,
      parsedBody.data
    );

    res.status(200).json({
      ok: true,
      message: 'Estado de espacio actualizado correctamente',
      data: espacio
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'ESPACIO_NOT_FOUND') {
      res.status(404).json({
        ok: false,
        message: 'Espacio no encontrado'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al actualizar espacio'
    });
  }
};
