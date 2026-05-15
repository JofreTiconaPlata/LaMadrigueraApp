import 'package:la_madriguera/features/auth/domain/repositories/auth_repository.dart';
import 'package:la_madriguera/shared/models/usuario_model.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<UsuarioModel> call({
    required String email,
    required String password,
  }) {
    return _repository.login(
      email: email,
      password: password,
    );
  }
}
