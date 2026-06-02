import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  cancelReservaController,
  createReservaController,
  getMisReservasController,
  getReservaByIdController,
  getReservasController,
  getReservasOperadorController
} from './reservas.controller';

export const reservasRoutes = Router();

reservasRoutes.get('/', authMiddleware, getReservasController);
reservasRoutes.get('/mis-reservas', authMiddleware, getMisReservasController);
reservasRoutes.get('/operador', authMiddleware, getReservasOperadorController);
reservasRoutes.post('/', authMiddleware, createReservaController);
reservasRoutes.patch('/:id/cancelar', authMiddleware, cancelReservaController);
reservasRoutes.get('/:id', authMiddleware, getReservaByIdController);
