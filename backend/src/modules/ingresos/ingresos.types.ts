export interface IngresoResponse {
  id: number;
  reservaId: number | null;
  parqueoId: number;
  espacioId: number;
  vehiculoId: number;
  operadorId: number;
  fechaIngreso: Date;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface IngresoDetalleResponse extends IngresoResponse {
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
  operador: {
    id: number;
    nombre: string;
    email: string;
    rol: string;
  };
}

export interface CreateIngresoInput {
  reservaId?: number;
  parqueoId: number;
  espacioId: number;
  vehiculoId: number;
}
