import { PrismaClient } from '../generated/prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { env } from './env';

const adapter = new PrismaPg({
  connectionString: env.DATABASE_URL
});

export const prisma = new PrismaClient({
  adapter,
  log: env.NODE_ENV === 'development'
    ? ['query', 'info', 'warn', 'error']
    : ['warn', 'error']
});


