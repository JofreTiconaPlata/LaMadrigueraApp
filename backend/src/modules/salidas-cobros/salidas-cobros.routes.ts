import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  createSalidaCobroController,
  getSalidaCobroByIdController,
  getSalidasCobrosController
} from './salidas-cobros.controller';

export const salidasCobrosRoutes = Router();

salidasCobrosRoutes.get('/', authMiddleware, getSalidasCobrosController);
salidasCobrosRoutes.get('/:id', authMiddleware, getSalidaCobroByIdController);
salidasCobrosRoutes.post('/', authMiddleware, createSalidaCobroController);
