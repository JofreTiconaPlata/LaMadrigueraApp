import { Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import {
  createIngresoSchema,
  ingresoIdParamsSchema,
  ingresosQuerySchema
} from './ingresos.schema';
import {
  cancelarIngresoService,
  createIngresoService,
  getIngresoByIdService,
  getIngresosActivosService,
  getIngresosService
} from './ingresos.service';

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

const handleIngresoError = (error: unknown, res: Response): void => {
  if (!(error instanceof Error)) {
    res.status(500).json({
      ok: false,
      message: 'Error interno en ingresos'
    });
    return;
  }

  const errorMap: Record<string, { status: number; message: string }> = {
    OPERADOR_NOT_FOUND: { status: 404, message: 'Operador no encontrado' },
    USER_NOT_ALLOWED: { status: 403, message: 'El usuario no tiene permisos para ingresos' },
    PARQUEO_NOT_FOUND: { status: 404, message: 'Parqueo no encontrado' },
    PARQUEO_FORBIDDEN: { status: 403, message: 'No puede gestionar ingresos de un parqueo ajeno' },
    ESPACIO_NOT_FOUND: { status: 404, message: 'Espacio no encontrado' },
    ESPACIO_NOT_IN_PARQUEO: { status: 400, message: 'El espacio no pertenece al parqueo indicado' },
    ESPACIO_NOT_AVAILABLE: { status: 409, message: 'El espacio no está disponible' },
    VEHICULO_NOT_FOUND: { status: 404, message: 'Vehículo no encontrado' },
    VEHICULO_ALREADY_INSIDE: { status: 409, message: 'El vehículo ya tiene un ingreso activo' },
    INGRESO_NOT_FOUND: { status: 404, message: 'Ingreso no encontrado' },
    INGRESO_NOT_ACTIVE: { status: 409, message: 'El ingreso no está activo' },
    INGRESO_FORBIDDEN: { status: 403, message: 'No puede acceder o modificar ingresos de otro operador' }
  };

  const mappedError = errorMap[error.message];

  if (mappedError) {
    res.status(mappedError.status).json({
      ok: false,
      message: mappedError.message
    });
    return;
  }

  res.status(500).json({
    ok: false,
    message: 'Error interno en ingresos'
  });
};

export const getIngresosController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedQuery = ingresosQuerySchema.safeParse(req.query);

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
    const ingresos = await getIngresosService(
      parsedQuery.data.parqueoId,
      parsedQuery.data.estado,
      {
        id: req.user!.id,
        rol: req.user!.rol
      }
    );

    res.status(200).json({
      ok: true,
      data: ingresos
    });
  } catch (error) {
    handleIngresoError(error, res);
  }
};

export const getIngresosActivosController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedQuery = ingresosQuerySchema.pick({ parqueoId: true }).safeParse(req.query);

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
    const ingresos = await getIngresosActivosService(parsedQuery.data.parqueoId, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      data: ingresos
    });
  } catch (error) {
    handleIngresoError(error, res);
  }
};

export const getIngresoByIdController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedParams = ingresoIdParamsSchema.safeParse(req.params);

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
    const ingreso = await getIngresoByIdService(parsedParams.data.id, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      data: ingreso
    });
  } catch (error) {
    handleIngresoError(error, res);
  }
};

export const createIngresoController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  if (!ensureAuthenticated(req, res)) {
    return;
  }

  const parsedBody = createIngresoSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de ingreso inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const ingreso = await createIngresoService(parsedBody.data, req.user!.id);

    res.status(201).json({
      ok: true,
      message: 'Ingreso registrado correctamente',
      data: ingreso
    });
  } catch (error) {
    handleIngresoError(error, res);
  }
};

export const cancelarIngresoController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedParams = ingresoIdParamsSchema.safeParse(req.params);

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
    const ingreso = await cancelarIngresoService(parsedParams.data.id, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      message: 'Ingreso cancelado correctamente',
      data: ingreso
    });
  } catch (error) {
    handleIngresoError(error, res);
  }
};
