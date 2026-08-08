import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

enum BackupResult { success, noToken, noRepo, networkError, authError, unknownError }

class BackupService {
  /// يرفع نسخة JSON من بيانات التطبيق (السجل، الإحصائيات، المفضلة) إلى
  /// ملف backup/alive_backup.json داخل مستودع GitHub الذي حدده المستخدم.
  static Future<BackupResult> backupNow() async {
    final token = await StorageService.getGithubToken();
    final repo = await StorageService.getGithubRepo(); // format: owner/repo

    if (token == null || token.trim().isEmpty) return BackupResult.noToken;
    if (repo == null || repo.trim().isEmpty || !repo.contains('/')) return BackupResult.noRepo;

    final path = 'backup/alive_backup.json';
    final url = Uri.parse('https://api.github.com/repos/$repo/contents/$path');

    try {
      // 1. تحقق إذا الملف موجود مسبقاً لأخذ الـ sha (مطلوب للتحديث)
      String? sha;
      final getResp = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github+json',
        },
      );
      if (getResp.statusCode == 200) {
        final data = json.decode(getResp.body);
        sha = data['sha'];
      } else if (getResp.statusCode == 401 || getResp.statusCode == 403) {
        return BackupResult.authError;
      }

      // 2. جهّز المحتوى
      final payload = await StorageService.buildBackupPayload();
      final content = base64Encode(utf8.encode(const JsonEncoder.withIndent('  ').convert(payload)));

      final body = {
        'message': 'Alive backup: ${DateTime.now().toIso8601String()}',
        'content': content,
        if (sha != null) 'sha': sha,
      };

      final putResp = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (putResp.statusCode == 200 || putResp.statusCode == 201) {
        return BackupResult.success;
      } else if (putResp.statusCode == 401 || putResp.statusCode == 403) {
        return BackupResult.authError;
      } else {
        return BackupResult.unknownError;
      }
    } catch (e) {
      return BackupResult.networkError;
    }
  }
}
