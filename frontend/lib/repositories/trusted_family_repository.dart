import 'package:hive_flutter/hive_flutter.dart';
import '../../core/database/app_database.dart';
import '../../models/trusted_contact.dart';

class TrustedFamilyRepository {
  final AppDatabase _db;
  static const String _settingsBoxName = 'trusted_family_settings_box';

  TrustedFamilyRepository(this._db);

  Stream<List<TrustedContact>> watchContacts() {
    return _db.trustedContactsStream;
  }

  Future<List<TrustedContact>> getAllContacts() async {
    return _db.trustedContactsStream.first;
  }

  Future<void> addContact(TrustedContact contact) async {
    final current = await _db.trustedContactsStream.first;

    // PART 4 Requirement: Maximum 5 trusted contacts
    if (current.length >= 5) {
      throw Exception('Maximum 5 trusted contacts allowed. Please remove a contact before adding a new one.');
    }

    // Duplicate detection (phone)
    final isDuplicate = current.any(
      (c) => c.phoneNumber.replaceAll(RegExp(r'\D'), '') == contact.phoneNumber.replaceAll(RegExp(r'\D'), ''),
    );

    if (isDuplicate) {
      throw Exception('A contact with this email or phone number already exists in your trusted network.');
    }

    // If this is the first contact added, automatically set as primary
    final isFirst = current.isEmpty;
    final contactToSave = contact.copyWith(isPrimary: isFirst || contact.isPrimary);

    final id = await _db.insertTrustedContact(contactToSave);
    if (contactToSave.isPrimary && !isFirst) {
      await _db.setPrimaryContact(id);
    }
  }

  Future<void> editContact(TrustedContact contact) async {
    await _db.updateTrustedContact(contact);
    if (contact.isPrimary && contact.id != null) {
      await _db.setPrimaryContact(contact.id!);
    }
  }

  Future<void> deleteContact(int id) async {
    await _db.deleteTrustedContact(id);
  }

  Future<void> markPrimary(int id) async {
    await _db.setPrimaryContact(id);
  }

  // --- Settings & Consent Management ---
  Box get _settingsBox => Hive.box(_settingsBoxName);

  bool get isFeatureEnabled => _settingsBox.get('is_enabled', defaultValue: false) as bool;

  Future<void> setFeatureEnabled(bool enabled) async {
    await _settingsBox.put('is_enabled', enabled);
  }

  bool get hasPrivacyConsent => _settingsBox.get('privacy_consent', defaultValue: false) as bool;

  Future<void> setPrivacyConsent(bool consent) async {
    await _settingsBox.put('privacy_consent', consent);
    if (consent) {
      await setFeatureEnabled(true);
    }
  }

  bool get isCountdownEnabled => _settingsBox.get('countdown_enabled', defaultValue: true) as bool;

  Future<void> setCountdownEnabled(bool enabled) async {
    await _settingsBox.put('countdown_enabled', enabled);
  }

  int get countdownDurationSeconds => _settingsBox.get('countdown_duration', defaultValue: 10) as int;

  Future<void> setCountdownDurationSeconds(int seconds) async {
    await _settingsBox.put('countdown_duration', seconds);
  }
}
