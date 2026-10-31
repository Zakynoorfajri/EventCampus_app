import 'event.dart';

/// Model data untuk satu pendaftaran acara.
class Registration {
  final Event event;
  final String name;
  final String nim;
  final String email;
  final String phone;
  final DateTime registeredAt;
  final String status;

  const Registration({
    required this.event,
    required this.name,
    required this.nim,
    required this.email,
    required this.phone,
    required this.registeredAt,
    this.status = 'Terdaftar',
  });
}