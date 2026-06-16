export type MetodoPagoInput = "EFECTIVO" | "QR" | "TARJETA" | "TRANSFERENCIA";

export interface SalidaCobroResponse {
  id: number;
  ingresoId: number;
  operadorId: number;
  fechaSalida: Date;
  tiempoTotalMinutos: number;
  montoTotal: number;
  estadoPago: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface SalidaCobroDetalleResponse extends SalidaCobroResponse {
  ingreso: {
    id: number;
    fechaIngreso: Date;
    estado: string;
    parqueo: {
      id: number;
      nombre: string;
      direccion: string;
    };
    espacio: {
      id: number;
      codigo: string;
      tipo: string;
      estado: string;
    };
    vehiculo: {
      id: number;
      placa: string;
      tipo: string;
      marca: string | null;
      modelo: string | null;
      color: string | null;
    };
  };
  operador: {
    id: number;
    nombre: string;
    email: string;
    rol: string;
  };
  pago: {
    id: number;
    metodoPago: string;
    monto: number;
    referencia: string | null;
    estado: string;
    fechaPago: Date;
  } | null;
}

export interface SolicitarSalidaInput {
  ingresoId: number;
}

export interface ValidarPagoInput {
  metodoPago: MetodoPagoInput;
  referencia?: string;
}

/**
 * Compatibilidad temporal con el flujo antiguo.
 * Se eliminará cuando Flutter deje de utilizar POST /salidas-cobros.
 */
export interface CreateSalidaCobroInput {
  ingresoId: number;
  metodoPago?: MetodoPagoInput;
  referencia?: string;
}
