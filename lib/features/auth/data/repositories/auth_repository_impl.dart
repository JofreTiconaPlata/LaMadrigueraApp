import 'package:la_madriguera/core/storage/local_storage_service.dart';
import 'package:la_madriguera/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:la_madriguera/features/auth/domain/repositories/auth_repository.dart';
import 'package:la_madriguera/shared/models/usuario_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<UsuarioModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    await LocalStorageService.saveToken(response.token);
    return response.usuario;
  }

  @override
  Future<UsuarioModel> register({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
    String rol = 'CLIENTE',
  }) async {
    final response = await _remoteDataSource.register(
      nombre: nombre,
      email: email,
      password: password,
      telefono: telefono,
      rol: rol,
    );

    await LocalStorageService.saveToken(response.token);
    return response.usuario;
  }

  @override
  Future<void> logout() async {
    await LocalStorageService.clearToken();
  }
}
