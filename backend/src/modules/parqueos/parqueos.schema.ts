import { z } from 'zod';

const qrPagoUrlCreateSchema = z.preprocess(
  (value) => {
    if (
      value === undefined ||
      value === null ||
      (typeof value === 'string' && value.trim() === '')
    ) {
      return undefined;
    }

    return value;
  },
  z.string().trim().url('El QR de pago debe ser una URL válida').optional()
);

const qrPagoUrlUpdateSchema = z.preprocess(
  (value) => {
    if (value === undefined) {
      return undefined;
    }

    if (value === null || (typeof value === 'string' && value.trim() === '')) {
      return null;
    }

    return value;
  },
  z.string().trim().url('El QR de pago debe ser una URL válida').nullable().optional()
);

export const parqueoIdParamsSchema = z.object({
  id: z.coerce.number().int().positive('El id del parqueo debe ser válido'),
});

export const createParqueoBodySchema = z
  .object({
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
    tarifaAutoHora: z.coerce
      .number()
      .positive('La tarifa para autos debe ser mayor a 0'),
    tarifaMotoHora: z.coerce
      .number()
      .positive('La tarifa para motos debe ser mayor a 0'),
    qrPagoUrl: qrPagoUrlCreateSchema,
  })
  .refine((data) => data.espaciosAutos + data.espaciosMotos > 0, {
    message: 'Debe existir al menos un espacio para autos o motos',
    path: ['espaciosAutos'],
  });

export const updateParqueoBodySchema = z
  .object({
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
    qrPagoUrl: qrPagoUrlUpdateSchema,
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: 'Debe enviar al menos un campo para actualizar',
  });
