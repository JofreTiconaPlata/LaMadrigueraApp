export interface ParqueoResponse {
  id: number;
  operadorId: number;
  nombre: string;
  direccion: string;
  latitud: number;
  longitud: number;
  espaciosAutos: number;
  espaciosMotos: number;
  capacidadTotal: number;
  qrPagoUrl: string | null;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateParqueoInput {
  operadorId: number;
  nombre: string;
  direccion: string;
  latitud: number;
  longitud: number;
  espaciosAutos: number;
  espaciosMotos: number;
  qrPagoUrl?: string | null;
}

export interface UpdateParqueoInput {
  nombre?: string;
  direccion?: string;
  latitud?: number;
  longitud?: number;
  qrPagoUrl?: string | null;
}
