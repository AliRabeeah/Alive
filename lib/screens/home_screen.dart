import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_state_provider.dart';
import '../services/session_generator.dart';
import 'session_screen.dart';
import 'session_setup_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alive', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appState.greeting(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                appState.randomMotivation(),
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
              ),
              const SizedBox(height: 28),

              // إحصائيات سريعة
              Row(
                children: [
                  _statCard(context, '${appState.totalSessions}', 'جلسة مكتملة'),
                  const SizedBox(width: 12),
                  _statCard(context, '${appState.totalMinutes}', 'دقيقة تمرين'),
                ],
              ),
              const SizedBox(height: 32),

              // زر ابدأ جلسة كبير
              SizedBox(
                width: double.infinity,
                height: 130,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SessionSetupScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.self_improvement, size: 36),
                      SizedBox(height: 8),
                      Text('ابدأ جلسة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // جلسة سريعة عشوائية
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accent),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: Icon(Icons.shuffle, color: accent),
                  label: Text('جلسة سريعة (مفاجئني)', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final durations = [10, 15, 20, 30];
                    final levels = ['beginner', 'intermediate'];
                    final focuses = ['all', 'back', 'flexibility', 'strength', 'relaxation'];
                    durations.shuffle();
                    levels.shuffle();
                    focuses.shuffle();
                    final session = await SessionGenerator.generate(
                      durationMinutes: durations.first,
                      level: levels.first,
                      focus: focuses.first,
                    );
                    if (context.mounted) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SessionScreen(session: session)));
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                  child: const Text('حول التطبيق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
