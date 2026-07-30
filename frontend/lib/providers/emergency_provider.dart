import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recovery_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

final recoveryServiceProvider = Provider<RecoveryService>((ref) {
  return RecoveryService();
});

// A provider to manage the trusted contact number
class TrustedContactNotifier extends StateNotifier<String?> {
  TrustedContactNotifier() : super(null) {
    _loadContact();
  }

  static const String _boxName = 'settings_box';
  static const String _key = 'trusted_contact';

  Future<void> _loadContact() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    final box = Hive.box(_boxName);
    state = box.get(_key);
  }

  Future<void> setContact(String number) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    final box = Hive.box(_boxName);
    await box.put(_key, number);
    state = number;
  }
}

final trustedContactProvider = StateNotifierProvider<TrustedContactNotifier, String?>((ref) {
  return TrustedContactNotifier();
});
