/// Model data untuk satu acara kampus.
/// Dengan model ini kita tidak memakai Map mentah di widget.
class Event {
  final int id;
  final String title;
  final String category;
  final String description;
  final String image;
  final DateTime date;
  final String time;
  final String location;
  final String organizer;
  final int quota;
  final int price; // 0 berarti gratis
  final List<String> requirements;
  final String status; // Terbuka / Penuh / Selesai

  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.image,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    required this.quota,
    required this.price,
    required this.requirements,
    required this.status,
  });

  /// Factory constructor: mengubah Map hasil jsonDecode menjadi objek Event.
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      location: json['location'] as String,
      organizer: json['organizer'] as String,
      quota: json['quota'] as int,
      price: json['price'] as int,
      requirements: List<String>.from(json['requirements'] as List),
      status: json['status'] as String,
    );
  }

  /// True jika acara masih bisa didaftarkan.
  bool get isOpen => status == 'Terbuka';

  /// Teks biaya yang siap ditampilkan.
  String get priceText {
    if (price == 0) return 'Gratis';
    final digits = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final fromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  /// Tanggal dalam format Indonesia, contoh: 15 Nov 2026.
  String get dateText {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }
}