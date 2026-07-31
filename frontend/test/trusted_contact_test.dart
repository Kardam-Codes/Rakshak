import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/models/trusted_contact.dart';

void main() {
  group('TrustedContact Model Tests', () {
    test('Creates contact with valid default values', () {
      final contact = TrustedContact(
        name: 'Son',
        phoneNumber: '+919876543210',
        relationship: 'Son',
      );

      expect(contact.name, 'Son');
      expect(contact.phoneNumber, '+919876543210');
      expect(contact.relationship, 'Son');
      expect(contact.isPrimary, isFalse);
      expect(contact.isEmergency, isTrue);
      expect(contact.preferredNotificationMethod, NotificationMethod.whatsapp);
    });

    test('copyWith updates properties correctly', () {
      final contact = TrustedContact(
        id: 1,
        name: 'Daughter',
        phoneNumber: '+919876543211',
        relationship: 'Daughter',
      );

      final updated = contact.copyWith(isPrimary: true, name: 'Daughter (Primary)');
      expect(updated.id, 1);
      expect(updated.name, 'Daughter (Primary)');
      expect(updated.isPrimary, isTrue);
    });
  });
}
