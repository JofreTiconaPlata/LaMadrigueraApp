import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  getEspacioByIdController,
  getEspaciosController,
  updateEstadoEspacioController
} from './espacios.controller';

export const espaciosRoutes = Router();

espaciosRoutes.get('/', authMiddleware, getEspaciosController);
espaciosRoutes.get('/:id', authMiddleware, getEspacioByIdController);
espaciosRoutes.patch('/:id/estado', authMiddleware, updateEstadoEspacioController);
