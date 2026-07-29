import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> kycRules = [
  const ScamRule(
    id: 'KYC_001',
    name: 'KYC Expiry/Suspension',
    description: 'Detects claims about account suspension due to KYC',
    keywords: [
      'update kyc',
      'verify pan',
      'account suspended',
      'kyc expired',
      'verify immediately',
      'aadhar link',
      'pan link',
      'block your account',
      'account strictly blocked'
    ],
    weight: 40,
    category: ScamCategory.kycScam,
    recommendedAction: 'Do not click the link. Banks do not suspend accounts via SMS links.',
  ),
];
