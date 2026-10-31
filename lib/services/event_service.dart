import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/event.dart';

/// Service yang bertugas membaca data acara dari file JSON lokal.
/// Memisahkan urusan data dari tampilan membuat kode lebih rapi.
class EventService {
  static const String _path = 'assets/data/events.json';

  /// Membaca dan mengubah JSON menjadi daftar Event.
  /// Jika gagal (file hilang / format salah), exception akan dilempar
  /// dan ditangkap oleh halaman untuk menampilkan error state.
  Future<List<Event>> loadEvents() async {
    // Jeda singkat agar loading state terlihat saat demo.
    // Boleh dihapus jika tidak diperlukan.
    await Future.delayed(const Duration(milliseconds: 600));

    final raw = await rootBundle.loadString(_path);
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Event.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}