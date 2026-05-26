import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import { createReservaController } from './reservas.controller';

export const reservasRoutes = Router();

reservasRoutes.post('/', authMiddleware, createReservaController);
