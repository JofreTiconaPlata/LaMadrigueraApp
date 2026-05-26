import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  createParqueoController,
  deactivateParqueoController,
  getMisParqueosController,
  getParqueoByIdController,
  getParqueosController,
  updateParqueoController
} from './parqueos.controller';

export const parqueosRoutes = Router();

parqueosRoutes.get('/', authMiddleware, getParqueosController);
parqueosRoutes.get('/mios', authMiddleware, getMisParqueosController);
parqueosRoutes.post('/', authMiddleware, createParqueoController);
parqueosRoutes.get('/:id', authMiddleware, getParqueoByIdController);
parqueosRoutes.put('/:id', authMiddleware, updateParqueoController);
parqueosRoutes.delete('/:id', authMiddleware, deactivateParqueoController);
