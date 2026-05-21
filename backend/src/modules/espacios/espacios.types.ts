export interface EspacioResponse {
  id: number;
  parqueoId: number;
  codigo: string;
  tipo: string;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface UpdateEstadoEspacioInput {
  estado: 'DISPONIBLE' | 'OCUPADO' | 'RESERVADO' | 'MANTENIMIENTO';
}
