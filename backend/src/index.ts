import express from 'express';
import cors from 'cors';
import { env } from './config/env';
import { authRoutes } from './modules/auth/auth.routes';
import { parqueosRoutes } from './modules/parqueos/parqueos.routes';
import { espaciosRoutes } from './modules/espacios/espacios.routes';
import { tarifasRoutes } from './modules/tarifas/tarifas.routes';
import { vehiculosRoutes } from './modules/vehiculos/vehiculos.routes';
import { ingresosRoutes } from './modules/ingresos/ingresos.routes';
import { salidasCobrosRoutes } from './modules/salidas-cobros/salidas-cobros.routes';

const app = express();

app.use(cors({
  origin: env.FRONTEND_URL === '*' ? true : env.FRONTEND_URL,
  credentials: true
}));

app.use(express.json());

app.get('/health', (_req, res) => {
  res.status(200).json({
    ok: true,
    service: 'LaMadrigueraApp Backend',
    environment: env.NODE_ENV,
    timestamp: new Date().toISOString()
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/parqueos', parqueosRoutes);
app.use('/api/espacios', espaciosRoutes);
app.use('/api/tarifas', tarifasRoutes);
app.use('/api/vehiculos', vehiculosRoutes);
app.use('/api/ingresos', ingresosRoutes);
app.use('/api/salidas-cobros', salidasCobrosRoutes);

app.use((_req, res) => {
  res.status(404).json({
    ok: false,
    message: 'Route not found'
  });
});

app.listen(env.PORT, () => {
  console.log(`Backend running on http://localhost:${env.PORT}`);
});