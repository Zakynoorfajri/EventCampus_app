import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/category_item.dart';
import '../widgets/event_card.dart';
import '../widgets/event_image.dart';
import '../widgets/search_field.dart';

/// Halaman utama. Hanya menampilkan data dan melaporkan aksi pengguna
/// lewat callback; perpindahan halaman diatur oleh induknya.
class HomeScreen extends StatelessWidget {
  final List<Event> events;
  final ValueChanged<Event> onEventTap;
  final ValueChanged<String> onCategoryTap;
  final VoidCallback onSearchTap;
  final VoidCallback onSeeAllTap;

  const HomeScreen({
    super.key,
    required this.events,
    required this.onEventTap,
    required this.onCategoryTap,
    required this.onSearchTap,
    required this.onSeeAllTap,
  });

  static const List<String> _categories = [
    'Seminar',
    'Workshop',
    'Lomba',
    'Webinar',
    'Organisasi',
  ];

  @override
  Widget build(BuildContext context) {
    final openEvents = events.where((e) => e.isOpen).toList();

    // Unggulan: acara terbuka dengan tanggal paling dekat.
    final byDate = [...openEvents]..sort((a, b) => a.date.compareTo(b.date));
    final featured = byDate.firstOrNull;

    // Populer: acara terbuka dengan kuota terbesar.
    final byQuota = [...openEvents]
      ..sort((a, b) => b.quota.compareTo(a.quota));
    final popular = byQuota.take(4).toList();

    // Terbaru: id terbesar.
    final byId = [...events]..sort((a, b) => b.id.compareTo(a.id));
    final newest = byId.take(3).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _Header(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // readOnly: kolom ini hanya pintasan menuju halaman Jelajah.
              child: SearchField(readOnly: true, onTap: onSearchTap),
            ),
            if (featured != null) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _FeaturedBanner(
                  event: featured,
                  onTap: () => onEventTap(featured),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Kategori'),
            const SizedBox(height: 12),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return CategoryItem(
                    label: category,
                    onTap: () => onCategoryTap(category),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Acara Populer', onSeeAll: onSeeAllTap),
            const SizedBox(height: 12),
            SizedBox(
              height: 350,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: popular.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final event = popular[index];
                  // Align melonggarkan tinggi, supaya card tidak
                  // ditarik setinggi 350 dan tetap setinggi isinya.
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 280,
                      child: EventCard(
                        event: event,
                        onTap: () => onEventTap(event),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Acara Terbaru', onSeeAll: onSeeAllTap),
            const SizedBox(height: 12),
            for (final event in newest)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: EventCard(
                  event: event,
                  onTap: () => onEventTap(event),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Header: hanya sapaan kepada pengguna.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Halo, Mahasiswa! 👋', style: AppTextStyles.heading1),
        SizedBox(height: 2),
        Text(
          'Temukan kegiatan kampus favoritmu',
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}

/// Judul bagian + tautan "Lihat Semua" (opsional).
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.heading2),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'Lihat Semua',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Banner acara unggulan: gambar penuh + lapisan gelap + teks putih.
class _FeaturedBanner extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _FeaturedBanner({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 190,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            EventImage(path: event.image),
            // Gradasi gelap di bawah agar teks putih terbaca.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD172554)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Unggulan',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.dateText} • ${event.location}',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Lapisan transparan paling atas agar seluruh banner bisa diklik
            // dan menampilkan efek riak.
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}