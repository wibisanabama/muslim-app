class QuranQuote {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;

  const QuranQuote({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
  });
}

class QuranQuoteHelper {
  static const List<QuranQuote> quotes = [
    QuranQuote(
      surahNumber: 94,
      surahName: "Al-Insyirah",
      ayahNumber: 5,
      teksArab: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
      teksLatin: "Fa inna ma'al-'usri yusrā",
      teksIndonesia: "Karena sesungguhnya sesudah kesulitan itu ada kemudahan.",
    ),
    QuranQuote(
      surahNumber: 94,
      surahName: "Al-Insyirah",
      ayahNumber: 6,
      teksArab: "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
      teksLatin: "Inna ma'al-'usri yusrā",
      teksIndonesia: "Sesungguhnya sesudah kesulitan itu ada kemudahan.",
    ),
    QuranQuote(
      surahNumber: 13,
      surahName: "Ar-Ra'd",
      ayahNumber: 28,
      teksArab: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
      teksLatin: "Alā biżikrillāhi taṭma'innul-qulūb",
      teksIndonesia: "Ingatlah, hanya dengan mengingati Allah-lah hati menjadi tenteram.",
    ),
    QuranQuote(
      surahNumber: 2,
      surahName: "Al-Baqarah",
      ayahNumber: 186,
      teksArab: "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ",
      teksLatin: "Wa iżā sa'alaka 'ibādī 'annī fa innī qarīb, ujību da'watad-dā'i iżā da'ān",
      teksIndonesia: "Dan apabila hamba-hamba-Ku bertanya kepadamu tentang Aku, maka (jawablah), bahwasanya Aku adalah dekat. Aku mengabulkan permohonan orang yang berdoa apabila ia memohon kepada-Ku.",
    ),
    QuranQuote(
      surahNumber: 2,
      surahName: "Al-Baqarah",
      ayahNumber: 286,
      teksArab: "لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا",
      teksLatin: "Lā yukallifullāhu nafsan illā wus'ahā",
      teksIndonesia: "Allah tidak membebani seseorang melainkan sesuai dengan kesanggupannya.",
    ),
    QuranQuote(
      surahNumber: 3,
      surahName: "Ali 'Imran",
      ayahNumber: 139,
      teksArab: "وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنْتُمُ الْأَعْلَوْنَ إِنْ كُنْتُمْ مُؤْمِنِينَ",
      teksLatin: "Wa lā tahinū wa lā taḥzanū wa antumul-a'launa in kuntum mu'minīn",
      teksIndonesia: "Janganlah kamu bersikap lemah, dan janganlah (pula) kamu bersedih hati, padahal kamulah orang-orang yang paling tinggi (derajatnya), jika kamu orang-orang yang beriman.",
    ),
    QuranQuote(
      surahNumber: 20,
      surahName: "Thaha",
      ayahNumber: 46,
      teksArab: "قَالَ لَا تَخَافَا ۖ إِنَّنِي مَعَكُمَا أَسْمَعُ وَأَرَىٰ",
      teksLatin: "Qāla lā takhāfā innanī ma'akumā asma'u wa arā",
      teksIndonesia: "Dia (Allah) berfirman, 'Janganlah kamu berdua khawatir, sesungguhnya Aku bersamamu, Aku mendengar dan melihat.'",
    ),
    QuranQuote(
      surahNumber: 65,
      surahName: "At-Talaq",
      ayahNumber: 3,
      teksArab: "وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ ۚ وَمَنْ يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ",
      teksLatin: "Wa yarzuq-hu min ḥaiṡu lā yaḥtasib, wa may yatawakkal 'alallāhi fa huwa ḥasbuh",
      teksIndonesia: "Dan Dia memberinya rezeki dari arah yang tidak disangka-sangkanya. Dan barangsiapa bertawakal kepada Allah, niscaya Allah akan mencukupkan (keperluan)nya.",
    ),
    QuranQuote(
      surahNumber: 29,
      surahName: "Al-Ankabut",
      ayahNumber: 69,
      teksArab: "وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا ۚ وَإِنَّ اللَّهَ لَمَعَ الْمُحْسِنِينَ",
      teksLatin: "Wallażīna jāhadū fīnā lanahdiyannahum subulanā, wa innallāha lama'al-muḥsinīn",
      teksIndonesia: "Dan orang-orang yang berjihad untuk (mencari keridhaan) Kami, benar-benar akan Kami tunjukkan kepada mereka jalan-jalan Kami. Dan sesungguhnya Allah benar-benar beserta orang-orang yang berbuat baik.",
    ),
    QuranQuote(
      surahNumber: 2,
      surahName: "Al-Baqarah",
      ayahNumber: 152,
      teksArab: "فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ",
      teksLatin: "Fażkurūnī ażkurkum wasykurū lī wa lā takfurūn",
      teksIndonesia: "Karena itu, ingatlah kamu kepada-Ku niscaya Aku ingat (pula) kepadamu, dan bersyukurlah kepada-Ku, dan janganlah kamu mengingkari (nikmat)-Ku.",
    ),
  ];
}
