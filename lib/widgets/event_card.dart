import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'event_image.dart';
import 'info_badge.dart';

/// Card acara: gambar, kategori, status, judul, tanggal, lokasi,
/// dan ajakan "Lihat Detail". Seluruh card bisa diklik.
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: Colors.black26,
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias, // memotong gambar mengikuti sudut card
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            EventImage(
              path: event.image,
              height: 140,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: InfoBadge(
                          text: event.category,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InfoBadge(
                        text: event.status,
                        color: AppColors.statusColor(event.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.title,
                    style: AppTextStyles.heading2.copyWith(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.calendar_today_outlined, text: event.dateText),
                  const SizedBox(height: 4),
                  _InfoRow(icon: Icons.location_on_outlined, text: event.location),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Lihat Detail',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu baris ikon + teks (private: hanya dipakai di file ini).
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}