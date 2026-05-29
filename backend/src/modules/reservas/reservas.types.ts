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
}

export interface CreateReservaInput {
  parqueoId: number;
  vehiculoId: number;
  espacioId?: number;
  fechaInicio: Date;
  fechaFin: Date;
}
