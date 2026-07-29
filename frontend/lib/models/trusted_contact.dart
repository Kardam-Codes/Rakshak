enum NotificationMethod {
  email,
  sms,
  push,
  whatsapp
}

extension NotificationMethodExtension on NotificationMethod {
  String get displayName {
    switch (this) {
      case NotificationMethod.email:
        return 'Email';
      case NotificationMethod.sms:
        return 'SMS (Future)';
      case NotificationMethod.push:
        return 'Push (Future)';
      case NotificationMethod.whatsapp:
        return 'WhatsApp (Future)';
    }
  }
}

class TrustedContact {
  final int? id;
  final String name;
  final String phoneNumber;
  final String email;
  final String relationship; // e.g. "Son", "Daughter", "Spouse", "Friend"
  final String? profilePhoto;
  final String language; // "English", "Gujarati"
  final NotificationMethod preferredNotificationMethod;
  final bool isPrimary;
  final bool isEmergency;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrustedContact({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.relationship,
    this.profilePhoto,
    this.language = 'English',
    this.preferredNotificationMethod = NotificationMethod.email,
    this.isPrimary = false,
    this.isEmergency = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TrustedContact copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? relationship,
    String? profilePhoto,
    String? language,
    NotificationMethod? preferredNotificationMethod,
    bool? isPrimary,
    bool? isEmergency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      language: language ?? this.language,
      preferredNotificationMethod: preferredNotificationMethod ?? this.preferredNotificationMethod,
      isPrimary: isPrimary ?? this.isPrimary,
      isEmergency: isEmergency ?? this.isEmergency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
