import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;

import 'package:la_madriguera/core/storage/local_storage_service.dart';
import 'package:la_madriguera/shared/models/usuario_model.dart';

final sessionProvider = legacy.StateProvider<UsuarioModel?>((ref) => null);

final sessionInitializerProvider = FutureProvider<UsuarioModel?>((ref) async {
  final token = await LocalStorageService.getToken();

  if (token == null || token.isEmpty) {
    ref.read(sessionProvider.notifier).state = null;
    return null;
  }

  final usuario = await LocalStorageService.getUser();

  if (usuario == null) {
    ref.read(sessionProvider.notifier).state = null;
    return null;
  }

  ref.read(sessionProvider.notifier).state = usuario;
  return usuario;
});
