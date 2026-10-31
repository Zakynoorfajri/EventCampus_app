import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'utils/app_colors.dart';

void main() => runApp(const EventCampusApp());

class EventCampusApp extends StatelessWidget {
  const EventCampusApp({super.key});

  /// Tema Material 3 yang dipakai seluruh aplikasi.
  ThemeData _buildTheme() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.secondary)
        .copyWith(primary: AppColors.secondary, error: AppColors.error);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
            // Nama harus sama dengan "family" di pubspec.yaml.
      fontFamily: 'PlusJakartaSans',
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventCampus',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const MainShell(),
    );
  }
}