class Mood {
  final String value;
  final String emoji;
  int count;

  Mood({
    required this.value,
    required this.emoji,
    this.count = 0,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      value: json['value'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'emoji': emoji,
      'count': count,
    };
  }
}
