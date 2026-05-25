import { z } from 'zod';

export const salidaCobroIdParamsSchema = z.object({
  id: z.coerce.number().int().positive('El id de salida/cobro debe ser válido')
});

export const salidasCobrosQuerySchema = z.object({
  ingresoId: z.coerce.number().int().positive('El id del ingreso debe ser válido').optional(),
  estadoPago: z.enum(['PENDIENTE', 'PAGADO', 'ANULADO']).optional()
});

export const createSalidaCobroSchema = z.object({
  ingresoId: z.coerce.number().int().positive('El id del ingreso debe ser válido'),
  metodoPago: z.enum(['EFECTIVO', 'QR', 'TARJETA', 'TRANSFERENCIA']).optional(),
  referencia: z.string().trim().min(1).max(100).optional()
});
