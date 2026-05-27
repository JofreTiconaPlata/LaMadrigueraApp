import { z } from 'zod';

export const reservaIdParamsSchema = z.object({
  id: z.coerce.number().int().positive('El id de la reserva debe ser válido'),
});

export const reservasQuerySchema = z.object({
  clienteId: z.coerce
    .number()
    .int()
    .positive('El id del cliente debe ser válido')
    .optional(),
});

export const createReservaSchema = z
  .object({
    parqueoId: z.coerce
      .number()
      .int()
      .positive('El id del parqueo debe ser válido'),
    vehiculoId: z.coerce
      .number()
      .int()
      .positive('El id del vehículo debe ser válido'),
    espacioId: z.coerce
      .number()
      .int()
      .positive('El id del espacio debe ser válido')
      .optional(),
    fechaInicio: z.coerce.date(),
    fechaFin: z.coerce.date(),
  })
  .refine((data) => data.fechaFin > data.fechaInicio, {
    message: 'La fecha fin debe ser posterior a la fecha inicio',
    path: ['fechaFin'],
  });
