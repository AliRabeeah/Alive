import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../theme/app_theme_provider.dart';
import '../services/storage_service.dart';
import '../services/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final tokenController = TextEditingController();
  final repoController = TextEditingController();
  bool voiceEnabled = true;
  bool autoBackup = true;
  bool backingUp = false;
  String? backupMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    tokenController.text = await StorageService.getGithubToken() ?? '';
    repoController.text = await StorageService.getGithubRepo() ?? '';
    voiceEnabled = await StorageService.getVoiceEnabled();
    autoBackup = await StorageService.getAutoBackup();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppThemeProvider>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('المظهر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('وضع العرض')),
                    DropdownButton<ThemeMode>(
                      value: themeProvider.themeMode,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: ThemeMode.dark, child: Text('داكن')),
                        DropdownMenuItem(value: ThemeMode.light, child: Text('فاتح')),
                        DropdownMenuItem(value: ThemeMode.system, child: Text('حسب النظام')),
                      ],
                      onChanged: (v) {
                        if (v != null) themeProvider.setThemeMode(v);
                      },
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    const Expanded(child: Text('اللون المميز')),
                    GestureDetector(
                      onTap: () async {
                        Color picked = accent;
                        await ColorPicker(
                          color: accent,
                          onColorChanged: (c) => picked = c,
                          pickersEnabled: const {
                            ColorPickerType.wheel: true,
                            ColorPickerType.primary: false,
                            ColorPickerType.accent: false,
                          },
                          enableShadesSelection: true,
                          showColorCode: true,
                          colorCodeHasColor: true,
                        ).showPickerDialog(context, title: const Text('اختر اللون'));
                        await themeProvider.setAccentColor(picked);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: accent, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Text('الجلسة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: const Text('الإرشاد الصوتي'),
              value: voiceEnabled,
              onChanged: (v) async {
                setState(() => voiceEnabled = v);
                await StorageService.setVoiceEnabled(v);
              },
            ),
          ),

          const SizedBox(height: 28),
          const Text('النسخ الاحتياطي عبر GitHub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                TextField(
                  controller: tokenController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'GitHub Personal Access Token', border: OutlineInputBorder()),
                  onChanged: (v) => StorageService.setGithubToken(v),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: repoController,
                  decoration: const InputDecoration(labelText: 'المستودع (owner/repo)', border: OutlineInputBorder()),
                  onChanged: (v) => StorageService.setGithubRepo(v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('نسخ احتياطي تلقائي بعد كل جلسة'),
                  value: autoBackup,
                  onChanged: (v) async {
                    setState(() => autoBackup = v);
                    await StorageService.setAutoBackup(v);
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: backingUp
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(backingUp ? 'جارِ الرفع...' : 'نسخ احتياطي الآن'),
                    onPressed: backingUp
                        ? null
                        : () async {
                            setState(() {
                              backingUp = true;
                              backupMessage = null;
                            });
                            final result = await BackupService.backupNow();
                            setState(() {
                              backingUp = false;
                              backupMessage = switch (result) {
                                BackupResult.success => 'تم النسخ الاحتياطي بنجاح ✅',
                                BackupResult.noToken => 'الرجاء إدخال GitHub Token',
                                BackupResult.noRepo => 'الرجاء إدخال المستودع بصيغة owner/repo',
                                BackupResult.authError => 'خطأ في الصلاحيات، تحقق من التوكن',
                                BackupResult.networkError => 'خطأ في الاتصال بالإنترنت',
                                BackupResult.unknownError => 'حدث خطأ غير متوقع',
                              };
                            });
                          },
                  ),
                ),
                if (backupMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(backupMessage!, style: TextStyle(color: accent)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
