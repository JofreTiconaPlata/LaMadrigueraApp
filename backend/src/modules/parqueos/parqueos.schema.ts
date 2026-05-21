import { z } from 'zod';

export const parqueoIdParamsSchema = z.object({
  id: z.coerce.number().int().positive('El id del parqueo debe ser válido')
});

export const createParqueoBodySchema = z.object({
  nombre: z.string().trim().min(2, 'El nombre es obligatorio'),
  direccion: z.string().trim().min(2, 'La dirección es obligatoria'),
  latitud: z.coerce
    .number()
    .min(-90, 'La latitud debe ser válida')
    .max(90, 'La latitud debe ser válida'),
  longitud: z.coerce
    .number()
    .min(-180, 'La longitud debe ser válida')
    .max(180, 'La longitud debe ser válida'),
  espaciosAutos: z.coerce
    .number()
    .int()
    .min(0, 'Los espacios para autos no pueden ser negativos'),
  espaciosMotos: z.coerce
    .number()
    .int()
    .min(0, 'Los espacios para motos no pueden ser negativos')
});
