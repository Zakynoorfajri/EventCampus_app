import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// Kolom pencarian.
/// - Di Explore: dipakai untuk mengetik (onChanged).
/// - Di Home: dipakai sebagai tombol menuju Explore (readOnly + onTap).
class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final String hintText;

  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.hintText = 'Cari acara...',
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      style: AppTextStyles.subtitle,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.body,
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
      ),
    );
  }
}