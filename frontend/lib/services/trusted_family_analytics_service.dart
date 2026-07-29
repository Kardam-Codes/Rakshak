import 'package:hive_flutter/hive_flutter.dart';

class TrustedFamilyAnalyticsService {
  static const String _boxName = 'trusted_family_analytics_box';

  Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  Future<void> logEvent(String eventName) async {
    final count = (_box.get(eventName, defaultValue: 0) as int) + 1;
    await _box.put(eventName, count);
  }

  Map<String, int> getAnalyticsSummary() {
    return {
      'alertsSent': _box.get('alerts_sent', defaultValue: 0),
      'cancelledAlerts': _box.get('cancelled_alerts', defaultValue: 0),
      'countdownCancelled': _box.get('countdown_cancelled', defaultValue: 0),
      'emailsSent': _box.get('emails_sent', defaultValue: 0),
      'deliverySuccess': _box.get('delivery_success', defaultValue: 0),
    };
  }
}
