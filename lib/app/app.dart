import 'package:flutter/material.dart';
import 'package:la_madriguera/app/router/app_router.dart';
import 'package:la_madriguera/app/theme/app_theme.dart';

class LaMadrigueraApp extends StatelessWidget {
  const LaMadrigueraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'La Madriguera',
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
