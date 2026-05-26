class ShalatScheduleResponse {
  final bool status;
  final String? message;
  final List<ShalatDaySchedule> schedules;

  ShalatScheduleResponse({
    required this.status,
    required this.message,
    required this.schedules,
  });

  factory ShalatScheduleResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final jadwalList = (data?['jadwal'] as List?) ?? [];

    return ShalatScheduleResponse(
      status: (json['status'] as bool?) ?? false,
      message: json['message']?.toString(),
      schedules: jadwalList
          .map((e) => ShalatDaySchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ShalatDaySchedule {
  final String tanggal;
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  ShalatDaySchedule({
    required this.tanggal,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory ShalatDaySchedule.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => (v ?? '').toString();

    return ShalatDaySchedule(
      tanggal: s(json['tanggal']),
      imsak: s(json['imsak']),
      subuh: s(json['subuh']),
      terbit: s(json['terbit']),
      dhuha: s(json['dhuha']),
      dzuhur: s(json['dzuhur']),
      ashar: s(json['ashar']),
      maghrib: s(json['maghrib']),
      isya: s(json['isya']),
    );
  }
}