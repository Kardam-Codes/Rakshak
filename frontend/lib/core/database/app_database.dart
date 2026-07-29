import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/notification_entity.dart';
import '../../models/call_entity.dart';
import '../../models/upi_transaction_entity.dart';
import '../../engine/models/risk_level.dart';
import '../../engine/models/scam_category.dart';
import '../../engine/models/transaction_type.dart';
import '../../models/explanation_entity.dart';

class ExplanationEntityAdapter extends TypeAdapter<ExplanationEntity> {
  @override
  final int typeId = 3;

  @override
  ExplanationEntity read(BinaryReader reader) {
    final fields = reader.readMap();
    return ExplanationEntity(
      id: fields['id'],
      sourceFeature: fields['sourceFeature'] ?? '',
      category: fields['category'] ?? '',
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == fields['riskLevel'],
        orElse: () => RiskLevel.safe,
      ),
      confidence: fields['confidence'] ?? 0.0,
      offlineExplanation: fields['offlineExplanation'] ?? '',
      aiExplanation: fields['aiExplanation'],
      recommendedAction: fields['recommendedAction'],
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

class AppDatabase {
  static const String _boxName = 'notifications_box';
  static const String _callsBoxName = 'calls_box';
  static const String _upiBoxName = 'upi_transactions_box';
  static const String _explanationsBoxName = 'explanations_box';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NotificationEntityAdapter());
    Hive.registerAdapter(CallEntityAdapter());
    Hive.registerAdapter(UPITransactionEntityAdapter());
    Hive.registerAdapter(ExplanationEntityAdapter());
    await Hive.openBox<NotificationEntity>(_boxName);
    await Hive.openBox<CallEntity>(_callsBoxName);
    await Hive.openBox<UPITransactionEntity>(_upiBoxName);
    await Hive.openBox<ExplanationEntity>(_explanationsBoxName);
  }

  Box<NotificationEntity> get _box => Hive.box<NotificationEntity>(_boxName);

  Stream<List<NotificationEntity>> watchNotifications() {
    return _box.watch().map((_) => _getAllSorted()).asBroadcastStream()
      ..listen((_) {}) // force active
      // Yield the initial value immediately
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
    final id = await _box.add(entity);
    // update with ID
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

  Future<void> updateNotification(NotificationEntity entity) async {
    if (entity.id != null && _box.containsKey(entity.id)) {
      await _box.put(entity.id!, entity);
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

  // --- Explanation Entity Methods ---
  Box<ExplanationEntity> get _expBox => Hive.box<ExplanationEntity>(_explanationsBoxName);

  Future<int> insertExplanation(ExplanationEntity entity) async {
    final id = await _expBox.add(entity);
    await _expBox.put(id, entity.copyWith(id: id));
    return id;
  }

  Future<void> updateExplanation(ExplanationEntity entity) async {
    if (entity.id != null && _expBox.containsKey(entity.id)) {
      await _expBox.put(entity.id!, entity);
    }
  }

  ExplanationEntity? getExplanationByHash(String hash) {
    try {
      return _expBox.values.firstWhere((e) => e.contentHash == hash);
    } catch (_) {
      return null;
    }
  }
}

