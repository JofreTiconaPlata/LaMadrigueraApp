export interface TarifaResponse {
  id: number;
  parqueoId: number;
  tipoVehiculo: string;
  montoHora: number;
  montoFraccion: number | null;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateTarifaInput {
  parqueoId: number;
  tipoVehiculo: 'AUTO' | 'MOTO' | 'CAMIONETA';
  montoHora: number;
  montoFraccion?: number;
}

export interface UpdateTarifaInput {
  montoHora?: number;
  montoFraccion?: number;
  estado?: 'ACTIVO' | 'INACTIVO';
}
