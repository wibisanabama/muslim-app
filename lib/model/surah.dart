class Surah {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;

  Surah({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      nomor: (json['nomor'] as num).toInt(),
      nama: (json['nama'] ?? '').toString(),
      namaLatin: (json['namaLatin'] ?? '').toString(),
      jumlahAyat: (json['jumlahAyat'] as num).toInt(),
      tempatTurun: (json['tempatTurun'] ?? '').toString(),
      arti: (json['arti'] ?? '').toString(),
      deskripsi: (json['deskripsi'] ?? '').toString(),
    );
  }
}
