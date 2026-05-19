import { z } from 'zod';

export const registerSchema = z.object({
  nombre: z.string().trim().min(2, 'El nombre debe tener al menos 2 caracteres'),
  email: z.string().trim().email('El email no es válido').toLowerCase(),
  password: z.string().min(8, 'La contraseña debe tener al menos 8 caracteres'),
  telefono: z.string().trim().min(5).max(20).optional(),
  rol: z.enum(['CLIENTE', 'OPERADOR', 'ADMIN']).default('CLIENTE')
});

export const loginSchema = z.object({
  email: z.string().trim().email('El email no es válido').toLowerCase(),
  password: z.string().min(1, 'La contraseña es obligatoria')
});
