import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> upiRules = [
  const ScamRule(
    id: 'UPI_001',
    name: 'Collect Request Scam',
    description: 'Detects malicious UPI collect requests',
    keywords: [
      'collect request',
      'approve',
      'request money',
      'receive money',
      'collect',
      'pending request',
      'accept payment',
      'money requested'
    ],
    weight: 35,
    category: ScamCategory.collectRequest,
    recommendedAction: 'Do not enter your UPI PIN to receive money.',
  ),
];
