import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  createReservaController,
  getMisReservasController,
  getReservaByIdController,
  getReservasController
} from './reservas.controller';

export const reservasRoutes = Router();

reservasRoutes.get('/', authMiddleware, getReservasController);
reservasRoutes.get('/mis-reservas', authMiddleware, getMisReservasController);
reservasRoutes.post('/', authMiddleware, createReservaController);
reservasRoutes.get('/:id', authMiddleware, getReservaByIdController);
