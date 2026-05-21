import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  createParqueoController,
  getParqueoByIdController,
  getParqueosController
} from './parqueos.controller';

export const parqueosRoutes = Router();

parqueosRoutes.get('/', authMiddleware, getParqueosController);
parqueosRoutes.post('/', authMiddleware, createParqueoController);
parqueosRoutes.get('/:id', authMiddleware, getParqueoByIdController);
