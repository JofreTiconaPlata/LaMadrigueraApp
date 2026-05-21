import { z } from 'zod';

export const ingresoIdParamsSchema = z.object({
  id: z.coerce.number().int().positive('El id del ingreso debe ser válido')
});

export const ingresosQuerySchema = z.object({
  parqueoId: z.coerce.number().int().positive('El id del parqueo debe ser válido').optional(),
  estado: z.enum(['ACTIVO', 'FINALIZADO', 'CANCELADO']).optional()
});

export const createIngresoSchema = z.object({
  parqueoId: z.coerce.number().int().positive('El id del parqueo debe ser válido'),
  espacioId: z.coerce.number().int().positive('El id del espacio debe ser válido'),
  vehiculoId: z.coerce.number().int().positive('El id del vehículo debe ser válido')
});
