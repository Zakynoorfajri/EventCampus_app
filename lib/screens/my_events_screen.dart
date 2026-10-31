import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/registration.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_image.dart';
import '../widgets/info_badge.dart';

/// Halaman "Acara Saya": daftar acara yang sudah didaftarkan.
/// Halaman ini hanya menampilkan data kiriman induk (StatelessWidget).
class MyEventsScreen extends StatelessWidget {
  final List<Registration> registrations;
  final ValueChanged<Event> onEventTap;
  final VoidCallback onBrowseTap;

  const MyEventsScreen({
    super.key,
    required this.registrations,
    required this.onEventTap,
    required this.onBrowseTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pendaftaran terbaru di atas. List disalin agar aslinya tidak berubah.
    final items = registrations.reversed.toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Acara Saya', style: AppTextStyles.heading1),
                const SizedBox(height: 4),
                Text(
                  items.isEmpty
                      ? 'Belum ada acara yang kamu daftarkan'
                      : '${items.length} acara terdaftar',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Belum ada pendaftaran',
                    message:
                        'Daftar ke acara kampus dan hasilnya akan tampil di sini.',
                    actionLabel: 'Jelajahi Acara',
                    onAction: onBrowseTap,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final registration = items[index];
                      return _RegistrationCard(
                        registration: registration,
                        onTap: () => onEventTap(registration.event),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Kartu satu pendaftaran: gambar kecil + info acara + status.
class _RegistrationCard extends StatelessWidget {
  final Registration registration;
  final VoidCallback onTap;

  const _RegistrationCard({required this.registration, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final event = registration.event;

    return Material(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: Colors.black26,
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: EventImage(path: event.image, width: 80, height: 80),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoBadge(
                      text: registration.status,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      style: AppTextStyles.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _MetaRow(
                      icon: Icons.calendar_today_outlined,
                      text: '${event.dateText} • ${event.time}',
                    ),
                    const SizedBox(height: 2),
                    _MetaRow(
                      icon: Icons.location_on_outlined,
                      text: event.location,
                    ),
                    const SizedBox(height: 2),
                    _MetaRow(
                      icon: Icons.person_outline,
                      text: '${registration.name} (${registration.nim})',
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu baris kecil: ikon + teks satu baris.
class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}