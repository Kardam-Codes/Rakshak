enum TransactionType {
  payment,
  collectRequest,
  refund,
  cashback,
  reward,
  bankVerification,
  autoPay,
  subscription,
  mandate,
  unknown
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.collectRequest:
        return 'Collect Request';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.cashback:
        return 'Cashback';
      case TransactionType.reward:
        return 'Reward';
      case TransactionType.bankVerification:
        return 'Bank Verification';
      case TransactionType.autoPay:
        return 'AutoPay';
      case TransactionType.subscription:
        return 'Subscription';
      case TransactionType.mandate:
        return 'Mandate';
      case TransactionType.unknown:
        return 'Unknown';
    }
  }
}
