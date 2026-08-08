import 'dart:math';
import '../models/pose.dart';
import '../models/session.dart';
import '../data/poses_repository.dart';

class SessionGenerator {
  static const levelRank = {'beginner': 1, 'intermediate': 2, 'advanced': 3};

  /// focus: 'all' | 'back' | 'flexibility' | 'strength' | 'relaxation' | 'balance' | 'morning' | 'evening'
  static Future<YogaSession> generate({
    required int durationMinutes,
    required String level,
    required String focus,
  }) async {
    final all = await PosesRepository.loadAll();
    final rng = Random();
    final totalSeconds = durationMinutes * 60;

    bool levelOk(Pose p) => levelRank[p.level]! <= levelRank[level]!;

    List<Pose> warmupPool = all.where((p) => p.category == 'warmup' && levelOk(p)).toList();
    List<Pose> cooldownPool = all.where((p) => p.category == 'cooldown' && levelOk(p)).toList();
    List<Pose> mainPool = all
        .where((p) => p.category != 'warmup' && p.category != 'cooldown' && levelOk(p))
        .where((p) => focus == 'all' || p.tags.contains(focus))
        .toList();
    if (mainPool.length < 4) {
      // fallback: widen to all tags if focus too narrow
      mainPool = all.where((p) => p.category != 'warmup' && p.category != 'cooldown' && levelOk(p)).toList();
    }
    mainPool.shuffle(rng);
    warmupPool.shuffle(rng);
    cooldownPool.shuffle(rng);

    final holdScale = level == 'advanced' ? 1.25 : (level == 'intermediate' ? 1.1 : 1.0);

    final items = <SessionPoseItem>[];
    int used = 0;

    // Warmup: ~12% of time, at least 1 pose
    final warmupBudget = (totalSeconds * 0.12).round();
    int warmupUsed = 0;
    for (final p in warmupPool) {
      final s = (p.defaultSeconds * holdScale).round();
      if (warmupUsed + s > warmupBudget && warmupUsed > 0) break;
      items.add(SessionPoseItem(pose: p, seconds: s));
      warmupUsed += s;
      used += s;
      if (warmupUsed >= warmupBudget) break;
    }

    // Cooldown reserved budget ~15% (added at the end)
    final cooldownBudget = (totalSeconds * 0.15).round();

    // Main body fills the rest
    final mainBudget = totalSeconds - used - cooldownBudget;
    int mainUsed = 0;
    int idx = 0;
    while (mainUsed < mainBudget && mainPool.isNotEmpty) {
      final p = mainPool[idx % mainPool.length];
      final s = (p.defaultSeconds * holdScale).round();
      if (mainUsed + s > mainBudget && mainUsed > 0) break;
      items.add(SessionPoseItem(pose: p, seconds: s));
      mainUsed += s;
      idx++;
      if (idx > 200) break; // safety
    }
    used += mainUsed;

    // Cooldown poses to fill remaining time, always end with corpse/relaxation
    int cooldownUsed = 0;
    final corpse = cooldownPool.firstWhere((p) => p.id == 'corpse', orElse: () => cooldownPool.isNotEmpty ? cooldownPool.first : mainPool.first);
    final otherCooldown = cooldownPool.where((p) => p.id != 'corpse').toList();
    for (final p in otherCooldown) {
      final remaining = (totalSeconds - used - cooldownUsed);
      if (remaining <= corpse.defaultSeconds) break;
      final s = p.defaultSeconds;
      items.add(SessionPoseItem(pose: p, seconds: s));
      cooldownUsed += s;
    }
    final remainingForCorpse = max(20, totalSeconds - used - cooldownUsed);
    items.add(SessionPoseItem(pose: corpse, seconds: remainingForCorpse));

    return YogaSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      durationMinutes: durationMinutes,
      level: level,
      focus: focus,
      items: items,
    );
  }
}
