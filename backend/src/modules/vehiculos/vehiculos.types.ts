export interface VehiculoResponse {
  id: number;
  clienteId: number;
  placa: string;
  tipo: string;
  marca: string | null;
  modelo: string | null;
  color: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateVehiculoInput {
  clienteId: number;
  placa: string;
  tipo: 'AUTO' | 'MOTO' | 'CAMIONETA';
  marca?: string;
  modelo?: string;
  color?: string;
}
