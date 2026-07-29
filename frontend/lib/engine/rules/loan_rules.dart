import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> loanRules = [
  const ScamRule(
    id: 'LOAN_001',
    name: 'Fake Loan Scam',
    description: 'Detects fake or predatory instant loan offers',
    keywords: [
      'instant loan',
      'no documents',
      'easy loan',
      'approval',
      'disbursement',
      'processing fee',
      'pre-approved loan',
      'zero percent interest'
    ],
    weight: 35,
    category: ScamCategory.fakeLoan,
    recommendedAction: 'Verify the lender via RBI authorized lists before applying.',
  ),
];
