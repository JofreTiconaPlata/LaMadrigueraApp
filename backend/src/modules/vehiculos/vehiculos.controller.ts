import { Request, Response } from 'express';
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

export const getVehiculosController = async (req: Request, res: Response): Promise<void> => {
  const parsedQuery = vehiculosQuerySchema.safeParse(req.query);

  if (!parsedQuery.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros de consulta inválidos',
      errors: parsedQuery.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const vehiculos = await getVehiculosService(parsedQuery.data.clienteId);

    res.status(200).json({
      ok: true,
      data: vehiculos
    });
  } catch {
    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener vehículos'
    });
  }
};

export const getVehiculoByIdController = async (req: Request, res: Response): Promise<void> => {
  const parsedParams = vehiculoIdParamsSchema.safeParse(req.params);

  if (!parsedParams.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros inválidos',
      errors: parsedParams.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const vehiculo = await getVehiculoByIdService(parsedParams.data.id);

    res.status(200).json({
      ok: true,
      data: vehiculo
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'VEHICULO_NOT_FOUND') {
      res.status(404).json({
        ok: false,
        message: 'Vehículo no encontrado'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener vehículo'
    });
  }
};

export const createVehiculoController = async (req: Request, res: Response): Promise<void> => {
  const parsedBody = createVehiculoSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de vehículo inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const vehiculo = await createVehiculoService(parsedBody.data);

    res.status(201).json({
      ok: true,
      message: 'Vehículo creado correctamente',
      data: vehiculo
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'VEHICULO_ALREADY_EXISTS') {
      res.status(409).json({
        ok: false,
        message: 'Ya existe un vehículo registrado con esa placa'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al crear vehículo'
    });
  }
};

export const deleteVehiculoController = async (req: Request, res: Response): Promise<void> => {
  const parsedParams = vehiculoIdParamsSchema.safeParse(req.params);

  if (!parsedParams.success) {
    res.status(400).json({
      ok: false,
      message: 'Parámetros inválidos',
      errors: parsedParams.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const vehiculo = await deleteVehiculoService(parsedParams.data.id);

    res.status(200).json({
      ok: true,
      message: 'Vehículo eliminado correctamente',
      data: vehiculo
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'VEHICULO_NOT_FOUND') {
      res.status(404).json({
        ok: false,
        message: 'Vehículo no encontrado'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al eliminar vehículo'
    });
  }
};
