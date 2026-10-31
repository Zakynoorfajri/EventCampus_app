import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// Item kategori: ikon bulat + label. Bisa ditandai "terpilih".
class CategoryItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  /// Memetakan nama kategori ke ikon Material.
  static IconData iconFor(String category) {
    return switch (category) {
      'Seminar' => Icons.school_outlined,
      'Workshop' => Icons.build_outlined,
      'Lomba' => Icons.emoji_events_outlined,
      'Webinar' => Icons.videocam_outlined,
      'Organisasi' => Icons.groups_outlined,
      _ => Icons.apps_outlined, // "Semua"
    };
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Icon(
                iconFor(label),
                color: isSelected ? Colors.white : AppColors.secondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}