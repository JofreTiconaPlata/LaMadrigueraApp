export interface ParqueoResponse {
  id: number;
  nombre: string;
  direccion: string;
  latitud: number;
  longitud: number;
  espaciosAutos: number;
  espaciosMotos: number;
  capacidadTotal: number;
  estado: string;
  createdAt: Date;
  updatedAt: Date;
}
