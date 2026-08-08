import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppStateProvider extends ChangeNotifier {
  int totalMinutes = 0;
  int totalSessions = 0;
  DateTime? lastSessionDate;

  Future<void> refresh() async {
    final stats = await StorageService.getStats();
    totalMinutes = stats['totalMinutes'] ?? 0;
    totalSessions = stats['totalSessions'] ?? 0;
    lastSessionDate = await StorageService.getLastSessionDate();
    notifyListeners();
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'صباح النشاط ☀️';
    if (hour >= 12 && hour < 17) return 'استراحة تجديد الطاقة 🌤️';
    if (hour >= 17 && hour < 21) return 'جلسة مسائية هادئة 🌇';
    return 'وقت الاسترخاء والنوم 🌙';
  }

  static const motivations = [
    'كل نفس تأخذه هو خطوة نحو توازن أكبر.',
    'الجسم يستمع، والعقل يهدأ — استمر.',
    'التقدم ليس بالكمال، بل بالاستمرار.',
    'خمس دقائق اليوم أفضل من صفر.',
    'أنصت لجسدك، لا تتسابق معه.',
    'التنفس العميق هو أقرب طريق للسكينة.',
  ];

  String randomMotivation() {
    final list = List<String>.from(motivations);
    list.shuffle();
    return list.first;
  }
}
