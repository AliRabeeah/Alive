import 'package:flutter/material.dart';
import '../services/session_generator.dart';
import '../services/storage_service.dart';
import 'session_screen.dart';

class SessionSetupScreen extends StatefulWidget {
  const SessionSetupScreen({super.key});

  @override
  State<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends State<SessionSetupScreen> {
  int duration = 20;
  String level = 'beginner';
  String focus = 'all';
  bool loading = false;

  final durations = [10, 15, 20, 30, 45, 60];
  final levels = {'beginner': 'مبتدئ', 'intermediate': 'متوسط', 'advanced': 'متقدم'};
  final focuses = {
    'all': 'شامل',
    'back': 'الظهر',
    'flexibility': 'المرونة',
    'strength': 'القوة',
    'relaxation': 'الاسترخاء',
    'balance': 'التوازن',
    'morning': 'صباحي',
    'evening': 'مسائي',
  };

  @override
  void initState() {
    super.initState();
    _loadLast();
  }

  Future<void> _loadLast() async {
    final s = await StorageService.getLastSettings();
    setState(() {
      duration = s['duration'];
      level = s['level'];
      focus = s['focus'];
    });
  }

  Widget _chipGroup<T>(Map<T, String> items, T selected, ValueChanged<T> onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.entries.map((e) {
        final isSelected = e.key == selected;
        final accent = Theme.of(context).colorScheme.primary;
        return ChoiceChip(
          label: Text(e.value),
          selected: isSelected,
          onSelected: (_) => onSelect(e.key),
          selectedColor: accent,
          labelStyle: TextStyle(
            color: isSelected ? Colors.black : null,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Theme.of(context).cardTheme.color,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('إعداد الجلسة')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('المدة (دقيقة)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _chipGroup<int>(
                {for (final d in durations) d: '$d'},
                duration,
                (v) => setState(() => duration = v),
              ),
              const SizedBox(height: 28),
              const Text('المستوى', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _chipGroup<String>(levels, level, (v) => setState(() => level = v)),
              const SizedBox(height: 28),
              const Text('التركيز', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _chipGroup<String>(focuses, focus, (v) => setState(() => focus = v)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          setState(() => loading = true);
                          await StorageService.saveLastSettings(duration: duration, level: level, focus: focus);
                          final session = await SessionGenerator.generate(
                            durationMinutes: duration,
                            level: level,
                            focus: focus,
                          );
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => SessionScreen(session: session)),
                            );
                          }
                        },
                  child: loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('توليد الجلسة والبدء'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
