import { Request, Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import { loginSchema, registerSchema } from './auth.schema';
import {
  getAuthenticatedUsuarioService,
  loginUsuarioService,
  registerUsuarioService
} from './auth.service';

export const registerController = async (req: Request, res: Response): Promise<void> => {
  const parsedBody = registerSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de registro inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const result = await registerUsuarioService(parsedBody.data);

    res.status(201).json({
      ok: true,
      message: 'Usuario registrado correctamente',
      data: result
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'EMAIL_ALREADY_EXISTS') {
      res.status(409).json({
        ok: false,
        message: 'El email ya está registrado'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al registrar usuario'
    });
  }
};

export const loginController = async (req: Request, res: Response): Promise<void> => {
  const parsedBody = loginSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(400).json({
      ok: false,
      message: 'Datos de login inválidos',
      errors: parsedBody.error.flatten().fieldErrors
    });
    return;
  }

  try {
    const result = await loginUsuarioService(parsedBody.data);

    res.status(200).json({
      ok: true,
      message: 'Login correcto',
      data: result
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'INVALID_CREDENTIALS') {
      res.status(401).json({
        ok: false,
        message: 'Email o contraseña incorrectos'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al iniciar sesión'
    });
  }
};

export const meController = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  if (!req.user) {
    res.status(401).json({
      ok: false,
      message: 'Usuario no autenticado'
    });
    return;
  }

  try {
    const usuario = await getAuthenticatedUsuarioService(req.user.id);

    res.status(200).json({
      ok: true,
      data: usuario
    });
  } catch (error) {
    if (error instanceof Error && error.message === 'USER_NOT_FOUND') {
      res.status(404).json({
        ok: false,
        message: 'Usuario no encontrado'
      });
      return;
    }

    res.status(500).json({
      ok: false,
      message: 'Error interno al obtener usuario autenticado'
    });
  }
};
