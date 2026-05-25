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

export interface CreateSalidaCobroInput {
  ingresoId: number;
  metodoPago?: 'EFECTIVO' | 'QR' | 'TARJETA' | 'TRANSFERENCIA';
  referencia?: string;
}
