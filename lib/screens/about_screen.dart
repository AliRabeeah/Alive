import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('حول التطبيق')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.self_improvement, size: 80, color: accent),
              const SizedBox(height: 16),
              const Text('Alive', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('تطبيق يوجا شخصي', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
              const SizedBox(height: 32),
              const Text('تصميم وتطوير', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Text('Ali Halim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accent)),
              const SizedBox(height: 32),
              const Text('الإصدار 1.0.0', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
