export interface ReservaParqueoResponse {
  id: number;
  nombre: string;
  direccion: string;
}

export interface ReservaVehiculoResponse {
  id: number;
  placa: string;
  tipo: string;
}

export interface ReservaEspacioResponse {
  id: number;
  codigo: string;
  tipo: string;
}

export interface ReservaResponse {
  id: number;
  clienteId: number;
  parqueoId: number;
  espacioId: number | null;
  vehiculoId: number;
  fechaInicio: Date;
  fechaFin: Date;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
  parqueo?: ReservaParqueoResponse;
  vehiculo?: ReservaVehiculoResponse;
  espacio?: ReservaEspacioResponse | null;
}

export interface CreateReservaInput {
  parqueoId: number;
  vehiculoId: number;
  espacioId?: number;
  fechaInicio: Date;
  fechaFin: Date;
}
