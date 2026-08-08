import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../models/session.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SessionHistoryEntry> history = [];
  Map<String, int> stats = {'totalMinutes': 0, 'totalSessions': 0};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await StorageService.getHistory();
    final s = await StorageService.getStats();
    setState(() {
      history = h.reversed.toList();
      stats = s;
    });
  }

  static const focusLabels = {
    'all': 'شامل', 'back': 'الظهر', 'flexibility': 'المرونة', 'strength': 'القوة',
    'relaxation': 'الاسترخاء', 'balance': 'التوازن', 'morning': 'صباحي', 'evening': 'مسائي',
  };
  static const levelLabels = {'beginner': 'مبتدئ', 'intermediate': 'متوسط', 'advanced': 'متقدم'};

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('السجل والتقدم')),
      body: history.isEmpty
          ? const Center(child: Text('لا توجد جلسات مسجلة بعد'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16)),
                        child: Column(children: [
                          Text('${stats['totalSessions']}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: accent)),
                          const Text('إجمالي الجلسات'),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16)),
                        child: Column(children: [
                          Text('${stats['totalMinutes']}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: accent)),
                          const Text('إجمالي الدقائق'),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('آخر الجلسات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...history.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: accent.withOpacity(0.15), child: Icon(Icons.self_improvement, color: accent)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${e.durationMinutes} دقيقة · ${levelLabels[e.level]} · ${focusLabels[e.focus]}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(intl.DateFormat('yyyy/MM/dd - HH:mm').format(e.date),
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
    );
  }
}
