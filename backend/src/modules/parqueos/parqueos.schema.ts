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
    .min(0, 'Los espacios para autos no pueden ser negativos')
    .max(20, 'Los espacios para autos no pueden superar 20'),
  espaciosMotos: z.coerce
    .number()
    .int()
    .min(0, 'Los espacios para motos no pueden ser negativos')
    .max(10, 'Los espacios para motos no pueden superar 10'),
  qrPagoUrl: z.string().trim().url('El QR de pago debe ser una URL válida').optional()
}).refine(
  (data) => data.espaciosAutos + data.espaciosMotos > 0,
  {
    message: 'Debe existir al menos un espacio para autos o motos',
    path: ['espaciosAutos']
  }
);

export const updateParqueoBodySchema = z.object({
  nombre: z.string().trim().min(2, 'El nombre es obligatorio').optional(),
  direccion: z.string().trim().min(2, 'La dirección es obligatoria').optional(),
  latitud: z.coerce
    .number()
    .min(-90, 'La latitud debe ser válida')
    .max(90, 'La latitud debe ser válida')
    .optional(),
  longitud: z.coerce
    .number()
    .min(-180, 'La longitud debe ser válida')
    .max(180, 'La longitud debe ser válida')
    .optional(),
  qrPagoUrl: z
    .string()
    .trim()
    .url('El QR de pago debe ser una URL válida')
    .nullable()
    .optional()
}).refine(
  (data) => Object.keys(data).length > 0,
  {
    message: 'Debe enviar al menos un campo para actualizar'
  }
);
