import { z } from 'zod';

export const vehiculoIdParamsSchema = z.object({
  id: z.coerce.number().int().positive('El id del vehículo debe ser válido')
});

export const vehiculosQuerySchema = z.object({
  clienteId: z.coerce.number().int().positive('El id del cliente debe ser válido').optional()
});

export const createVehiculoSchema = z.object({
  placa: z.string().trim().min(5, 'La placa debe tener al menos 5 caracteres').max(12).toUpperCase(),
  tipo: z.enum(['AUTO', 'MOTO', 'CAMIONETA']),
  marca: z.string().trim().min(1).max(50).optional(),
  modelo: z.string().trim().min(1).max(50).optional(),
  color: z.string().trim().min(1).max(30).optional()
});
