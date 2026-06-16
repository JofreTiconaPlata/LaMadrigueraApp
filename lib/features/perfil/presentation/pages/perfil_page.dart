import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:la_madriguera/app/router/route_names.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';
import 'package:la_madriguera/core/storage/local_storage_service.dart';
import 'package:la_madriguera/features/perfil/data/datasources/perfil_remote_datasource.dart';
import 'package:la_madriguera/shared/enums/rol_enum.dart';
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

  Future<void> _mostrarEditarDatosDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final usuarioActual = ref.read(sessionProvider);

    if (usuarioActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No existe una sesión activa.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: usuarioActual.nombre);
    final passwordActualController = TextEditingController();
    final passwordNuevaController = TextEditingController();
    final confirmarPasswordController = TextEditingController();

    var ocultarPasswordActual = true;
    var ocultarPasswordNueva = true;
    var ocultarConfirmacion = true;
    var guardando = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final quiereCambiarPassword =
                  passwordActualController.text.isNotEmpty ||
                  passwordNuevaController.text.isNotEmpty ||
                  confirmarPasswordController.text.isNotEmpty;

              return PopScope(
                canPop: !guardando,
                child: AlertDialog(
                  title: const Text('Editar datos de cuenta'),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nombreController,
                            enabled: !guardando,
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

                              if (text.length < 2) {
                                return 'El nombre debe tener al menos 2 caracteres';
                              }

                              if (text.length > 100) {
                                return 'El nombre no puede superar 100 caracteres';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: passwordActualController,
                            enabled: !guardando,
                            obscureText: ocultarPasswordActual,
                            onChanged: (_) => setDialogState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Contraseña actual',
                              prefixIcon: const Icon(Icons.key_outlined),
                              suffixIcon: IconButton(
                                onPressed: guardando
                                    ? null
                                    : () {
                                        setDialogState(() {
                                          ocultarPasswordActual =
                                              !ocultarPasswordActual;
                                        });
                                      },
                                icon: Icon(
                                  ocultarPasswordActual
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (value) {
                              if (!quiereCambiarPassword) {
                                return null;
                              }

                              if ((value ?? '').isEmpty) {
                                return 'Ingresa tu contraseña actual';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: passwordNuevaController,
                            enabled: !guardando,
                            obscureText: ocultarPasswordNueva,
                            onChanged: (_) => setDialogState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Nueva contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: guardando
                                    ? null
                                    : () {
                                        setDialogState(() {
                                          ocultarPasswordNueva =
                                              !ocultarPasswordNueva;
                                        });
                                      },
                                icon: Icon(
                                  ocultarPasswordNueva
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (value) {
                              final text = value ?? '';

                              if (!quiereCambiarPassword) {
                                return null;
                              }

                              if (text.isEmpty) {
                                return 'Ingresa la nueva contraseña';
                              }

                              if (text.length < 8) {
                                return 'La contraseña debe tener al menos 8 caracteres';
                              }

                              if (text.length > 72) {
                                return 'La contraseña no puede superar 72 caracteres';
                              }

                              if (text == passwordActualController.text) {
                                return 'La nueva contraseña debe ser diferente';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: confirmarPasswordController,
                            enabled: !guardando,
                            obscureText: ocultarConfirmacion,
                            onChanged: (_) => setDialogState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Confirmar nueva contraseña',
                              prefixIcon: const Icon(Icons.lock_reset_outlined),
                              suffixIcon: IconButton(
                                onPressed: guardando
                                    ? null
                                    : () {
                                        setDialogState(() {
                                          ocultarConfirmacion =
                                              !ocultarConfirmacion;
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
                              if (!quiereCambiarPassword) {
                                return null;
                              }

                              if ((value ?? '').isEmpty) {
                                return 'Confirma la nueva contraseña';
                              }

                              if (value != passwordNuevaController.text) {
                                return 'Las contraseñas no coinciden';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: guardando
                          ? null
                          : () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: guardando
                          ? null
                          : () async {
                              final valido =
                                  formKey.currentState?.validate() ?? false;

                              if (!valido) {
                                return;
                              }

                              setDialogState(() {
                                guardando = true;
                              });

                              try {
                                final cambiaPassword =
                                    passwordNuevaController.text.isNotEmpty;

                                final usuarioActualizado =
                                    await PerfilRemoteDataSource()
                                        .actualizarPerfil(
                                          nombre: nombreController.text,
                                          passwordActual: cambiaPassword
                                              ? passwordActualController.text
                                              : null,
                                          passwordNueva: cambiaPassword
                                              ? passwordNuevaController.text
                                              : null,
                                        );

                                ref.read(sessionProvider.notifier).state =
                                    usuarioActualizado;

                                await LocalStorageService.saveUser(
                                  usuarioActualizado,
                                );

                                if (!dialogContext.mounted) {
                                  return;
                                }

                                Navigator.pop(dialogContext);

                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Datos actualizados correctamente.',
                                    ),
                                  ),
                                );
                              } catch (error) {
                                if (!dialogContext.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      error.toString().replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                    ),
                                  ),
                                );

                                setDialogState(() {
                                  guardando = false;
                                });
                              }
                            },
                      child: guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      nombreController.dispose();
      passwordActualController.dispose();
      passwordNuevaController.dispose();
      confirmarPasswordController.dispose();
    }
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
