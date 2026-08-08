class Pose {
  final String id;
  final String nameAr;
  final String nameEn;
  final String sanskrit;
  final String category; // warmup, standing, seated, balance, cooldown
  final List<String> tags; // focus areas: back, flexibility, strength, relaxation, morning, evening, balance
  final String level; // beginner, intermediate, advanced
  final int defaultSeconds;
  final String descAr;

  Pose({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.sanskrit,
    required this.category,
    required this.tags,
    required this.level,
    required this.defaultSeconds,
    required this.descAr,
  });

  factory Pose.fromJson(Map<String, dynamic> json) {
    return Pose(
      id: json['id'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      sanskrit: json['sanskrit'],
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      level: json['level'],
      defaultSeconds: json['defaultSeconds'] ?? 30,
      descAr: json['descAr'] ?? '',
    );
  }
}
