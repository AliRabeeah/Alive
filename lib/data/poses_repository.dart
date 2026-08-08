import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/pose.dart';

class PosesRepository {
  static List<Pose>? _cache;

  static Future<List<Pose>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/poses.json');
    final data = json.decode(raw);
    final list = (data['poses'] as List).map((e) => Pose.fromJson(e)).toList();
    _cache = list;
    return list;
  }
}
