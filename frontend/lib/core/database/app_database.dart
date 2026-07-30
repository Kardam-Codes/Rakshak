import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/notification_entity.dart';
import '../../models/call_entity.dart';
import '../../models/upi_transaction_entity.dart';
import '../../models/scan_entity.dart';
import '../../models/trusted_contact.dart';
import '../../models/family_alert_history.dart';
import '../../models/explanation_entity.dart';
import '../../engine/models/risk_level.dart';
import '../../engine/models/scam_category.dart';
import '../../engine/models/transaction_type.dart';


class NotificationEntityAdapter extends TypeAdapter<NotificationEntity> {
  @override
  final int typeId = 0;

  @override
  NotificationEntity read(BinaryReader reader) {
    final fields = reader.readMap();
    return NotificationEntity(
      id: fields['id'],
      appName: fields['appName'] ?? '',
      packageName: fields['packageName'] ?? '',
      title: fields['title'] ?? '',
      body: fields['body'] ?? '',
      timestamp: fields['timestamp'] ?? DateTime.now(),
      isRead: fields['isRead'] ?? false,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == fields['riskLevel'], 
        orElse: () => RiskLevel.safe
      ),
      category: ScamCategory.values.firstWhere(
        (e) => e.name == fields['category'], 
        orElse: () => ScamCategory.unknown
      ),
      matchedRules: (fields['matchedRules'] as List?)?.cast<String>() ?? [],
      reason: fields['reason'] ?? '',
      aiSimpleExplanation: fields['aiSimpleExplanation'],
      aiReason: fields['aiReason'],
      aiRecommendedAction: fields['aiRecommendedAction'],
      notificationHash: fields['notificationHash'],
    );
  }

  @override
  void write(BinaryWriter writer, NotificationEntity obj) {
    writer.writeMap({
      'id': obj.id,
      'appName': obj.appName,
      'packageName': obj.packageName,
      'title': obj.title,
      'body': obj.body,
      'timestamp': obj.timestamp,
      'isRead': obj.isRead,
      'riskLevel': obj.riskLevel.name,
      'category': obj.category.name,
      'matchedRules': obj.matchedRules,
      'reason': obj.reason,
      'aiSimpleExplanation': obj.aiSimpleExplanation,
      'aiReason': obj.aiReason,
      'aiRecommendedAction': obj.aiRecommendedAction,
      'notificationHash': obj.notificationHash,
    });
  }
}

class CallEntityAdapter extends TypeAdapter<CallEntity> {
  @override
  final int typeId = 1;

  @override
  CallEntity read(BinaryReader reader) {
    final fields = reader.readMap();
    return CallEntity(
      id: fields['id'],
      phoneNumber: fields['phoneNumber'] ?? '',
      contactName: fields['contactName'],
      callType: fields['callType'] ?? 'missed',
      timestamp: fields['timestamp'] ?? DateTime.now(),
      durationSeconds: fields['durationSeconds'] ?? 0,
      isKnownContact: fields['isKnownContact'] ?? false,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == fields['riskLevel'], 
        orElse: () => RiskLevel.safe
      ),
      category: ScamCategory.values.firstWhere(
        (e) => e.name == fields['category'], 
        orElse: () => ScamCategory.unknown
      ),
      matchedRules: (fields['matchedRules'] as List?)?.cast<String>() ?? [],
      offlineReason: fields['offlineReason'] ?? '',
      aiExplanation: fields['aiExplanation'],
      aiRecommendedAction: fields['aiRecommendedAction'],
    );
  }

  @override
  void write(BinaryWriter writer, CallEntity obj) {
    writer.writeMap({
      'id': obj.id,
      'phoneNumber': obj.phoneNumber,
      'contactName': obj.contactName,
      'callType': obj.callType,
      'timestamp': obj.timestamp,
      'durationSeconds': obj.durationSeconds,
      'isKnownContact': obj.isKnownContact,
      'riskLevel': obj.riskLevel.name,
      'category': obj.category.name,
      'matchedRules': obj.matchedRules,
      'offlineReason': obj.offlineReason,
      'aiExplanation': obj.aiExplanation,
      'aiRecommendedAction': obj.aiRecommendedAction,
    });
  }
}

