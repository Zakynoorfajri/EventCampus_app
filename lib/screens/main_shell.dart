import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/registration.dart';
import '../services/event_service.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/empty_state.dart';
import 'event_detail_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'my_events_screen.dart';
import 'registration_screen.dart';

/// Halaman induk: memegang SEMUA state bersama dan bottom navigation.
/// - Data acara (dimuat dari JSON)
/// - Status loading / error
/// - Daftar pendaftaran
/// - Tab yang sedang aktif
/// Halaman anak hanya menerima data dan melapor lewat callback.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final EventService _service = EventService();

  // ---------- State ----------
  List<Event> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  int _tabIndex = 0;
  String _exploreCategory = 'Semua';
  int _exploreRequestId = 0;

  /// Daftar pendaftaran selama aplikasi berjalan (hilang saat ditutup).
  final List<Registration> _registrations = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // ---------- Data ----------

  /// Memuat JSON. Dipanggil saat awal dan saat tombol "Coba Lagi" ditekan.
  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _service.loadEvents();
      if (!mounted) return; // halaman sudah ditutup, jangan setState
      setState(() {
        _events = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// True jika acara tersebut sudah ada di daftar pendaftaran.
  bool _isRegistered(Event event) {
    return _registrations.any((r) => r.event.id == event.id);
  }

  /// Menyimpan pendaftaran baru lalu memperbarui tampilan.
  void _addRegistration(Registration registration) {
    setState(() => _registrations.add(registration));
  }

  // ---------- Navigasi ----------

  /// Pindah ke tab Jelajah, opsional dengan kategori tertentu.
  /// requestId dinaikkan agar Explore tahu ada permintaan baru.
  void _openExplore([String category = 'Semua']) {
    setState(() {
      _exploreCategory = category;
      _exploreRequestId++;
      _tabIndex = 1;
    });
  }

  /// Membuka halaman detail. Objek Event dikirim lewat constructor.
  void _openDetail(Event event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(
          event: event,
          isRegistered: () => _isRegistered(event),
          onRegister: _openRegistration,
        ),
      ),
    );
  }

  /// Membuka formulir dan menunggu sampai halaman formulir ditutup.
  Future<void> _openRegistration(Event event) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RegistrationScreen(
          event: event,
          events: _events,
          isRegistered: _isRegistered,
          onSubmit: _addRegistration,
        ),
      ),
    );
  }

  // ---------- Tampilan ----------

  Widget _buildHome() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Gagal memuat acara',
        message: 'Terjadi kesalahan saat membaca data. Silakan coba lagi.',
        actionLabel: 'Coba Lagi',
        onAction: _loadEvents,
      );
    }
    return HomeScreen(
      events: _events,
      onEventTap: _openDetail,
      onCategoryTap: _openExplore,
      onSearchTap: _openExplore,
      onSeeAllTap: _openExplore,
    );
  }

  @override
  Widget build(BuildContext context) {
    // PopScope: jika bukan di tab Beranda, tombol back sistem
    // kembali ke Beranda dulu (bukan langsung keluar dari aplikasi).
    return PopScope(
      canPop: _tabIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) setState(() => _tabIndex = 0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _tabIndex,
          children: [
            _buildHome(),
            ExploreScreen(
              events: _events,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              onRetry: _loadEvents,
              onEventTap: _openDetail,
              initialCategory: _exploreCategory,
              requestId: _exploreRequestId,
            ),
            MyEventsScreen(
              registrations: _registrations,
              onEventTap: _openDetail,
              onBrowseTap: _openExplore,
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavbar(
          currentIndex: _tabIndex,
          onTap: (i) => setState(() => _tabIndex = i),
        ),
      ),
    );
  }
}