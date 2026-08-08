import 'pose.dart';

class SessionPoseItem {
  final Pose pose;
  final int seconds;
  SessionPoseItem({required this.pose, required this.seconds});
}

class YogaSession {
  final String id;
  final DateTime createdAt;
  final int durationMinutes;
  final String level;
  final String focus;
  final List<SessionPoseItem> items;
  bool completed;

  YogaSession({
    required this.id,
    required this.createdAt,
    required this.durationMinutes,
    required this.level,
    required this.focus,
    required this.items,
    this.completed = false,
  });

  Map<String, dynamic> toHistoryJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'level': level,
        'focus': focus,
        'poseCount': items.length,
        'completed': completed,
      };
}

class SessionHistoryEntry {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final String level;
  final String focus;
  final bool completed;

  SessionHistoryEntry({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.level,
    required this.focus,
    required this.completed,
  });

  factory SessionHistoryEntry.fromJson(Map<String, dynamic> j) => SessionHistoryEntry(
        id: j['id'],
        date: DateTime.parse(j['createdAt']),
        durationMinutes: j['durationMinutes'],
        level: j['level'],
        focus: j['focus'],
        completed: j['completed'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': date.toIso8601String(),
        'durationMinutes': durationMinutes,
        'level': level,
        'focus': focus,
        'completed': completed,
      };
}
