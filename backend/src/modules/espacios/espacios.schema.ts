import { z } from 'zod';

export const espacioIdParamsSchema = z.object({
  id: z.coerce.number().int().positive('El id del espacio debe ser válido')
});

export const espaciosQuerySchema = z.object({
  parqueoId: z.coerce.number().int().positive('El id del parqueo debe ser válido').optional()
});

export const updateEstadoEspacioSchema = z.object({
  estado: z.enum(['DISPONIBLE', 'OCUPADO', 'RESERVADO', 'MANTENIMIENTO'])
});
