class Ayat {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;

  Ayat({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      nomorAyat: (json['nomorAyat'] as num).toInt(),
      teksArab: (json['teksArab'] ?? '').toString(),
      teksLatin: (json['teksLatin'] ?? '').toString(),
      teksIndonesia: (json['teksIndonesia'] ?? '').toString(),
    );
  }
}

class SurahDetail {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final List<Ayat> ayat;

  SurahDetail({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.ayat,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    final listAyat = json['ayat'] as List?;
    return SurahDetail(
      nomor: (json['nomor'] as num).toInt(),
      nama: (json['nama'] ?? '').toString(),
      namaLatin: (json['namaLatin'] ?? '').toString(),
      jumlahAyat: (json['jumlahAyat'] as num).toInt(),
      tempatTurun: (json['tempatTurun'] ?? '').toString(),
      arti: (json['arti'] ?? '').toString(),
      deskripsi: (json['deskripsi'] ?? '').toString(),
      ayat: listAyat != null
          ? listAyat.map((e) => Ayat.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }
}