class UPITransactionEntityAdapter extends TypeAdapter<UPITransactionEntity> {
  @override
  final int typeId = 2;

  @override
  UPITransactionEntity read(BinaryReader reader) {
    final fields = reader.readMap();
    return UPITransactionEntity(
      id: fields['id'],
      appName: fields['appName'] ?? '',
      packageName: fields['packageName'] ?? '',
      merchantName: fields['merchantName'] ?? '',
      upiId: fields['upiId'] ?? '',
      transactionType: TransactionType.values.firstWhere(
        (e) => e.name == fields['transactionType'],
        orElse: () => TransactionType.unknown
      ),
      amount: fields['amount'] ?? 0.0,
      currency: fields['currency'] ?? 'INR',
      timestamp: fields['timestamp'] ?? DateTime.now(),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == fields['riskLevel'], 
        orElse: () => RiskLevel.safe
      ),
      category: ScamCategory.values.firstWhere(
        (e) => e.name == fields['category'], 
        orElse: () => ScamCategory.unknown
      ),
      matchedRules: (fields['matchedRules'] as List?)?.cast<String>() ?? [],
      confidence: fields['confidence'] ?? 0.0,
      offlineReason: fields['offlineReason'] ?? '',
      aiExplanation: fields['aiExplanation'],
      recommendedAction: fields['recommendedAction'],
      status: fields['status'] ?? 'pending',
    );
  }

  @override
  void write(BinaryWriter writer, UPITransactionEntity obj) {
    writer.writeMap({
      'id': obj.id,
      'appName': obj.appName,
      'packageName': obj.packageName,
      'merchantName': obj.merchantName,
      'upiId': obj.upiId,
      'transactionType': obj.transactionType.name,
      'amount': obj.amount,
      'currency': obj.currency,
      'timestamp': obj.timestamp,
      'riskLevel': obj.riskLevel.name,
      'category': obj.category.name,
      'matchedRules': obj.matchedRules,
      'confidence': obj.confidence,
      'offlineReason': obj.offlineReason,
      'aiExplanation': obj.aiExplanation,
      'recommendedAction': obj.recommendedAction,
      'status': obj.status,
    });
  }
}

class ScanResultEntityAdapter extends TypeAdapter<ScanResultEntity> {
  @override
  final int typeId = 3;

  @override
  ScanResultEntity read(BinaryReader reader) {
    final fields = reader.readMap();
    return ScanResultEntity(
      id: fields['id'],
      content: fields['content'] ?? '',
      scanType: ScanType.values.firstWhere(
        (e) => e.name == fields['scanType'],
        orElse: () => ScanType.url,
      ),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == fields['riskLevel'],
        orElse: () => RiskLevel.safe,
      ),
      confidence: (fields['confidence'] as num?)?.toDouble() ?? 1.0,
      category: ScamCategory.values.firstWhere(
        (e) => e.name == fields['category'],
        orElse: () => ScamCategory.unknown,
      ),
      matchedRules: (fields['matchedRules'] as List?)?.cast<String>() ?? [],
      offlineReason: fields['offlineReason'] ?? '',
      recommendedAction: fields['recommendedAction'] ?? '',
      aiSimpleExplanation: fields['aiSimpleExplanation'],
      aiReason: fields['aiReason'],
      aiRecommendedAction: fields['aiRecommendedAction'],
      aiShortSummary: fields['aiShortSummary'],
      timestamp: fields['timestamp'] ?? DateTime.now(),
      processingTimeMs: fields['processingTimeMs'] ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, ScanResultEntity obj) {
    writer.writeMap({
      'id': obj.id,
      'content': obj.content,
      'scanType': obj.scanType.name,
      'riskLevel': obj.riskLevel.name,
      'confidence': obj.confidence,
      'category': obj.category.name,
      'matchedRules': obj.matchedRules,
      'offlineReason': obj.offlineReason,
      'recommendedAction': obj.recommendedAction,
      'aiSimpleExplanation': obj.aiSimpleExplanation,
      'aiReason': obj.aiReason,
      'aiRecommendedAction': obj.aiRecommendedAction,
      'aiShortSummary': obj.aiShortSummary,
      'timestamp': obj.timestamp,
      'processingTimeMs': obj.processingTimeMs,
    });
  }
}

