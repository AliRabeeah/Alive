import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/session.dart';
import '../services/tts_service.dart';
import '../services/storage_service.dart';
import '../services/backup_service.dart';

class SessionScreen extends StatefulWidget {
  final YogaSession session;
  const SessionScreen({super.key, required this.session});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int currentIndex = 0;
  int secondsLeft = 0;
  Timer? _timer;
  bool paused = false;
  bool voiceEnabled = true;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initVoice();
    _startPose(0);
  }

  Future<void> _initVoice() async {
    voiceEnabled = await StorageService.getVoiceEnabled();
  }

  int get totalSeconds => widget.session.items.fold(0, (a, b) => a + b.seconds);

  int get elapsedSeconds {
    int elapsed = 0;
    for (int i = 0; i < currentIndex; i++) {
      elapsed += widget.session.items[i].seconds;
    }
    elapsed += (widget.session.items[currentIndex].seconds - secondsLeft);
    return elapsed;
  }

  void _startPose(int index) {
    _timer?.cancel();
    final item = widget.session.items[index];
    setState(() {
      currentIndex = index;
      secondsLeft = item.seconds;
    });
    HapticFeedback.mediumImpact();
    if (voiceEnabled) {
      TtsService.speak('${item.pose.nameAr}. ${item.pose.descAr}');
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (paused) return;
      setState(() => secondsLeft--);
      if (secondsLeft <= 0) {
        t.cancel();
        _nextPose();
      }
    });
  }

  void _nextPose() {
    if (currentIndex + 1 < widget.session.items.length) {
      _startPose(currentIndex + 1);
    } else {
      _completeSession();
    }
  }

  void _prevPose() {
    if (currentIndex > 0) {
      _startPose(currentIndex - 1);
    }
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    TtsService.stop();
    WakelockPlus.disable();
    setState(() => finished = true);

    final entry = SessionHistoryEntry(
      id: widget.session.id,
      date: DateTime.now(),
      durationMinutes: widget.session.durationMinutes,
      level: widget.session.level,
      focus: widget.session.focus,
      completed: true,
    );
    await StorageService.addHistoryEntry(entry);

    final autoBackup = await StorageService.getAutoBackup();
    if (autoBackup) {
      // نفّذ النسخ الاحتياطي بالخلفية دون انتظار المستخدم
      BackupService.backupNow();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    TtsService.stop();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    if (finished) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: accent, size: 90),
                  const SizedBox(height: 20),
                  const Text('أحسنت! الجلسة اكتملت 🌿', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('${widget.session.durationMinutes} دقيقة من الاسترخاء والتوازن'),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                      child: const Text('العودة للرئيسية'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final item = widget.session.items[currentIndex];
    final overallProgress = elapsedSeconds / totalSeconds;
    final poseProgress = 1 - (secondsLeft / item.seconds);

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentIndex + 1} / ${widget.session.items.length}'),
        actions: [
          IconButton(
            icon: Icon(voiceEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () async {
              setState(() => voiceEnabled = !voiceEnabled);
              await StorageService.setVoiceEnabled(voiceEnabled);
              if (!voiceEnabled) TtsService.stop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: overallProgress.clamp(0, 1),
              backgroundColor: Theme.of(context).cardTheme.color,
              color: accent,
              minHeight: 4,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardTheme.color,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 220,
                            height: 220,
                            child: CircularProgressIndicator(
                              value: poseProgress.clamp(0, 1),
                              strokeWidth: 8,
                              backgroundColor: accent.withOpacity(0.15),
                              color: accent,
                            ),
                          ),
                          Icon(Icons.self_improvement, size: 70, color: accent),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('$secondsLeft', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: accent)),
                    const SizedBox(height: 20),
                    Text(item.pose.nameAr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    Text(item.pose.sanskrit, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))),
                    const SizedBox(height: 14),
                    Text(item.pose.descAr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.5)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 34,
                    icon: const Icon(Icons.replay),
                    onPressed: _prevPose,
                  ),
                  IconButton(
                    iconSize: 60,
                    icon: Icon(paused ? Icons.play_circle_fill : Icons.pause_circle_filled, color: accent),
                    onPressed: () => setState(() => paused = !paused),
                  ),
                  IconButton(
                    iconSize: 34,
                    icon: const Icon(Icons.skip_next),
                    onPressed: _nextPose,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
