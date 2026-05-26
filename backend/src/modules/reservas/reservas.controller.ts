import { Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import { createReservaSchema } from './reservas.schema';
import { createReservaService } from './reservas.service';

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

const handleReservaError = (
  error: unknown,
  res: Response
): boolean => {
  if (error instanceof Error && error.message === 'RESERVA_FORBIDDEN') {
    res.status(403).json({
      ok: false,
      message: 'Solo un cliente puede crear reservas'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'CLIENTE_PROFILE_NOT_FOUND') {
    res.status(404).json({
      ok: false,
      message: 'Perfil de cliente no encontrado'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'VEHICULO_NOT_FOUND') {
    res.status(404).json({
      ok: false,
      message: 'Vehículo no encontrado para el cliente autenticado'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'PARQUEO_NOT_FOUND') {
    res.status(404).json({
      ok: false,
      message: 'Parqueo no encontrado'
    });
    return true;
  }

  if (error instanceof Error && error.message === 'ESPACIO_DISPONIBLE_NOT_FOUND') {
    res.status(409).json({
      ok: false,
      message: 'No hay espacios disponibles para el tipo de vehículo'
    });
    return true;
  }

  return false;
};

export const createReservaController = async (
  req: AuthenticatedRequest,
  res: Response
): Promise<void> => {
  const parsedBody = createReservaSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de reserva inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  if (!ensureAuthenticated(req, res)) {
    return;
  }

  try {
    const reserva = await createReservaService(parsedBody.data, {
      id: req.user!.id,
      rol: req.user!.rol
    });

    res.status(201).json({
      ok: true,
      message: 'Reserva creada correctamente',
      data: reserva
    });
  } catch (error) {
    if (handleReservaError(error, res)) {
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al crear reserva'
    });
  }
};
