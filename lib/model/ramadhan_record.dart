class ShalatDayLog {
  final int day;
  final Map<String, bool> prayers;

  ShalatDayLog({required this.day, required this.prayers});

  factory ShalatDayLog.fromJson(Map<String, dynamic> json) {
    final prayersJson = json['prayers'] as Map<String, dynamic>? ?? {};
    return ShalatDayLog(
      day: json['day'] as int? ?? 1,
      prayers: prayersJson.map((key, value) => MapEntry(key, value as bool)),
    );
  }

  Map<String, dynamic> toJson() => {'day': day, 'prayers': prayers};

  factory ShalatDayLog.createDefault(int day) {
    return ShalatDayLog(
      day: day,
      prayers: {
        'Subuh': false,
        'Dzuhur': false,
        'Ashar': false,
        'Maghrib': false,
        'Isya': false,
        'Tarawih': false,
        'Witir': false,
        'Dhuha': false,
        'Tahajjud': false,
      },
    );
  }
}

class CeramahLog {
  final String id;
  final DateTime date;
  final String speaker;
  final String title;
  final String summary;

  CeramahLog({
    required this.id,
    required this.date,
    required this.speaker,
    required this.title,
    required this.summary,
  });

  factory CeramahLog.fromJson(Map<String, dynamic> json) {
    return CeramahLog(
      id: json['id'] as String? ?? '',
      date: DateTime.parse(
        json['date'] as String? ?? DateTime.now().toIso8601String(),
      ),
      speaker: json['speaker'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'speaker': speaker,
    'title': title,
    'summary': summary,
  };
}

class InfaqLog {
  final String id;
  final DateTime date;
  final double amount;
  final String notes;

  InfaqLog({
    required this.id,
    required this.date,
    required this.amount,
    required this.notes,
  });

  factory InfaqLog.fromJson(Map<String, dynamic> json) {
    return InfaqLog(
      id: json['id'] as String? ?? '',
      date: DateTime.parse(
        json['date'] as String? ?? DateTime.now().toIso8601String(),
      ),
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'amount': amount,
    'notes': notes,
  };
}