import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  createTarifaController,
  getTarifaByIdController,
  getTarifasController,
  updateTarifaController
} from './tarifas.controller';

export const tarifasRoutes = Router();

tarifasRoutes.get('/', authMiddleware, getTarifasController);
tarifasRoutes.get('/:id', authMiddleware, getTarifaByIdController);
tarifasRoutes.post('/', authMiddleware, createTarifaController);
tarifasRoutes.patch('/:id', authMiddleware, updateTarifaController);
