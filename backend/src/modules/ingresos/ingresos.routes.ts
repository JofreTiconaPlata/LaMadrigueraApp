import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  cancelarIngresoController,
  createIngresoController,
  getIngresoByIdController,
  getIngresosActivosController,
  getIngresosController
} from './ingresos.controller';

export const ingresosRoutes = Router();

ingresosRoutes.get('/', authMiddleware, getIngresosController);
ingresosRoutes.get('/activos', authMiddleware, getIngresosActivosController);
ingresosRoutes.get('/:id', authMiddleware, getIngresoByIdController);
ingresosRoutes.post('/', authMiddleware, createIngresoController);
ingresosRoutes.patch('/:id/cancelar', authMiddleware, cancelarIngresoController);
