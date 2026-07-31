import '../models/upi_transaction_entity.dart';
import '../repositories/upi_repository.dart';
import '../engine/rule_engine.dart';
import '../engine/alert_engine.dart';
import '../engine/models/transaction_type.dart';
import '../models/notification_entity.dart';
import '../services/onnx_service.dart';

class UPIProtectionService {
  final UPIRepository _upiRepository;
  final AlertEngine _alertEngine;

  UPIProtectionService(this._upiRepository, this._alertEngine);

  /// Processes text from a notification to extract UPI parameters
  Future<void> processUPINotification(NotificationEntity notification) async {
    final title = notification.title.toLowerCase();
    final body = notification.body.toLowerCase();
    final combined = '$title $body';

    // 1. Transaction Type Detection
    TransactionType type = TransactionType.unknown;
    if (combined.contains('requested money') || combined.contains('collect request') || combined.contains('approve payment')) {
      type = TransactionType.collectRequest;
    } else if (combined.contains('sent') || combined.contains('paid') || combined.contains('debited')) {
      type = TransactionType.payment;
    } else if (combined.contains('refund') || combined.contains('reversed')) {
      type = TransactionType.refund;
    } else if (combined.contains('cashback') || combined.contains('reward')) {
      type = TransactionType.cashback;
    }

    // 2. Amount Extraction
    double amount = _extractAmount(combined);

    // 3. Extract UPI ID & Merchant
    final upiId = _extractUpiId(combined);
    final merchantName = _extractMerchant(title, body) ?? 'Unknown Sender';

    // Ensure it's somewhat valid before generating an entity
    if (amount == 0 && upiId.isEmpty && type == TransactionType.unknown) {
      return; 
    }

    // 4. ML model analysis, with local rule fallback if backend/model is unavailable.
    final modelText = [
      notification.title,
      notification.body,
      'Transaction type: ${type.name}',
      if (amount > 0) 'Amount: $amount',
      if (upiId.isNotEmpty) 'UPI ID: $upiId',
      'Merchant: $merchantName',
    ].join('\n');
    final detection = await OnnxService.instance.predict(modelText) ?? RuleEngine.analyzeUPI(
      merchantName: merchantName,
      upiId: upiId,
      type: type,
      amount: amount,
      title: notification.title,
      body: notification.body,
      isKnownContact: false, // In prod, check Contacts permission for UPI ID phone prefixes
    );

    // 5. Create Entity
    final transaction = UPITransactionEntity(
      appName: notification.appName,
      packageName: notification.packageName,
      merchantName: merchantName,
      upiId: upiId,
      transactionType: type,
      amount: amount,
      timestamp: DateTime.now(),
      riskLevel: detection.riskLevel,
      category: detection.category,
      matchedRules: detection.matchedRules,
      confidence: detection.confidence,
      offlineReason: detection.reason,
      recommendedAction: detection.recommendedAction,
    );

    // 6. Save locally
    final savedId = await _upiRepository.saveTransaction(transaction);
    final savedTransaction = transaction.copyWith(id: savedId);

    // 7. Route to Alert Engine for AI Explanation and Warnings
    _alertEngine.processUPITransaction(savedTransaction);
  }

  double _extractAmount(String text) {
    // Regex for amounts roughly like Rs. 500, Rs.500, ₹500, INR 500, 500.00
    final regex = RegExp(r'(?:rs\.?|inr|₹|amount[:\-]?)\s*([\d,]+\.?\d*)', caseSensitive: false);
    final match = regex.firstMatch(text);
    if (match != null && match.group(1) != null) {
      final amtStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amtStr) ?? 0.0;
    }
    return 0.0;
  }

  String _extractUpiId(String text) {
    // Basic regex for standard UPI forms like 9876543210@ybl, name.surname@okhdfcbank
    final regex = RegExp(r'([\w.-]+@[\w.-]+)');
    final match = regex.firstMatch(text);
    return match?.group(1) ?? '';
  }

  String? _extractMerchant(String title, String body) {
    // Usually names appear before VPA or keywords in standard payloads.
    // Simplifying for mock context:
    if (body.contains('requested by')) {
       final split = body.split('requested by');
       if (split.length > 1) {
          return split[1].split('for').first.trim();
       }
    }
    return title.isNotEmpty ? title : 'Unknown Sender';
  }
}
