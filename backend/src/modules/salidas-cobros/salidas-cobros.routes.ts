import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  getSalidaCobroByIdController,
  getSalidasCobrosController,
  solicitarSalidaController,
  validarPagoController
} from './salidas-cobros.controller';

export const salidasCobrosRoutes = Router();

salidasCobrosRoutes.get('/', authMiddleware, getSalidasCobrosController);

salidasCobrosRoutes.post(
  '/solicitar',
  authMiddleware,
  solicitarSalidaController
);

salidasCobrosRoutes.patch(
  '/:id/validar-pago',
  authMiddleware,
  validarPagoController
);

salidasCobrosRoutes.get(
  '/:id',
  authMiddleware,
  getSalidaCobroByIdController
);
