import { Request, Response } from 'express';
import {
  createTarifaSchema,
  tarifaIdParamsSchema,
  tarifasQuerySchema,
  updateTarifaSchema
} from './tarifas.schema';
import {
  createTarifaService,
  getTarifaByIdService,
  getTarifasService,
  updateTarifaService
} from './tarifas.service';

export const getTarifasController = async (req: Request, res: Response): Promise<void> => {
  const parsedQuery = tarifasQuerySchema.safeParse(req.query);

  if (!parsedQuery.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros de consulta inválidos',
      errors: parsedQuery.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const tarifas = await getTarifasService(
      parsedQuery.data.parqueoId,
      parsedQuery.data.tipoVehiculo
    );

    res.status(200).json({
      ok: true,
      data: tarifas
    });
  } catch {
    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener tarifas'
    });
  }
};

export const getTarifaByIdController = async (req: Request, res: Response): Promise<void> => {
  const parsedParams = tarifaIdParamsSchema.safeParse(req.params);

  if (!parsedParams.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros inválidos',
      errors: parsedParams.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const tarifa = await getTarifaByIdService(parsedParams.data.id);

    res.status(200).json({
      ok: true,
      data: tarifa
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'TARIFA_NOT_FOUND') {
      res.status(404).json({
        ok: false,
        message: 'Tarifa no encontrada'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener tarifa'
    });
  }
};

export const createTarifaController = async (req: Request, res: Response): Promise<void> => {
  const parsedBody = createTarifaSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de tarifa inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const tarifa = await createTarifaService(parsedBody.data);

    res.status(201).json({
      ok: true,
      message: 'Tarifa creada correctamente',
      data: tarifa
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'TARIFA_ALREADY_EXISTS') {
      res.status(409).json({
        ok: false,
        message: 'Ya existe una tarifa para ese parqueo y tipo de vehículo'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al crear tarifa'
    });
  }
};

export const updateTarifaController = async (req: Request, res: Response): Promise<void> => {
  const parsedParams = tarifaIdParamsSchema.safeParse(req.params);
  const parsedBody = updateTarifaSchema.safeParse(req.body);

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
      message: 'Datos de tarifa inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const tarifa = await updateTarifaService(parsedParams.data.id, parsedBody.data);

    res.status(200).json({
      ok: true,
      message: 'Tarifa actualizada correctamente',
      data: tarifa
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'TARIFA_NOT_FOUND') {
      res.status(404).json({
        ok: false,
        message: 'Tarifa no encontrada'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al actualizar tarifa'
    });
  }
};
