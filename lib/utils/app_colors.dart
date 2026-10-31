import 'package:flutter/material.dart';

/// Kumpulan warna aplikasi di satu tempat.
/// Kalau ingin mengubah tema, cukup ubah di file ini.
class AppColors {
  // Constructor private: class ini hanya dipakai sebagai wadah konstanta,
  // jadi tidak perlu dibuat objeknya.
  AppColors._();

  static const Color primary = Color(0xFF172554); // Navy Blue
  static const Color secondary = Color(0xFF2563EB); // Royal Blue
  static const Color accent = Color(0xFFF59E0B); // Orange
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color border = Color(0xFFE2E8F0);

  /// Warna label sesuai status acara.
  static Color statusColor(String status) {
    return switch (status) {
      'Terbuka' => success,
      'Penuh' => error,
      _ => textSecondary, // Selesai atau status lain
    };
  }
}