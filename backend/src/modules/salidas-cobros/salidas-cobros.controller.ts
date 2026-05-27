import { Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import {
  createSalidaCobroSchema,
  salidaCobroIdParamsSchema,
  salidasCobrosQuerySchema
} from './salidas-cobros.schema';
import {
  createSalidaCobroService,
  getSalidaCobroByIdService,
  getSalidasCobrosService
} from './salidas-cobros.service';

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

const handleSalidaCobroError = (error: unknown, res: Response): void => {
  if (!(error instanceof Error)) {
    res.status(500).json({
      ok: false,
      message: 'Error interno en salidas/cobros'
    });
    return;
  }

  const errorMap: Record<string, { status: number; message: string }> = {
    OPERADOR_NOT_FOUND: { status: 404, message: 'Operador no encontrado' },
    USER_NOT_ALLOWED: { status: 403, message: 'El usuario no tiene permisos para salidas/cobros' },
    INGRESO_NOT_FOUND: { status: 404, message: 'Ingreso no encontrado' },
    INGRESO_NOT_ACTIVE: { status: 409, message: 'El ingreso no está activo' },
    SALIDA_ALREADY_EXISTS: { status: 409, message: 'Ya existe una salida/cobro para este ingreso' },
    SALIDA_COBRO_NOT_FOUND: { status: 404, message: 'Salida/cobro no encontrada' },
    SALIDA_COBRO_FORBIDDEN: { status: 403, message: 'No puede acceder o cobrar ingresos de otro operador' },
    TARIFA_NOT_FOUND: { status: 404, message: 'Tarifa activa no encontrada para este vehículo' }
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
    message: 'Error interno en salidas/cobros'
  });
};

export const getSalidasCobrosController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedQuery = salidasCobrosQuerySchema.safeParse(req.query);

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
    const salidasCobros = await getSalidasCobrosService(
      parsedQuery.data.ingresoId,
      parsedQuery.data.estadoPago,
      {
        id: req.user!.id,
        rol: req.user!.rol
      }
    );

    res.status(200).json({
      ok: true,
      data: salidasCobros
    });
  } catch (error) {
    handleSalidaCobroError(error, res);
  }
};

export const getSalidaCobroByIdController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedParams = salidaCobroIdParamsSchema.safeParse(req.params);

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
    const salidaCobro = await getSalidaCobroByIdService(parsedParams.data.id, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(200).json({
      ok: true,
      data: salidaCobro
    });
  } catch (error) {
    handleSalidaCobroError(error, res);
  }
};

export const createSalidaCobroController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  if (!ensureAuthenticated(req, res)) {
    return;
  }

  const parsedBody = createSalidaCobroSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de salida/cobro inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const salidaCobro = await createSalidaCobroService(
      parsedBody.data,
      req.user!.id
    );

    res.status(201).json({
      ok: true,
      message: 'Salida y cobro registrados correctamente',
      data: salidaCobro
    });
  } catch (error) {
    handleSalidaCobroError(error, res);
  }
};