class ExplanationEntityAdapter extends TypeAdapter<ExplanationEntity> {
  @override
  final int typeId = 6;

  @override
  ExplanationEntity read(BinaryReader reader) {
    final fields = reader.readMap();
    return ExplanationEntity(
      id: fields['id'],
      sourceFeature: fields['sourceFeature'] ?? '',
      category: fields['category'] ?? ScamCategory.unknown.name,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == fields['riskLevel'],
        orElse: () => RiskLevel.safe,
      ),
      confidence: (fields['confidence'] as num?)?.toDouble() ?? 0,
      offlineExplanation: fields['offlineExplanation'] ?? '',
      aiExplanation: fields['aiExplanation'],
      recommendedAction: fields['recommendedAction'] ?? '',
      preventionTips: (fields['preventionTips'] as List?)?.cast<String>() ?? [],
      summary: fields['summary'] ?? '',
      createdAt: fields['createdAt'] ?? DateTime.now(),
      contentHash: fields['contentHash'] ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, ExplanationEntity obj) {
    writer.writeMap({
      'id': obj.id,
      'sourceFeature': obj.sourceFeature,
      'category': obj.category,
      'riskLevel': obj.riskLevel.name,
      'confidence': obj.confidence,
      'offlineExplanation': obj.offlineExplanation,
      'aiExplanation': obj.aiExplanation,
      'recommendedAction': obj.recommendedAction,
      'preventionTips': obj.preventionTips,
      'summary': obj.summary,
      'createdAt': obj.createdAt,
      'contentHash': obj.contentHash,
    });
  }
}

