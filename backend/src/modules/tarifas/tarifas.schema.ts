import { z } from 'zod';

export const tarifaIdParamsSchema = z.object({
  id: z.coerce.number().int().positive('El id de la tarifa debe ser válido')
});

export const tarifasQuerySchema = z.object({
  parqueoId: z.coerce.number().int().positive('El id del parqueo debe ser válido').optional(),
  tipoVehiculo: z.enum(['AUTO', 'MOTO', 'CAMIONETA']).optional()
});

export const createTarifaSchema = z.object({
  parqueoId: z.coerce.number().int().positive('El id del parqueo debe ser válido'),
  tipoVehiculo: z.enum(['AUTO', 'MOTO', 'CAMIONETA']),
  montoHora: z.coerce.number().positive('El monto por hora debe ser mayor a 0'),
  montoFraccion: z.coerce.number().positive('El monto por fracción debe ser mayor a 0').optional()
});

export const updateTarifaSchema = z.object({
  montoHora: z.coerce.number().positive('El monto por hora debe ser mayor a 0').optional(),
  montoFraccion: z.coerce.number().positive('El monto por fracción debe ser mayor a 0').optional(),
  estado: z.enum(['ACTIVO', 'INACTIVO']).optional()
}).refine((data) => Object.keys(data).length > 0, {
  message: 'Debe enviar al menos un campo para actualizar'
});
