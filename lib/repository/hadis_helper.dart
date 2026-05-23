class Hadis {
  final int number;
  final String title;
  final String narrator;
  final String arabic;
  final String latin;
  final String translation;
  final String explanation;

  const Hadis({
    required this.number,
    required this.title,
    required this.narrator,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.explanation,
  });
}

class HadisHelper {
  static const List<Hadis> list = [
    Hadis(
      number: 1,
      title: "Niat dalam Beramal",
      narrator: "HR. Bukhari & Muslim",
      arabic: "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى",
      latin: "Innamal a'maalu bin-niyyaat, wa innamaa likullim-ri'im-maa nawaa.",
      translation: "Sesungguhnya segala perbuatan itu bergantung pada niatnya, dan sesungguhnya setiap orang memperoleh apa yang ia niatkan.",
      explanation: "Hadis ini menjelaskan bahwa setiap perbuatan dinilai sah dan mendapat pahala di sisi Allah jika didasari oleh niat yang ikhlas dan tujuan yang benar.",
    ),
    Hadis(
      number: 2,
      title: "Menuntut Ilmu",
      narrator: "HR. Ibnu Majah",
      arabic: "طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ",
      latin: "Tholabul 'ilmi fariidhotun 'alaa kulli muslim.",
      translation: "Menuntut ilmu itu wajib atas setiap orang muslim.",
      explanation: "Kewajiban menuntut ilmu mencakup ilmu syar'i untuk beribadah dengan benar serta ilmu umum yang bermanfaat bagi kehidupan dan kemaslahatan umat.",
    ),
    Hadis(
      number: 3,
      title: "Senyum adalah Sedekah",
      narrator: "HR. Tirmidzi",
      arabic: "تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ",
      latin: "Tabassumuka fii wajhi akhiika laka shodaqoh.",
      translation: "Senyummu di hadapan saudaramu adalah sedekah bagimu.",
      explanation: "Hadis ini mengajarkan pentingnya bermuka manis, ramah, dan menyenangkan hati orang lain, yang secara sosial bernilai pahala setara sedekah materi.",
    ),
    Hadis(
      number: 4,
      title: "Keutamaan Belajar Al-Quran",
      narrator: "HR. Bukhari",
      arabic: "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ",
      latin: "Khoirukum man ta'allamal qur'aana wa 'allamahu.",
      translation: "Sebaik-baik kalian adalah orang yang belajar Al-Quran dan mengajarkannya.",
      explanation: "Belajar Al-Quran meliputi memperbaiki bacaan (tajwid), memahami tafsir makna, serta mengamalkan isinya dalam kehidupan sehari-hari.",
    ),
    Hadis(
      number: 5,
      title: "Kebersihan Sebagian dari Iman",
      narrator: "HR. Muslim",
      arabic: "الطَّهُورُ شَطْرُ الإِيمَانِ",
      latin: "At-thohuuru syathrul iimaan.",
      translation: "Bersuci (kebersihan) itu adalah sebagian dari iman.",
      explanation: "Islam sangat menekankan kebersihan fisik, lingkungan, dan spiritual sebagai prasyarat ibadah dan wujud kesehatan jiwa raga.",
    ),
    Hadis(
      number: 6,
      title: "Kasih Sayang terhadap Sesama",
      narrator: "HR. Bukhari",
      arabic: "مَنْ لاَ يَرْحَمْ لاَ يُرْحَمْ",
      latin: "Man laa yarham laa yurham.",
      translation: "Barangsiapa yang tidak menyayangi, niscaya ia tidak akan disayangi.",
      explanation: "Kasih sayang adalah sifat luhur. Allah mencintai hamba-hamba-Nya yang bersikap lembut dan menebarkan kasih sayang di muka bumi.",
    ),
    Hadis(
      number: 7,
      title: "Mencintai Saudara seperti Diri Sendiri",
      narrator: "HR. Bukhari & Muslim",
      arabic: "لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ",
      latin: "Laa yu'minu ahadukum hattaa yuhibba li-akhiihi maa yuhibbu linafsihi.",
      translation: "Tidak sempurna iman salah seorang di antara kalian sampai ia mencintai untuk saudaranya apa yang ia cintai untuk dirinya sendiri.",
      explanation: "Sempurnanya iman diukur dari empati kita, di mana kita mendambakan keselamatan, kebaikan, dan kemudahan bagi orang lain sebagaimana untuk diri kita.",
    ),
    Hadis(
      number: 8,
      title: "Menunjukkan Jalan Kebaikan",
      narrator: "HR. Muslim",
      arabic: "مَنْ دَلَّ عَلَى خَيْرٍ فَلَهُ مِثْلُ أَجْرِ فَاعِلِهِ",
      latin: "Man dalla 'alaa khoirin falahu mithlu ajri faa'ilihi.",
      translation: "Barangsiapa yang menunjukkan kepada kebaikan, maka baginya pahala seperti pahala orang yang mengerjakannya.",
      explanation: "Mengajak atau menyebarkan kebaikan, nasihat baik, atau ilmu yang bermanfaat mendatangkan aliran pahala jariah tanpa mengurangi pahala pelaku aslinya.",
    ),
    Hadis(
      number: 9,
      title: "Kata-Kata yang Baik",
      narrator: "HR. Bukhari & Muslim",
      arabic: "وَالْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ",
      latin: "Wal-kalimatut-thoyyibatu shodaqoh.",
      translation: "Dan kata-kata yang baik adalah sedekah.",
      explanation: "Berbicara sopan, menyapa dengan ramah, memberikan ucapan semangat, atau mendamaikan pihak yang berselisih bernilai sedekah lisan.",
    ),
    Hadis(
      number: 10,
      title: "Menjaga Lisan dan Tangan",
      narrator: "HR. Bukhari & Muslim",
      arabic: "الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ",
      latin: "Al-muslimu man salimal muslimuuna min lisaanihi wa yadihi.",
      translation: "Seorang muslim sejati adalah orang yang muslim lainnya selamat dari gangguan lisan dan tangannya.",
      explanation: "Islam mendidik pemeluknya untuk menjamin rasa aman bagi sesama, tidak memfitnah, merundung, mencaci, ataupun menganiaya secara fisik.",
    ),
    Hadis(
      number: 11,
      title: "Keindahan Akhlak",
      narrator: "HR. Ahmad",
      arabic: "إِنَّمَا بُعِثْتُ لأُتَمِّمَ صَالِحَ الأَخْلاَقِ",
      latin: "Innamaa bu'ithtu li-utammima shoolihal akhlaaq.",
      translation: "Sesungguhnya aku (Muhammad) diutus hanyalah untuk menyempurnakan akhlak yang mulia.",
      explanation: "Misi utama dakwah Rasulullah SAW adalah menanamkan integritas moral, keadaban, kebaikan perilaku, serta keluhuran budi pekerti.",
    ),
    Hadis(
      number: 12,
      title: "Menjaga Silaturahmi",
      narrator: "HR. Bukhari & Muslim",
      arabic: "لاَ يَدْخُلُ الْجَنَّةَ قَاطِعٌ",
      latin: "Laa yadkhulul jannata qoothi'.",
      translation: "Tidak akan masuk surga orang yang memutus tali silaturahmi.",
      explanation: "Menjaga persaudaraan dengan kerabat, tetangga, dan teman sangat penting. Memutuskan hubungan kekerabatan adalah dosa besar dalam pandangan syariat.",
    ),
  ];
}
