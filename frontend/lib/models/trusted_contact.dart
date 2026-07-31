enum NotificationMethod {
  sms,
  push,
  whatsapp
}

extension NotificationMethodExtension on NotificationMethod {
  String get displayName {
    switch (this) {
      case NotificationMethod.sms:
        return 'SMS';
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
  final String relationship; // e.g. "Son", "Daughter", "Spouse", "Friend"
  final String? profilePhoto;
  final String language; // "English", "Gujarati"
  final bool isPrimary;
  final bool isEmergency;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrustedContact({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.profilePhoto,
    this.language = 'English',
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
    String? relationship,
    String? profilePhoto,
    String? language,
    bool? isPrimary,
    bool? isEmergency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      language: language ?? this.language,
      isPrimary: isPrimary ?? this.isPrimary,
      isEmergency: isEmergency ?? this.isEmergency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
