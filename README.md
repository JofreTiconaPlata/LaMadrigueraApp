# LaMadrigueraApp

Aplicación móvil para la gestión de parqueos, desarrollada como proyecto académico de la materia **Programación Móvil**.

LaMadrigueraApp permite administrar parqueos, espacios, vehículos, reservas, ingresos, salidas y cobros mediante una aplicación móvil conectada a un backend con base de datos relacional.

---

## Propósito de la aplicación

El propósito de LaMadrigueraApp es digitalizar y organizar la gestión de parqueos, reduciendo el control manual de espacios, vehículos, reservas, ingresos y cobros.

La aplicación está orientada a dos tipos principales de usuarios:

- **Cliente:** puede registrarse, iniciar sesión, consultar parqueos, registrar vehículos y gestionar reservas.
- **Operador:** puede administrar parqueos, espacios, tarifas, ingresos, vehículos estacionados, salidas y cobros.

El rol **ADMIN** queda reservado para uso interno del sistema y no forma parte del registro público desde la aplicación móvil.

---

## Integrantes

| Integrante | Rol principal |
|---|---|
| Jose Aima Lupa | Coordinación / QA / Documentación |
| Jofre Ticona Plata | Backend / Base de datos / Integración |
| Jhonatan Ortuño Cáceres | Desarrollo móvil |
| Wilber Lancea Mamani | Desarrollo móvil |

---

## Tecnologías utilizadas

### Aplicación móvil

- Flutter
- Dart
- Riverpod
- GoRouter
- Dio
- Shared Preferences
- Flutter Map
- Geolocator

### Backend

- Node.js
- Express
- TypeScript
- Prisma ORM
- PostgreSQL
- JWT
- bcrypt
- Zod
- CORS
- dotenv

### Herramientas

- Git
- GitHub
- GitHub Actions
- Android Studio
- Visual Studio Code
- Prisma CLI
- Flutter CLI
- npm

---

## Requisitos previos

Antes de ejecutar el proyecto, se recomienda tener instalado:

- Git
- Flutter SDK compatible con el proyecto
- Dart SDK incluido con Flutter
- Android Studio o un dispositivo Android físico
- Node.js 20.19.0 o superior
- npm
- PostgreSQL local o una base de datos PostgreSQL remota

Verificar instalaciones:

```bash
git --version
flutter --version
dart --version
node --version
npm --version
```

---

## Clonar el repositorio

```bash
git clone https://github.com/JofreTiconaPlata/LaMadrigueraApp.git
cd LaMadrigueraApp
```

---

# Configuración del frontend móvil

## Instalar dependencias de Flutter

Desde la raíz del proyecto:

```bash
flutter pub get
```

## Verificar dispositivos disponibles

```bash
flutter devices
```

## Analizar el código Flutter

```bash
flutter analyze
```

## Ejecutar pruebas Flutter

```bash
flutter test
```

## Ejecutar la aplicación

Con un emulador o dispositivo físico conectado:

```bash
flutter run
```

## Compilar APK debug

```bash
flutter build apk --debug
```

El APK se genera normalmente en:

```bash
build/app/outputs/flutter-apk/app-debug.apk
```

---

# Configuración del backend

## Entrar a la carpeta backend

```bash
cd backend
```

## Instalar dependencias

```bash
npm install
```

---

## Configurar variables de entorno

Crear un archivo `.env` dentro de la carpeta `backend`:

```bash
cp .env.example .env
```

Si no existe `.env.example`, crear manualmente el archivo:

```env
DATABASE_URL="postgresql://usuario:password@localhost:5432/lamadriguera"
JWT_SECRET="cambiar_este_secreto"
PORT=3000
```

Modificar `DATABASE_URL` según la configuración de PostgreSQL local o remoto.

