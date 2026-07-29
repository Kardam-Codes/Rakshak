import 'package:hive_flutter/hive_flutter.dart';

class ScanAnalyticsService {
  static const String _boxName = 'scan_analytics_box';

  Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  Future<void> trackScan({
    required String scanType,
    required String riskLevel,
    required int durationMs,
  }) async {
    final totalScans = (_box.get('total_scans', defaultValue: 0) as int) + 1;
    final typeScans = (_box.get('type_$scanType', defaultValue: 0) as int) + 1;
    final riskScans = (_box.get('risk_$riskLevel', defaultValue: 0) as int) + 1;
    final totalTime = (_box.get('total_duration_ms', defaultValue: 0) as int) + durationMs;

    await _box.put('total_scans', totalScans);
    await _box.put('type_$scanType', typeScans);
    await _box.put('risk_$riskLevel', riskScans);
    await _box.put('total_duration_ms', totalTime);
  }

  Map<String, dynamic> getAnalyticsSummary() {
    final totalScans = _box.get('total_scans', defaultValue: 0) as int;
    final totalTime = _box.get('total_duration_ms', defaultValue: 0) as int;
    final avgTime = totalScans > 0 ? (totalTime / totalScans).round() : 0;

    return {
      'totalScans': totalScans,
      'qrScans': _box.get('type_qr', defaultValue: 0),
      'urlScans': _box.get('type_url', defaultValue: 0),
      'imageScans': _box.get('type_image', defaultValue: 0),
      'screenshotScans': _box.get('type_screenshot', defaultValue: 0),
      'safeScans': _box.get('risk_safe', defaultValue: 0),
      'mediumScans': _box.get('risk_medium', defaultValue: 0),
      'highScans': _box.get('risk_high', defaultValue: 0),
      'averageScanTimeMs': avgTime,
    };
  }
}
