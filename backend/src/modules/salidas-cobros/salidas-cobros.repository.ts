import { prisma } from "../../config/prisma";
import {
  CreateSalidaCobroInput,
  SolicitarSalidaInput,
  ValidarPagoInput,
} from "./salidas-cobros.types";

const includeSalidaCobroDetalle = {
  ingreso: {
    select: {
      id: true,
      fechaIngreso: true,
      estado: true,
      parqueo: {
        select: {
          id: true,
          nombre: true,
          direccion: true,
          operadorId: true,
        },
      },
      espacio: {
        select: {
          id: true,
          codigo: true,
          tipo: true,
          estado: true,
        },
      },
      vehiculo: {
        select: {
          id: true,
          placa: true,
          tipo: true,
          marca: true,
          modelo: true,
          color: true,
        },
      },
    },
  },
  operador: {
    select: {
      id: true,
      nombre: true,
      email: true,
      rol: true,
    },
  },
  pago: {
    select: {
      id: true,
      metodoPago: true,
      monto: true,
      referencia: true,
      estado: true,
      fechaPago: true,
    },
  },
};

export const findSalidasCobrosRepository = (
  ingresoId?: number,
  estadoPago?: "PENDIENTE" | "PAGADO" | "ANULADO",
  operadorId?: number,
) => {
  return prisma.salidaCobro.findMany({
    where: {
      ...(ingresoId ? { ingresoId } : {}),
      ...(estadoPago ? { estadoPago } : {}),
      ...(operadorId
        ? {
            ingreso: {
              parqueo: {
                operadorId,
              },
            },
          }
        : {}),
    },
    include: includeSalidaCobroDetalle,
    orderBy: {
      fechaSalida: "desc",
    },
  });
};

export const findSalidaCobroByIdRepository = (id: number) => {
  return prisma.salidaCobro.findUnique({
    where: {
      id,
    },
    include: includeSalidaCobroDetalle,
  });
};

export const createSalidaCobroRepository = (
  input: CreateSalidaCobroInput,
  operadorId: number,
) => {
  return prisma.$transaction(async (tx) => {
    const operador = await tx.usuario.findUnique({
      where: {
        id: operadorId,
      },
    });

    if (!operador) {
      throw new Error("OPERADOR_NOT_FOUND");
    }

    if (operador.rol !== "OPERADOR" && operador.rol !== "ADMIN") {
      throw new Error("USER_NOT_ALLOWED");
    }

    const ingreso = await tx.ingreso.findUnique({
      where: {
        id: input.ingresoId,
      },
      include: {
        vehiculo: true,
        espacio: true,
        parqueo: true,
      },
    });

    if (!ingreso) {
      throw new Error("INGRESO_NOT_FOUND");
    }

    if (ingreso.estado !== "ACTIVO") {
      throw new Error("INGRESO_NOT_ACTIVE");
    }

    if (
      operador.rol === "OPERADOR" &&
      ingreso.parqueo.operadorId !== operadorId
    ) {
      throw new Error("SALIDA_COBRO_FORBIDDEN");
    }

    const salidaExistente = await tx.salidaCobro.findUnique({
      where: {
        ingresoId: input.ingresoId,
      },
    });

    if (salidaExistente) {
      throw new Error("SALIDA_ALREADY_EXISTS");
    }

    const tarifa = await tx.tarifa.findUnique({
      where: {
        parqueoId_tipoVehiculo: {
          parqueoId: ingreso.parqueoId,
          tipoVehiculo: ingreso.vehiculo.tipo,
        },
      },
    });

    if (!tarifa || tarifa.estado !== "ACTIVO") {
      throw new Error("TARIFA_NOT_FOUND");
    }

    const fechaSalida = new Date();
    const tiempoTotalMinutos = Math.max(
      1,
      Math.ceil(
        (fechaSalida.getTime() - ingreso.fechaIngreso.getTime()) / 60000,
      ),
    );

    const horasCobradas = Math.max(1, Math.ceil(tiempoTotalMinutos / 60));
    const montoTotal = Number(tarifa.montoHora) * horasCobradas;
    const estadoPago = input.metodoPago ? "PAGADO" : "PENDIENTE";

    const salidaCobro = await tx.salidaCobro.create({
      data: {
        ingresoId: input.ingresoId,
        operadorId,
        fechaSalida,
        tiempoTotalMinutos,
        montoTotal,
        estadoPago,
      },
    });

    if (input.metodoPago) {
      await tx.pago.create({
        data: {
          salidaCobroId: salidaCobro.id,
          metodoPago: input.metodoPago,
          monto: montoTotal,
          referencia: input.referencia,
          estado: "PAGADO",
        },
      });
    }

    await tx.ingreso.update({
      where: {
        id: input.ingresoId,
      },
      data: {
        estado: "FINALIZADO",
      },
    });

    await tx.espacio.update({
      where: {
        id: ingreso.espacioId,
      },
      data: {
        estado: "DISPONIBLE",
      },
    });

    const salidaCobroDetalle = await tx.salidaCobro.findUnique({
      where: {
        id: salidaCobro.id,
      },
      include: includeSalidaCobroDetalle,
    });

    if (!salidaCobroDetalle) {
      throw new Error("SALIDA_COBRO_NOT_FOUND");
    }

    return salidaCobroDetalle;
  });
};

