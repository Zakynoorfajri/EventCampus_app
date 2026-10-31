import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';
import '../widgets/search_field.dart';

/// Halaman Jelajah: daftar semua acara + pencarian + filter.
/// Data dan status (loading/error) datang dari induk.
class ExploreScreen extends StatefulWidget {
  final List<Event> events;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<Event> onEventTap;

  /// Kategori awal kiriman dari Home ('Semua' jika tidak ada).
  final String initialCategory;

  /// Naik setiap kali Home mengirim permintaan baru ke halaman ini.
  final int requestId;

  const ExploreScreen({
    super.key,
    required this.events,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onEventTap,
    this.initialCategory = 'Semua',
    this.requestId = 0,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const List<String> _categories = [
    'Semua',
    'Seminar',
    'Workshop',
    'Lomba',
    'Webinar',
    'Organisasi',
  ];
  static const List<String> _statuses = ['Semua', 'Terbuka', 'Penuh', 'Selesai'];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late String _category = widget.initialCategory;
  String _status = 'Semua';

  @override
  void didUpdateWidget(covariant ExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Home mengirim permintaan baru: terapkan kategorinya, bersihkan pencarian.
    if (oldWidget.requestId != widget.requestId) {
      _category = widget.initialCategory;
      _status = 'Semua';
      _query = '';
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    // Controller wajib dibuang agar tidak terjadi kebocoran memori.
    _searchController.dispose();
    super.dispose();
  }

  /// Daftar acara setelah pencarian dan kedua filter diterapkan.
  List<Event> get _filtered {
    final q = _query.trim().toLowerCase();
    return widget.events.where((e) {
      final matchName = q.isEmpty || e.title.toLowerCase().contains(q);
      final matchCategory = _category == 'Semua' || e.category == _category;
      final matchStatus = _status == 'Semua' || e.status == _status;
      return matchName && matchCategory && matchStatus;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _category = 'Semua';
      _status = 'Semua';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasData = !widget.isLoading && widget.errorMessage == null;
    final results = hasData ? _filtered : const <Event>[];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jelajah Acara', style: AppTextStyles.heading1),
                const SizedBox(height: 12),
                SearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 12),
                const Text('Kategori', style: AppTextStyles.subtitle),
              ],
            ),
          ),
          _FilterRow(
            options: _categories,
            selected: _category,
            onSelected: (value) => setState(() => _category = value),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Status', style: AppTextStyles.subtitle),
          ),
          _FilterRow(
            options: _statuses,
            selected: _status,
            onSelected: (value) => setState(() => _status = value),
          ),
          if (hasData && widget.events.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '${results.length} acara ditemukan',
                style: AppTextStyles.caption,
              ),
            ),
          Expanded(child: _buildContent(results)),
        ],
      ),
    );
  }

  /// Memilih tampilan sesuai kondisi: loading, error, kosong, atau daftar.
  Widget _buildContent(List<Event> results) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Gagal memuat acara',
        message: 'Terjadi kesalahan saat membaca data. Silakan coba lagi.',
        actionLabel: 'Coba Lagi',
        onAction: widget.onRetry,
      );
    }

    if (widget.events.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Belum ada acara',
        message: 'Acara kampus akan muncul di sini.',
      );
    }

    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'Acara tidak ditemukan',
        message: 'Coba kata kunci atau filter yang berbeda.',
        actionLabel: 'Reset Filter',
        onAction: _resetFilters,
      );
    }

    return ListView.separated(
      // Menutup keyboard saat daftar digulir.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = results[index];
        return EventCard(event: event, onTap: () => widget.onEventTap(event));
      },
    );
  }
}

/// Satu baris chip filter yang bisa digulir ke samping.
/// Dipakai dua kali (kategori dan status) agar tidak ada kode ganda.
class _FilterRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selected;
          return Center(
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              showCheckmark: false,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelStyle: AppTextStyles.subtitle.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }
}