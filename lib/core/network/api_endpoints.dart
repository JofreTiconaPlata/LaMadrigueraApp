class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authMe = '/api/auth/me';
  static const String authUpdateMe = '/api/auth/me';

  static const String parqueos = '/api/parqueos';
  static const String misParqueos = '/api/parqueos/mios';
  static const String espacios = '/api/espacios';
  static const String tarifas = '/api/tarifas';
  static const String vehiculos = '/api/vehiculos';
  static const String ingresos = '/api/ingresos';
  static const String ingresosActivos = '/api/ingresos/activos';
  static const String reservas = '/api/reservas';
  static const String misReservas = '/api/reservas/mis-reservas';
  static const String reservasOperador = '/api/reservas/operador';
  static const String salidasCobros = '/api/salidas-cobros';
}
