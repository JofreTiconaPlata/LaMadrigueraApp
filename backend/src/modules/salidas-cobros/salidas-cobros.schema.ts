import { z } from "zod";

const metodoPagoSchema = z.enum(["EFECTIVO", "QR", "TARJETA", "TRANSFERENCIA"]);

export const salidaCobroIdParamsSchema = z.object({
  id: z.coerce.number().int().positive("El id de salida/cobro debe ser válido"),
});

export const salidasCobrosQuerySchema = z.object({
  ingresoId: z.coerce
    .number()
    .int()
    .positive("El id del ingreso debe ser válido")
    .optional(),
  estadoPago: z.enum(["PENDIENTE", "PAGADO", "ANULADO"]).optional(),
});

export const solicitarSalidaSchema = z.object({
  ingresoId: z.coerce
    .number()
    .int()
    .positive("El id del ingreso debe ser válido"),
});

export const validarPagoSchema = z.object({
  metodoPago: metodoPagoSchema,
  referencia: z.string().trim().min(1).max(100).optional(),
});

/**
 * Compatibilidad temporal con el endpoint antiguo.
 */
export const createSalidaCobroSchema = z.object({
  ingresoId: z.coerce
    .number()
    .int()
    .positive("El id del ingreso debe ser válido"),
  metodoPago: metodoPagoSchema.optional(),
  referencia: z.string().trim().min(1).max(100).optional(),
});
