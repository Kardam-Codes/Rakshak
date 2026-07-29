import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> refundRules = [
  const ScamRule(
    id: 'REFUND_001',
    name: 'Refund Scam',
    description: 'Detects fake refund notifications and customer care scams',
    keywords: [
      'refund',
      'reverse payment',
      'customer care',
      'remote access',
      'dial',
      'anydesk',
      'teamviewer',
      'support team'
    ],
    weight: 35,
    category: ScamCategory.refundScam,
    recommendedAction: 'Do not install any remote access apps if requested by "customer care".',
  ),
];
