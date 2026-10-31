import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';

import 'package:uas_pemrograman_mobile_23552010157/main.dart';

void main() {
  testWidgets('Aplikasi memuat daftar acara dan menampilkan Beranda',
      (WidgetTester tester) async {
    // Ukuran layar 360x800 piksel logis.
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const EventCampusApp());
    await tester.pumpAndSettle(); // tunggu loading JSON selesai

    expect(find.text('Halo, Mahasiswa! 👋'), findsOneWidget);
    expect(find.text('Acara Populer'), findsOneWidget);
  });
}