class AppDatabase {
  static const String _boxName = 'notifications_box';
  static const String _explanationsBoxName = 'explanations_box';
  static const String _callsBoxName = 'calls_box';
  static const String _upiBoxName = 'upi_transactions_box';
  static const String _scansBoxName = 'scans_box';
  static const String _trustedContactsBoxName = 'trusted_contacts_box';
  static const String _familyHistoryBoxName = 'family_alert_history_box';
  static const String _settingsBoxName = 'trusted_family_settings_box';
  static const String _analyticsBoxName = 'trusted_family_analytics_box';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NotificationEntityAdapter());
    Hive.registerAdapter(CallEntityAdapter());
    Hive.registerAdapter(UPITransactionEntityAdapter());
    Hive.registerAdapter(ScanResultEntityAdapter());
    Hive.registerAdapter(TrustedContactAdapter());
    Hive.registerAdapter(FamilyAlertHistoryAdapter());
    Hive.registerAdapter(ExplanationEntityAdapter());
    await Hive.openBox<NotificationEntity>(_boxName);
    await Hive.openBox<ExplanationEntity>(_explanationsBoxName);
    await Hive.openBox<CallEntity>(_callsBoxName);
    await Hive.openBox<UPITransactionEntity>(_upiBoxName);
    await Hive.openBox<ScanResultEntity>(_scansBoxName);
    await Hive.openBox<TrustedContact>(_trustedContactsBoxName);
    await Hive.openBox<FamilyAlertHistoryEntity>(_familyHistoryBoxName);
    await Hive.openBox<ExplanationEntity>('explanations');
    await Hive.openBox(_settingsBoxName);
    await Hive.openBox(_analyticsBoxName);
  }

  Box<NotificationEntity> get _box => Hive.box<NotificationEntity>(_boxName);

  Stream<List<NotificationEntity>> watchNotifications() {
    return _box.watch().map((_) => _getAllSorted()).asBroadcastStream()
      ..listen((_) {}) // force active
      ;
  }

  Stream<List<NotificationEntity>> get notificationsStream async* {
    yield _getAllSorted();
    yield* watchNotifications();
  }

  List<NotificationEntity> _getAllSorted() {
    final list = _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<int> insertNotification(NotificationEntity entity) async {
    if (entity.notificationHash != null) {
      final existing = findNotificationByHash(entity.notificationHash!);
      if (existing?.id != null) {
        final updated = entity.copyWith(
          id: existing!.id,
          isRead: existing.isRead,
          aiSimpleExplanation: entity.aiSimpleExplanation ?? existing.aiSimpleExplanation,
          aiReason: entity.aiReason ?? existing.aiReason,
          aiRecommendedAction: entity.aiRecommendedAction ?? existing.aiRecommendedAction,
        );
        await _box.put(existing.id!, updated);
        return existing.id!;
      }
    }

    final id = await _box.add(entity);
    final updated = entity.copyWith(id: id);
    await _box.put(id, updated);
    return id;
  }

  Future<void> deleteNotification(int id) async {
    await _box.delete(id);
  }

  Future<void> clearNotifications() async {
    await _box.clear();
  }

  Future<void> markAsRead(int id) async {
    final entity = _box.get(id);
    if (entity != null) {
      await _box.put(id, entity.copyWith(isRead: true));
    }
  }

  Future<NotificationEntity?> findNotificationByHashWithAi(String hash) async {
    try {
      return _box.values.firstWhere((e) => e.notificationHash == hash && e.aiSimpleExplanation != null);
    } catch (_) {
      return null;
    }
  }

  NotificationEntity? findNotificationByHash(String hash) {
    try {
      return _box.values.firstWhere((e) => e.notificationHash == hash);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateNotification(NotificationEntity entity) async {
    if (entity.id != null && _box.containsKey(entity.id)) {
      await _box.put(entity.id!, entity);
    }
  }

  Box<ExplanationEntity> get _explanationsBox => Hive.box<ExplanationEntity>(_explanationsBoxName);

  Future<int> insertExplanation(ExplanationEntity entity) async {
    final id = await _explanationsBox.add(entity);
    await _explanationsBox.put(id, entity.copyWith(id: id));
    return id;
  }

  Future<void> updateExplanation(ExplanationEntity entity) async {
    if (entity.id != null && _explanationsBox.containsKey(entity.id)) {
      await _explanationsBox.put(entity.id!, entity);
    }
  }

  ExplanationEntity? getExplanationByHash(String hash) {
    try {
      return _explanationsBox.values.firstWhere((e) => e.contentHash == hash);
    } catch (_) {
      return null;
    }
  }

  // --- Call Entity Methods ---
  Box<CallEntity> get _callsBox => Hive.box<CallEntity>(_callsBoxName);

  Stream<List<CallEntity>> get callsStream async* {
    yield _getAllCallsSorted();
    yield* _callsBox.watch().map((_) => _getAllCallsSorted()).asBroadcastStream();
  }

  List<CallEntity> _getAllCallsSorted() {
    final list = _callsBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<int> insertCall(CallEntity entity) async {
    final id = await _callsBox.add(entity);
    await _callsBox.put(id, entity.copyWith(id: id));
    return id;
  }

  Future<void> updateCall(CallEntity entity) async {
    if (entity.id != null && _callsBox.containsKey(entity.id)) {
      await _callsBox.put(entity.id!, entity);
    }
  }

  Future<void> deleteCall(int id) async {
    await _callsBox.delete(id);
  }

  Future<void> clearCalls() async {
    await _callsBox.clear();
  }

  // --- UPI Transaction Entity Methods ---
  Box<UPITransactionEntity> get _upiBox => Hive.box<UPITransactionEntity>(_upiBoxName);

  Stream<List<UPITransactionEntity>> get upiTransactionsStream async* {
    yield _getAllUpiTransactionsSorted();
    yield* _upiBox.watch().map((_) => _getAllUpiTransactionsSorted()).asBroadcastStream();
  }

  List<UPITransactionEntity> _getAllUpiTransactionsSorted() {
    final list = _upiBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  // --- Scan Result Methods ---
  Box<ScanResultEntity> get _scansBox => Hive.box<ScanResultEntity>(_scansBoxName);

  Stream<List<ScanResultEntity>> get scansStream async* {
    yield _getAllScansSorted();
    yield* _scansBox.watch().map((_) => _getAllScansSorted()).asBroadcastStream();
  }

  List<ScanResultEntity> _getAllScansSorted() {
    final list = _scansBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<int> insertUpiTransaction(UPITransactionEntity entity) async {
    final id = await _upiBox.add(entity);
    await _upiBox.put(id, entity.copyWith(id: id));
    return id;
  }

  Future<void> updateUpiTransaction(UPITransactionEntity entity) async {
    if (entity.id != null && _upiBox.containsKey(entity.id)) {
      await _upiBox.put(entity.id!, entity);
    }
  }

  Future<void> deleteUpiTransaction(int id) async {
    await _upiBox.delete(id);
  }

  Future<void> clearUpiTransactions() async {
    await _upiBox.clear();
  }
  Future<int> insertScan(ScanResultEntity entity) async {
    final id = await _scansBox.add(entity);
    final updated = entity.copyWith(id: id);
    await _scansBox.put(id, updated);
    return id;
  }

  Future<ScanResultEntity?> findCachedScan(String content) async {
    try {
      final clean = content.trim().toLowerCase();
      final matches = _scansBox.values.where((e) => e.content.trim().toLowerCase() == clean).toList();
      if (matches.isNotEmpty) {
        matches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return matches.first;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteScan(int id) async {
    await _scansBox.delete(id);
  }

  Future<void> clearScans() async {
    await _scansBox.clear();
  }

  // --- Trusted Contact Methods ---
  Box<TrustedContact> get _trustedContactsBox => Hive.box<TrustedContact>(_trustedContactsBoxName);

  Stream<List<TrustedContact>> get trustedContactsStream async* {
    yield _getAllTrustedContacts();
    yield* _trustedContactsBox.watch().map((_) => _getAllTrustedContacts()).asBroadcastStream();
  }

  List<TrustedContact> _getAllTrustedContacts() {
    final list = _trustedContactsBox.values.toList()
      ..sort((a, b) {
        if (a.isPrimary) return -1;
        if (b.isPrimary) return 1;
        return a.name.compareTo(b.name);
      });
    return list;
  }

  Future<int> insertTrustedContact(TrustedContact contact) async {
    final id = await _trustedContactsBox.add(contact);
    final updated = contact.copyWith(id: id);
    await _trustedContactsBox.put(id, updated);
    return id;
  }



  Future<void> updateTrustedContact(TrustedContact contact) async {
    if (contact.id != null && _trustedContactsBox.containsKey(contact.id)) {
      await _trustedContactsBox.put(contact.id!, contact);
    }
  }

  Future<void> deleteTrustedContact(int id) async {
    await _trustedContactsBox.delete(id);
  }

  Future<void> setPrimaryContact(int id) async {
    for (var contact in _trustedContactsBox.values) {
      if (contact.id == id) {
        await _trustedContactsBox.put(contact.id!, contact.copyWith(isPrimary: true));
      } else if (contact.isPrimary) {
        await _trustedContactsBox.put(contact.id!, contact.copyWith(isPrimary: false));
      }
    }
  }

  // --- Family Alert History Methods ---
  Box<FamilyAlertHistoryEntity> get _familyHistoryBox => Hive.box<FamilyAlertHistoryEntity>(_familyHistoryBoxName);

  Stream<List<FamilyAlertHistoryEntity>> get familyHistoryStream async* {
    yield _getAllFamilyHistorySorted();
    yield* _familyHistoryBox.watch().map((_) => _getAllFamilyHistorySorted()).asBroadcastStream();
  }

  List<FamilyAlertHistoryEntity> _getAllFamilyHistorySorted() {
    final list = _familyHistoryBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<int> insertFamilyAlertHistory(FamilyAlertHistoryEntity entity) async {
    final id = await _familyHistoryBox.add(entity);
    final updated = entity.copyWith(id: id);
    await _familyHistoryBox.put(id, updated);
    return id;
  }

  Future<void> deleteFamilyAlertHistory(int id) async {
    await _familyHistoryBox.delete(id);
  }

  Future<void> clearFamilyAlertHistory() async {
    await _familyHistoryBox.clear();
  }
}

class TrustedContactAdapter extends TypeAdapter<TrustedContact> {
  @override
  final int typeId = 5;

  @override
  TrustedContact read(BinaryReader reader) {
    final fields = reader.readMap();
    return TrustedContact(
      id: fields['id'],
      name: fields['name'] ?? '',
      phoneNumber: fields['phoneNumber'] ?? '',
      email: fields['email'] ?? '',
      relationship: fields['relationship'] ?? 'Family',
      profilePhoto: fields['profilePhoto'],
      language: fields['language'] ?? 'English',
      preferredNotificationMethod: NotificationMethod.values.firstWhere(
        (e) => e.name == fields['preferredNotificationMethod'],
        orElse: () => NotificationMethod.email,
      ),
      isPrimary: fields['isPrimary'] ?? false,
      isEmergency: fields['isEmergency'] ?? true,
      createdAt: fields['createdAt'] ?? DateTime.now(),
      updatedAt: fields['updatedAt'] ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, TrustedContact obj) {
    writer.writeMap({
      'id': obj.id,
      'name': obj.name,
      'phoneNumber': obj.phoneNumber,
      'email': obj.email,
      'relationship': obj.relationship,
      'profilePhoto': obj.profilePhoto,
      'language': obj.language,
      'preferredNotificationMethod': obj.preferredNotificationMethod.name,
      'isPrimary': obj.isPrimary,
      'isEmergency': obj.isEmergency,
      'createdAt': obj.createdAt,
      'updatedAt': obj.updatedAt,
    });
  }
}

class FamilyAlertHistoryAdapter extends TypeAdapter<FamilyAlertHistoryEntity> {
  @override
  final int typeId = 4;

  @override
  FamilyAlertHistoryEntity read(BinaryReader reader) {
    final fields = reader.readMap();
    return FamilyAlertHistoryEntity(
      id: fields['id'],
      recipientEmail: fields['recipientEmail'] ?? '',
      recipientName: fields['recipientName'] ?? '',
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == fields['riskLevel'],
        orElse: () => RiskLevel.safe,
      ),
      category: fields['category'] ?? '',
      messageSummary: fields['messageSummary'] ?? '',
      timestamp: fields['timestamp'] ?? DateTime.now(),
      deliveryStatus: fields['deliveryStatus'] ?? 'sent',
      viewed: fields['viewed'] ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, FamilyAlertHistoryEntity obj) {
    writer.writeMap({
      'id': obj.id,
      'recipientEmail': obj.recipientEmail,
      'recipientName': obj.recipientName,
      'riskLevel': obj.riskLevel.name,
      'category': obj.category,
      'messageSummary': obj.messageSummary,
      'timestamp': obj.timestamp,
      'deliveryStatus': obj.deliveryStatus,
      'viewed': obj.viewed,
    });
  }
}