Ejemplo local:

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/lamadriguera"
JWT_SECRET="lamadriguera_secret_dev"
PORT=3000
```

---

# Validar base de datos con Prisma

Desde la carpeta `backend`:

## Validar el schema Prisma

```bash
npx prisma validate
```

## Generar Prisma Client

```bash
npx prisma generate
```

## Ejecutar migraciones

```bash
npx prisma migrate dev
```

## Ejecutar seed de datos iniciales

```bash
npm run seed
```

Si el comando anterior no está disponible, usar:

```bash
npx prisma db seed
```

## Abrir Prisma Studio

```bash
npx prisma studio
```

Prisma Studio permite revisar visualmente las tablas y datos de la base de datos.

---

# Ejecutar backend

Desde la carpeta `backend`:

```bash
npm run dev
```

El servidor debería ejecutarse en:

```text
http://localhost:3000
```

## Verificar que el backend está activo

Abrir en navegador o probar con curl:

```bash
curl http://localhost:3000/health
```

Respuesta esperada:

```json
{
  "status": "ok"
}
```

---

# Validar backend

## Compilar backend

```bash
npm run build
```

## Verificar tipos TypeScript

```bash
npm run typecheck
```

## Validar Prisma

```bash
npx prisma validate
```

## Generar Prisma Client

```bash
npx prisma generate
```

---

# Flujo recomendado de ejecución completa

Abrir dos terminales.

## Terminal 1: Backend

```bash
cd LaMadrigueraApp/backend
npm install
npx prisma validate
npx prisma generate
npm run dev
```

## Terminal 2: Flutter

```bash
cd LaMadrigueraApp
flutter pub get
flutter analyze
flutter test
flutter run
```

---

# Endpoints principales del backend

| Módulo | Ruta base |
|---|---|
| Autenticación | `/api/auth` |
| Parqueos | `/api/parqueos` |
| Espacios | `/api/espacios` |
| Tarifas | `/api/tarifas` |
| Vehículos | `/api/vehiculos` |
| Reservas | `/api/reservas` |
| Ingresos | `/api/ingresos` |
| Salidas y cobros | `/api/salidas-cobros` |

---

# Roles del sistema

| Rol | Descripción |
|---|---|
| CLIENTE | Usuario que consulta parqueos, registra vehículos y realiza reservas. |
| OPERADOR | Usuario que administra parqueos, espacios, tarifas, ingresos, salidas y cobros. |
| ADMIN | Rol interno restringido. No se registra ni accede desde la aplicación móvil pública. |

---

# Comandos útiles de Git

## Ver estado del repositorio

```bash
git status
```

## Crear una rama nueva

```bash
git checkout -b feature/nombre-funcionalidad
```

## Guardar cambios

```bash
git add .
git commit -m "feat(modulo): descripcion del cambio"
```

## Subir rama al remoto

```bash
git push -u origin feature/nombre-funcionalidad
```

## Ver historial reciente

```bash
git log --oneline --decorate --max-count=10
```

---

# Validación antes de subir cambios

Antes de hacer commit o pull request, ejecutar:

## Frontend

```bash
flutter analyze
flutter test
```

## Backend

```bash
cd backend
npm run build
npm run typecheck
npx prisma validate
```

---

# Estructura general del proyecto

```text
LaMadrigueraApp/
├── android/
├── backend/
│   ├── prisma/
│   └── src/
│       ├── modules/
│       └── index.ts
├── lib/
│   ├── app/
│   ├── core/
│   └── features/
├── test/
├── web/
├── pubspec.yaml
└── README.md
```

---

# Estado del proyecto

El proyecto cuenta con una base funcional para:

- Registro e inicio de sesión.
- Control de roles CLIENTE y OPERADOR.
- Restricción de ADMIN en app pública.
- Gestión de parqueos.
- Gestión de espacios.
- Gestión de tarifas.
- Gestión de vehículos.
- Gestión de reservas.
- Registro de ingresos.
- Registro de salidas y cobros.
- Conexión entre Flutter y backend.
- Validación mediante comandos de frontend y backend.

---

# Mejoras futuras

- Despliegue formal del backend en la nube.
- Base de datos PostgreSQL remota permanente.
- Recuperación de contraseña.
- Refresh tokens.
- Pagos reales mediante QR, tarjeta o transferencia.
- Notificaciones push.
- Reportes estadísticos avanzados.
- Panel web administrativo.
- Documentación de API con Swagger/OpenAPI.
- APK firmada para distribución.

---

# Licencia

Proyecto académico desarrollado para la materia **Programación Móvil**.
