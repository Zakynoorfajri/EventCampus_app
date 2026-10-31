import 'package:flutter/material.dart';

import '../utils/app_text_styles.dart';

/// Label kecil berbentuk pil, dipakai untuk kategori dan status acara.
class InfoBadge extends StatelessWidget {
  final String text;
  final Color color;

  const InfoBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30), // latar tipis dari warna yang sama
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}