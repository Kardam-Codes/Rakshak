import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> investmentRules = [
  const ScamRule(
    id: 'INV_001',
    name: 'Investment Scam',
    description: 'Detects "get rich quick" and crypto investment scams',
    keywords: [
      'double your money',
      'crypto',
      'bitcoin',
      'guaranteed returns',
      'trading tips',
      'forex training',
      'investment plan',
      'daily profit'
    ],
    weight: 40,
    category: ScamCategory.investmentScam,
    recommendedAction: 'Beware of unregistered investment schemes guaranteeing high returns.',
  ),
];