export const solicitarSalidaRepository = (
  input: SolicitarSalidaInput,
  usuarioId: number,
) => {
  return prisma.$transaction(async (tx) => {
    const cliente = await tx.cliente.findUnique({
      where: {
        usuarioId,
      },
    });

    if (!cliente) {
      throw new Error("CLIENTE_PROFILE_NOT_FOUND");
    }

    const ingreso = await tx.ingreso.findUnique({
      where: {
        id: input.ingresoId,
      },
      include: {
        vehiculo: true,
        espacio: true,
        parqueo: true,
        salidaCobro: {
          include: {
            ingreso: {
              include: {
                parqueo: true,
                espacio: true,
                vehiculo: true,
              },
            },
            operador: true,
            pago: true,
          },
        },
      },
    });

    if (!ingreso) {
      throw new Error("INGRESO_NOT_FOUND");
    }

    if (ingreso.vehiculo.clienteId !== cliente.id) {
      throw new Error("SALIDA_COBRO_FORBIDDEN");
    }

    if (ingreso.estado !== "ACTIVO") {
      throw new Error("INGRESO_NOT_ACTIVE");
    }

    if (ingreso.espacio.estado !== "OCUPADO") {
      throw new Error("ESPACIO_NOT_OCCUPIED");
    }

    if (ingreso.salidaCobro) {
      if (ingreso.salidaCobro.estadoPago === "PENDIENTE") {
        return ingreso.salidaCobro;
      }

      throw new Error("SALIDA_ALREADY_COMPLETED");
    }

    const tarifa = await tx.tarifa.findUnique({
      where: {
        parqueoId_tipoVehiculo: {
          parqueoId: ingreso.parqueoId,
          tipoVehiculo: ingreso.vehiculo.tipo,
        },
      },
    });

    if (!tarifa || tarifa.estado !== "ACTIVO") {
      throw new Error("TARIFA_NOT_FOUND");
    }

    const fechaSalida = new Date();

    const tiempoTotalMinutos = Math.max(
      1,
      Math.ceil(
        (fechaSalida.getTime() - ingreso.fechaIngreso.getTime()) / 60000,
      ),
    );

    const horasCobradas = Math.max(1, Math.ceil(tiempoTotalMinutos / 60));

    const montoTotal = Number(tarifa.montoHora) * horasCobradas;

    return tx.salidaCobro.create({
      data: {
        ingresoId: ingreso.id,
        operadorId: ingreso.parqueo.operadorId,
        fechaSalida,
        tiempoTotalMinutos,
        montoTotal,
        estadoPago: "PENDIENTE",
      },
      include: includeSalidaCobroDetalle,
    });
  });
};

export const validarPagoRepository = (
  salidaCobroId: number,
  input: ValidarPagoInput,
  operadorId: number,
) => {
  return prisma.$transaction(async (tx) => {
    const salidaCobro = await tx.salidaCobro.findUnique({
      where: {
        id: salidaCobroId,
      },
      include: {
        ingreso: {
          include: {
            parqueo: true,
            espacio: true,
            vehiculo: true,
          },
        },
        pago: true,
      },
    });

    if (!salidaCobro) {
      throw new Error("SALIDA_COBRO_NOT_FOUND");
    }

    if (salidaCobro.ingreso.parqueo.operadorId !== operadorId) {
      throw new Error("SALIDA_COBRO_FORBIDDEN");
    }

    if (salidaCobro.estadoPago !== "PENDIENTE") {
      throw new Error("SALIDA_COBRO_NOT_PENDING");
    }

    if (salidaCobro.pago) {
      throw new Error("PAGO_ALREADY_EXISTS");
    }

    if (salidaCobro.ingreso.estado !== "ACTIVO") {
      throw new Error("INGRESO_NOT_ACTIVE");
    }

    if (salidaCobro.ingreso.espacio.estado !== "OCUPADO") {
      throw new Error("ESPACIO_NOT_OCCUPIED");
    }

    await tx.pago.create({
      data: {
        salidaCobroId: salidaCobro.id,
        metodoPago: input.metodoPago,
        monto: salidaCobro.montoTotal,
        referencia: input.referencia,
        estado: "PAGADO",
      },
    });

    await tx.salidaCobro.update({
      where: {
        id: salidaCobro.id,
      },
      data: {
        estadoPago: "PAGADO",
      },
    });

    await tx.ingreso.update({
      where: {
        id: salidaCobro.ingresoId,
      },
      data: {
        estado: "FINALIZADO",
      },
    });

    if (salidaCobro.ingreso.reservaId) {
      await tx.reserva.update({
        where: {
          id: salidaCobro.ingreso.reservaId,
        },
        data: {
          estado: "COMPLETADA",
        },
      });
    }

    await tx.espacio.update({
      where: {
        id: salidaCobro.ingreso.espacioId,
      },
      data: {
        estado: "DISPONIBLE",
      },
    });

    const resultado = await tx.salidaCobro.findUnique({
      where: {
        id: salidaCobro.id,
      },
      include: includeSalidaCobroDetalle,
    });

    if (!resultado) {
      throw new Error("SALIDA_COBRO_NOT_FOUND");
    }

    return resultado;
  });
};
