import { z } from 'zod';

export const parqueoIdParamsSchema = z.object({
  id: z.coerce.number().int().positive('El id del parqueo debe ser válido')
});
