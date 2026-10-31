import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/registration.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/event_image.dart';

/// Halaman formulir pendaftaran acara.
/// - [event]        : acara yang dipilih dari halaman detail.
/// - [events]       : seluruh acara, untuk mengisi dropdown.
/// - [isRegistered] : fungsi pengecek pendaftaran ganda.
/// - [onSubmit]     : dipanggil dengan data pendaftaran yang sudah valid.
class RegistrationScreen extends StatefulWidget {
  final Event event;
  final List<Event> events;
  final bool Function(Event event) isRegistered;
  final ValueChanged<Registration> onSubmit;

  const RegistrationScreen({
    super.key,
    required this.event,
    required this.events,
    required this.isRegistered,
    required this.onSubmit,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  static const int _phoneMin = 10;
  static const int _phoneMax = 13;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  late Event _selected = widget.event;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ---------- Validator: mengembalikan teks error, atau null jika valid ----------

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama lengkap wajib diisi';
    if (text.length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  String? _validateNim(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'NIM wajib diisi';
    if (!RegExp(r'^\d+$').hasMatch(text)) return 'NIM harus berupa angka';
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(text)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nomor telepon wajib diisi';
    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return 'Nomor telepon hanya boleh berisi angka';
    }
    if (text.length < _phoneMin || text.length > _phoneMax) {
      return 'Nomor telepon harus $_phoneMin-$_phoneMax digit';
    }
    return null;
  }

  String? _validateEvent(Event? value) {
    // Setelah berhasil kirim, hentikan validasi supaya tidak muncul
    // pesan "sudah terdaftar" di balik dialog sukses.
    if (_isSubmitting) return null;
    if (value == null) return 'Pilih acara yang ingin didaftarkan';
    if (widget.isRegistered(value)) {
      return 'Anda sudah terdaftar di acara ini';
    }
    return null;
  }

  // ---------- Aksi ----------

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.success,
        ),
      );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    // validate() menjalankan semua validator dan menampilkan pesan error
    // pada field yang bermasalah.
    if (!_formKey.currentState!.validate()) {
      _showMessage(
        'Pendaftaran gagal. Periksa isian yang bertanda merah.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final registration = Registration(
      event: _selected,
      name: _nameController.text.trim(),
      nim: _nimController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      registeredAt: DateTime.now(),
    );
    widget.onSubmit(registration); // induk menyimpan ke state-nya

    // Simpan messenger dan navigator sebelum await supaya aman dipakai
    // setelah dialog ditutup.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SuccessDialog(
        registration: registration,
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );

    if (!mounted) return;
    navigator.pop(); // kembali ke halaman detail
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil!'),
          backgroundColor: AppColors.success,
        ),
      );
  }

  // ---------- Tampilan ----------

  InputDecoration _decoration(String label, IconData icon) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.body,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.secondary, 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.5),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dropdown hanya berisi acara yang masih terbuka, ditambah acara
    // yang dipilih (supaya nilai awal selalu ada di daftar).
    final options = widget.events
        .where((e) => e.isOpen || e.id == widget.event.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran', style: AppTextStyles.heading2),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EventSummary(event: _selected),
                const SizedBox(height: 20),
                const Text('Data Peserta', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  validator: _validateName,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoration('Nama lengkap', Icons.person_outline),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nimController,
                  validator: _validateNim,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: _decoration('NIM', Icons.badge_outlined),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  validator: _validateEmail,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      _decoration('Email mahasiswa', Icons.email_outlined),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  validator: _validatePhone,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: _decoration('Nomor telepon', Icons.phone_outlined),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<Event>(
                  // Catatan: jika flutter analyze menampilkan info
                  // "value is deprecated", ganti 'value' dengan
                  // 'initialValue' (Flutter versi terbaru).
                  initialValue: _selected,
                  isExpanded: true, // agar judul panjang dipotong, bukan overflow
                  validator: _validateEvent,
                  decoration: _decoration('Acara', Icons.event_outlined),
                  items: [
                    for (final e in options)
                      DropdownMenuItem<Event>(
                        value: e,
                        // Acara yang sudah didaftarkan tidak bisa dipilih.
                        enabled: !widget.isRegistered(e),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.subtitle.copyWith(
                                  color: widget.isRegistered(e)
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (widget.isRegistered(e))
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: AppColors.success,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selected = value);
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Kirim Pendaftaran',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu ringkasan acara yang sedang dipilih (berubah saat dropdown diganti).
class _EventSummary extends StatelessWidget {
  final Event event;

  const _EventSummary({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: EventImage(path: event.image, width: 72, height: 72),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.dateText} • ${event.time}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  event.location,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog yang tampil setelah pendaftaran berhasil.
class _SuccessDialog extends StatelessWidget {
  final Registration registration;
  final VoidCallback onClose;

  const _SuccessDialog({required this.registration, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final event = registration.event;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: const Icon(Icons.check_circle, size: 56, color: AppColors.success),
      title: const Text(
        'Pendaftaran Berhasil',
        style: AppTextStyles.heading2,
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terima kasih, ${registration.name}. Anda terdaftar di:',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 12),
            Text(event.title, style: AppTextStyles.subtitle),
            const SizedBox(height: 6),
            Text('${event.dateText} • ${event.time}',
                style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text(event.location, style: AppTextStyles.caption),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: onClose,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Selesai', style: AppTextStyles.button),
          ),
        ),
      ],
    );
  }
}