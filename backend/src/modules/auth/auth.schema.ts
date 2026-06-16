import { z } from 'zod';

export const registerSchema = z.object({
  nombre: z.string().trim().min(2, 'El nombre debe tener al menos 2 caracteres'),
  email: z.string().trim().email('El email no es válido').toLowerCase(),
  password: z.string().min(8, 'La contraseña debe tener al menos 8 caracteres'),
  telefono: z.string().trim().min(5).max(20).optional(),
  rol: z.enum(['CLIENTE', 'OPERADOR']).default('CLIENTE')
});

export const loginSchema = z.object({
  email: z.string().trim().email('El email no es válido').toLowerCase(),
  password: z.string().min(1, 'La contraseña es obligatoria')
});

export const updateMeSchema = z
  .object({
    nombre: z
      .string()
      .trim()
      .min(2, 'El nombre debe tener al menos 2 caracteres')
      .max(100, 'El nombre no puede superar 100 caracteres')
      .optional(),
    passwordActual: z.string().min(1, 'La contraseña actual es obligatoria').optional(),
    passwordNueva: z
      .string()
      .min(8, 'La nueva contraseña debe tener al menos 8 caracteres')
      .max(72, 'La nueva contraseña no puede superar 72 caracteres')
      .optional()
  })
  .superRefine((data, ctx) => {
    const cambiaNombre = data.nombre !== undefined;
    const cambiaPassword =
      data.passwordActual !== undefined || data.passwordNueva !== undefined;

    if (!cambiaNombre && !cambiaPassword) {
      ctx.addIssue({
        code: 'custom',
        message: 'Debe enviar al menos un dato para actualizar'
      });
    }

    if (data.passwordNueva !== undefined && data.passwordActual === undefined) {
      ctx.addIssue({
        code: 'custom',
        path: ['passwordActual'],
        message: 'La contraseña actual es obligatoria'
      });
    }

    if (data.passwordActual !== undefined && data.passwordNueva === undefined) {
      ctx.addIssue({
        code: 'custom',
        path: ['passwordNueva'],
        message: 'La nueva contraseña es obligatoria'
      });
    }
  });
