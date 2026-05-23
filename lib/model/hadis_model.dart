class Hadis {
  final int number;
  final String arabic;
  final String translation;

  Hadis({
    required this.number,
    required this.arabic,
    required this.translation,
  });

  factory Hadis.fromJson(Map<String, dynamic> json) {
    return Hadis(
      number: json['number'] as int,
      arabic: json['arab'] as String,
      translation: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'arab': arabic,
      'id': translation,
    };
  }
}
