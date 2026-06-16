import { Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import {
  salidaCobroIdParamsSchema,
  salidasCobrosQuerySchema,
  solicitarSalidaSchema,
  validarPagoSchema
} from './salidas-cobros.schema';
import {
  getSalidaCobroByIdService,
  getSalidasCobrosService,
  solicitarSalidaService,
  validarPagoService
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
    CLIENTE_PROFILE_NOT_FOUND: {
      status: 404,
      message: 'No se encontró el perfil del cliente'
    },
    OPERADOR_NOT_FOUND: {
      status: 404,
      message: 'Operador no encontrado'
    },
    USER_NOT_ALLOWED: {
      status: 403,
      message: 'El usuario no tiene permisos para realizar esta operación'
    },
    INGRESO_NOT_FOUND: {
      status: 404,
      message: 'Ingreso no encontrado'
    },
    INGRESO_NOT_ACTIVE: {
      status: 409,
      message: 'El ingreso no está activo'
    },
    ESPACIO_NOT_OCCUPIED: {
      status: 409,
      message: 'El espacio asociado al ingreso no está ocupado'
    },
    SALIDA_ALREADY_EXISTS: {
      status: 409,
      message: 'Ya existe una salida/cobro para este ingreso'
    },
    SALIDA_ALREADY_COMPLETED: {
      status: 409,
      message: 'La salida de este ingreso ya fue procesada'
    },
    SALIDA_COBRO_NOT_FOUND: {
      status: 404,
      message: 'Salida/cobro no encontrada'
    },
    SALIDA_COBRO_FORBIDDEN: {
      status: 403,
      message: 'No tiene acceso a esta salida/cobro'
    },
    SALIDA_COBRO_NOT_PENDING: {
      status: 409,
      message: 'La salida/cobro ya no está pendiente'
    },
    PAGO_ALREADY_EXISTS: {
      status: 409,
      message: 'El pago ya fue registrado'
    },
    TARIFA_NOT_FOUND: {
      status: 404,
      message: 'No existe una tarifa activa para este vehículo'
    }
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

export const solicitarSalidaController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  if (!ensureAuthenticated(req, res)) {
    return;
  }

  const parsedBody = solicitarSalidaSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de solicitud de salida inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const salidaCobro = await solicitarSalidaService(parsedBody.data, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(201).json({
      ok: true,
      message: 'Solicitud de salida registrada correctamente',
      data: salidaCobro
    });
  } catch (error) {
    handleSalidaCobroError(error, res);
  }
};

export const validarPagoController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  if (!ensureAuthenticated(req, res)) {
    return;
  }

  const parsedParams = salidaCobroIdParamsSchema.safeParse(req.params);
  const parsedBody = validarPagoSchema.safeParse(req.body);

  if (!parsedParams.success || !parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de validación de pago inválidos',
      errors: {
        params: parsedParams.success
          ? undefined
          : parsedParams.error.flatten().fieldErrors,
        body: parsedBody.success
          ? undefined
          : parsedBody.error.flatten().fieldErrors
      }
    });
    return;
  }

  try {
    const salidaCobro = await validarPagoService(
      parsedParams.data.id,
      parsedBody.data,
      {
        id: req.user!.id,
        rol: req.user!.rol
      }
    );

    res.status(200).json({
      ok: true,
      message: 'Pago validado y salida finalizada correctamente',
      data: salidaCobro
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
