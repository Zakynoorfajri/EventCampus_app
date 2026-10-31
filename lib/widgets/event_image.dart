import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Menampilkan gambar dari assets.
/// Jika file gambar tidak ditemukan, tampil kotak abu-abu dengan ikon
/// sehingga aplikasi tidak crash.
class EventImage extends StatelessWidget {
  final String path;
  final double? height;
  final double? width;

  const EventImage({
    super.key,
    required this.path,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width,
          color: AppColors.border,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            size: 32,
            color: AppColors.textSecondary,
          ),
        );
      },
    );
  }
}
