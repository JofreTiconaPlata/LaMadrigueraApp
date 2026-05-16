import 'package:flutter_riverpod/legacy.dart';
import 'package:la_madriguera/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:la_madriguera/features/auth/domain/usecases/login_usecase.dart';
import 'package:la_madriguera/shared/models/usuario_model.dart';

class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final UsuarioModel? usuario;

  const LoginState({this.isLoading = false, this.errorMessage, this.usuario});

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    UsuarioModel? usuario,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      usuario: usuario ?? this.usuario,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  final LoginUseCase _loginUseCase = LoginUseCase(AuthRepositoryImpl());

  Future<UsuarioModel?> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final usuario = await _loginUseCase(email: email, password: password);

      state = state.copyWith(
        isLoading: false,
        usuario: usuario,
        clearError: true,
      );

      return usuario;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Correo o contraseña incorrectos',
      );

      return null;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(),
);
