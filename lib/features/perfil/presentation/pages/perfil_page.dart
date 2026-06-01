import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
import 'package:la_madriguera/shared/models/usuario_model.dart';
import 'package:la_madriguera/shared/providers/session_provider.dart';

class PerfilPage extends ConsumerWidget {
  const PerfilPage({super.key});

  Widget _option({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _mostrarEditarDatosDialog(BuildContext context, WidgetRef ref) {
    final usuarioActual = ref.read(sessionProvider);

    if (usuarioActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No existe una sesión activa.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: usuarioActual.nombre);
    final passwordController = TextEditingController();
    final confirmarPasswordController = TextEditingController();

    bool ocultarPassword = true;
    bool ocultarConfirmacion = true;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar datos de cuenta'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de usuario',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';

                          if (text.isEmpty) {
                            return 'Ingresa el nombre de usuario';
                          }

                          if (text.length < 3) {
                            return 'El nombre debe tener al menos 3 caracteres';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: passwordController,
                        obscureText: ocultarPassword,
                        decoration: InputDecoration(
                          labelText: 'Nueva contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                ocultarPassword = !ocultarPassword;
                              });
                            },
                            icon: Icon(
                              ocultarPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';

                          if (text.isEmpty) {
                            return null;
                          }

                          if (text.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: confirmarPasswordController,
                        obscureText: ocultarConfirmacion,
                        decoration: InputDecoration(
                          labelText: 'Confirmar contraseña',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                ocultarConfirmacion = !ocultarConfirmacion;
                              });
                            },
                            icon: Icon(
                              ocultarConfirmacion
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (value) {
                          final password = passwordController.text.trim();
                          final confirmacion = value?.trim() ?? '';

                          if (password.isEmpty && confirmacion.isEmpty) {
                            return null;
                          }

                          if (confirmacion.isEmpty) {
                            return 'Confirma la nueva contraseña';
                          }

                          if (password != confirmacion) {
                            return 'Las contraseñas no coinciden';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Nota: por ahora esta modificación es solo visual en frontend.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final valido = formKey.currentState?.validate() ?? false;

                    if (!valido) {
                      return;
                    }

                    final usuarioActualizado = UsuarioModel(
                      id: usuarioActual.id,
                      nombre: nombreController.text.trim(),
                      correo: usuarioActual.correo,
                      rol: usuarioActual.rol,
                    );

                    ref.read(sessionProvider.notifier).state =
                        usuarioActualizado;

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Datos actualizados correctamente.'),
                      ),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _optionsByRole(
    BuildContext context,
    WidgetRef ref,
    RolEnum? rol,
  ) {
    if (rol == RolEnum.operador) {
      return [
        _option(
          icon: Icons.local_parking,
          title: 'Mi parqueo',
          onTap: () {
            Navigator.pushNamed(context, RouteNames.misParqueos);
          },
        ),
        _option(
          icon: Icons.edit,
          title: 'Editar datos de cuenta',
          onTap: () {
            _mostrarEditarDatosDialog(context, ref);
          },
        ),
      ];
    }

    return [
      _option(
        icon: Icons.history,
        title: 'Historial de reservas',
        onTap: () {
          Navigator.pushNamed(context, RouteNames.historial);
        },
      ),
      _option(
        icon: Icons.edit,
        title: 'Editar datos de cuenta',
        onTap: () {
          _mostrarEditarDatosDialog(context, ref);
        },
      ),
    ];
  }

  String _rolLabel(RolEnum? rol) {
    switch (rol) {
      case RolEnum.operador:
        return 'Operador';
      case RolEnum.administrador:
        return 'Administrador';
      case RolEnum.cliente:
      case null:
        return 'Cliente';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 12),
            Text(
              usuario?.nombre ?? 'Usuario La Madriguera',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              usuario?.correo ?? 'usuario@gmail.com',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              _rolLabel(usuario?.rol),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ..._optionsByRole(context, ref, usuario?.rol),
          ],
        ),
      ),
    );
  }
}
