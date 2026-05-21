import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  getParqueoByIdController,
  getParqueosController
} from './parqueos.controller';

export const parqueosRoutes = Router();

parqueosRoutes.get('/', authMiddleware, getParqueosController);
parqueosRoutes.get('/:id', authMiddleware, getParqueoByIdController);
