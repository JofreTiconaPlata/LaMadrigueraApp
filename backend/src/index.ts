import express from 'express';
import cors from 'cors';
import { env } from './config/env';

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

app.use((_req, res) => {
  res.status(404).json({
    ok: false,
    message: 'Route not found'
  });
});

app.listen(env.PORT, () => {
  console.log(`Backend running on http://localhost:${env.PORT}`);
});
