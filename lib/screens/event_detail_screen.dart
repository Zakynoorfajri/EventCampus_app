import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/event_image.dart';
import '../widgets/info_badge.dart';

/// Halaman detail satu acara.
/// - [event]        : objek acara yang dikirim lewat Navigator.
/// - [isRegistered] : fungsi untuk mengecek apakah acara sudah didaftarkan.
/// - [onRegister]   : dipanggil saat tombol Daftar ditekan; induk yang
///                    membuka halaman formulir dan menunggu sampai selesai.
class EventDetailScreen extends StatefulWidget {
  final Event event;
  final bool Function() isRegistered;
  final Future<void> Function(Event event) onRegister;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.isRegistered,
    required this.onRegister,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  /// Membuka formulir, menunggu sampai ditutup, lalu menyegarkan tombol.
  Future<void> _handleRegister() async {
    await widget.onRegister(widget.event);
    if (!mounted) return; // halaman sudah ditutup, jangan setState
    setState(() {});
  }

  /// Menentukan teks dan status aktif tombol sesuai kondisi acara.
  ({String label, bool enabled}) _buttonState() {
    if (widget.isRegistered()) {
      return (label: 'Sudah Terdaftar', enabled: false);
    }
    return switch (widget.event.status) {
      'Terbuka' => (label: 'Daftar Sekarang', enabled: true),
      'Penuh' => (label: 'Kuota Penuh', enabled: false),
      _ => (label: 'Acara Telah Selesai', enabled: false),
    };
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final button = _buttonState();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 260,
                  backgroundColor: AppColors.primary,
                  leadingWidth: 64,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        tooltip: 'Kembali',
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: EventImage(
                      path: event.image,
                      width: double.infinity,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            InfoBadge(
                              text: event.category,
                              color: AppColors.secondary,
                            ),
                            InfoBadge(
                              text: event.status,
                              color: AppColors.statusColor(event.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(event.title, style: AppTextStyles.heading1),
                        const SizedBox(height: 16),
                        _InfoCard(event: event),
                        const SizedBox(height: 20),
                        const Text('Deskripsi', style: AppTextStyles.heading2),
                        const SizedBox(height: 8),
                        Text(
                          event.description,
                          style: AppTextStyles.body.copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        const Text('Persyaratan Peserta',
                            style: AppTextStyles.heading2),
                        const SizedBox(height: 8),
                        for (final item in event.requirements)
                          _RequirementItem(text: item),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _BottomAction(
            label: button.label,
            enabled: button.enabled,
            onPressed: _handleRegister,
          ),
        ],
      ),
    );
  }
}

/// Kartu berisi informasi inti acara (tanggal, jam, lokasi, dst).
class _InfoCard extends StatelessWidget {
  final Event event;

  const _InfoCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal',
            value: event.dateText,
          ),
          _InfoRow(
            icon: Icons.access_time,
            label: 'Jam',
            value: event.time,
          ),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Lokasi',
            value: event.location,
          ),
          _InfoRow(
            icon: Icons.business_outlined,
            label: 'Penyelenggara',
            value: event.organizer,
          ),
          _InfoRow(
            icon: Icons.people_outline,
            label: 'Kuota',
            value: '${event.quota} peserta',
          ),
          _InfoRow(
            icon: Icons.payments_outlined,
            label: 'Biaya',
            value: event.priceText,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

/// Satu baris: ikon, label kecil, dan nilai (boleh lebih dari satu baris).
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          // Expanded: teks panjang turun ke baris berikutnya, bukan overflow.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu poin persyaratan dengan ikon centang.
class _RequirementItem extends StatelessWidget {
  final String text;

  const _RequirementItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_outline,
              size: 18,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

/// Panel tombol tetap di bawah layar.
class _BottomAction extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _BottomAction({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      // SafeArea menjaga tombol tidak tertutup gesture bar di bawah layar.
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              // onPressed null membuat tombol otomatis tampil nonaktif.
              onPressed: enabled ? onPressed : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: enabled ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}