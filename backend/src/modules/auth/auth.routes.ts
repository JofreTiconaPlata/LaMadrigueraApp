import { Router } from 'express';
import { authMiddleware } from '../../middlewares/auth.middleware';
import {
  loginController,
  meController,
  registerController
} from './auth.controller';

export const authRoutes = Router();

authRoutes.post('/register', registerController);
authRoutes.post('/login', loginController);
authRoutes.get('/me', authMiddleware, meController);
