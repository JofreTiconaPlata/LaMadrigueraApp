import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  createVehiculoController,
  deleteVehiculoController,
  getVehiculoByIdController,
  getVehiculosController
} from './vehiculos.controller';

export const vehiculosRoutes = Router();

vehiculosRoutes.get('/', authMiddleware, getVehiculosController);
vehiculosRoutes.get('/:id', authMiddleware, getVehiculoByIdController);
vehiculosRoutes.post('/', authMiddleware, createVehiculoController);
vehiculosRoutes.delete('/:id', authMiddleware, deleteVehiculoController);
