import bcrypt from 'bcrypt';
import { PrismaClient } from '../src/generated/prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { config } from 'dotenv';

config();

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL
});

const prisma = new PrismaClient({ adapter });

const SALT_ROUNDS = 10;

async function main() {
  const operadorPasswordHash = await bcrypt.hash('Operador123', SALT_ROUNDS);
  const clientePasswordHash = await bcrypt.hash('Cliente123', SALT_ROUNDS);

  const operador = await prisma.usuario.upsert({
    where: { email: 'operador@demo.com' },
    update: {},
    create: {
      nombre: 'Operador Demo',
      email: 'operador@demo.com',
      passwordHash: operadorPasswordHash,
      telefono: '70000001',
      rol: 'OPERADOR'
    }
  });

  const usuarioCliente = await prisma.usuario.upsert({
    where: { email: 'cliente@demo.com' },
    update: {},
    create: {
      nombre: 'Cliente Demo',
      email: 'cliente@demo.com',
      passwordHash: clientePasswordHash,
      telefono: '70000002',
      rol: 'CLIENTE'
    }
  });

  const cliente = await prisma.cliente.upsert({
    where: { usuarioId: usuarioCliente.id },
    update: {},
    create: {
      usuarioId: usuarioCliente.id,
      ci: '1234567'
    }
  });

  const parqueo = await prisma.parqueo.upsert({
    where: { id: 1 },
    update: {
      operadorId: operador.id,
      nombre: 'Parqueo Central La Madriguera',
      direccion: 'Av. América, Cochabamba',
      latitud: -17.3769000,
      longitud: -66.1653000,
      espaciosAutos: 3,
      espaciosMotos: 2,
      capacidadTotal: 5,
      estado: 'ACTIVO'
    },
    create: {
      operadorId: operador.id,
      nombre: 'Parqueo Central La Madriguera',
      direccion: 'Av. América, Cochabamba',
      latitud: -17.3769000,
      longitud: -66.1653000,
      espaciosAutos: 3,
      espaciosMotos: 2,
      capacidadTotal: 5,
      estado: 'ACTIVO'
    }
  });

  const espacios = [
    { codigo: 'A1', tipo: 'AUTO' as const },
    { codigo: 'A2', tipo: 'AUTO' as const },
    { codigo: 'A3', tipo: 'AUTO' as const },
    { codigo: 'M1', tipo: 'MOTO' as const },
    { codigo: 'M2', tipo: 'MOTO' as const }
  ];

  for (const espacio of espacios) {
    await prisma.espacio.upsert({
      where: {
        parqueoId_codigo: {
          parqueoId: parqueo.id,
          codigo: espacio.codigo
        }
      },
      update: {
        tipo: espacio.tipo,
        estado: 'DISPONIBLE'
      },
      create: {
        parqueoId: parqueo.id,
        codigo: espacio.codigo,
        tipo: espacio.tipo,
        estado: 'DISPONIBLE'
      }
    });
  }

  const tarifas = [
    { tipoVehiculo: 'AUTO' as const, montoHora: 5, montoFraccion: 3 },
    { tipoVehiculo: 'MOTO' as const, montoHora: 3, montoFraccion: 2 },
    { tipoVehiculo: 'CAMIONETA' as const, montoHora: 7, montoFraccion: 4 }
  ];

  for (const tarifa of tarifas) {
    await prisma.tarifa.upsert({
      where: {
        parqueoId_tipoVehiculo: {
          parqueoId: parqueo.id,
          tipoVehiculo: tarifa.tipoVehiculo
        }
      },
      update: {
        montoHora: tarifa.montoHora,
        montoFraccion: tarifa.montoFraccion,
        estado: 'ACTIVO'
      },
      create: {
        parqueoId: parqueo.id,
        tipoVehiculo: tarifa.tipoVehiculo,
        montoHora: tarifa.montoHora,
        montoFraccion: tarifa.montoFraccion,
        estado: 'ACTIVO'
      }
    });
  }

  await prisma.vehiculo.upsert({
    where: { placa: 'ABC123' },
    update: {
      clienteId: cliente.id,
      tipo: 'AUTO',
      marca: 'Toyota',
      modelo: 'Corolla',
      color: 'Blanco'
    },
    create: {
      clienteId: cliente.id,
      placa: 'ABC123',
      tipo: 'AUTO',
      marca: 'Toyota',
      modelo: 'Corolla',
      color: 'Blanco'
    }
  });

  console.log('Seed demo ejecutado correctamente');
  console.log({
    operador: {
      id: operador.id,
      email: operador.email,
      password: 'Operador123'
    },
    cliente: {
      id: cliente.id,
      email: usuarioCliente.email,
      password: 'Cliente123'
    },
    parqueoId: parqueo.id,
    vehiculoPlaca: 'ABC123'
  });
}

main()
  .catch((error) => {
    console.error('Error ejecutando seed demo:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
