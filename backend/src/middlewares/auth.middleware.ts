import jwt from 'jsonwebtoken';
import { NextFunction, Request, Response } from 'express';
import { env } from '../config/env';
import { AuthTokenPayload } from '../modules/auth/auth.types';

export interface AuthenticatedRequest extends Request {
  user?: AuthTokenPayload;
}

export const authMiddleware = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): void => {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    res.status(401).json({
      ok: false,
      message: 'Token no proporcionado'
    });
    return;
  }

  const token = authHeader.replace('Bearer ', '').trim();

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET);

    if (typeof decoded === 'string') {
      res.status(401).json({
        ok: false,
        message: 'Token inválido'
      });
      return;
    }

    req.user = {
      id: Number(decoded.id),
      email: String(decoded.email),
      rol: decoded.rol as AuthTokenPayload['rol']
    };

    next();
  } catch {
    res.status(401).json({
      ok: false,
      message: 'Token inválido o expirado'
    });
  }
};
