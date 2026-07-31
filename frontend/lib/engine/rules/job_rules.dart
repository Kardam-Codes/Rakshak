import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> jobRules = [
  const ScamRule(
    id: 'JOB_001',
    name: 'Part-Time Job Offer',
    description: 'Detects unsolicited part-time job or task-based offers',
    keywords: ['part-time', 'part time', 'data entry', 'work from home', 'pasand karvama aavya che', 'paise kamaye', 'job mate'],
    weight: 40,
    category: ScamCategory.jobScam,
    recommendedAction: 'Legitimate companies do not recruit randomly via SMS/WhatsApp. Ignore this.',
  ),
  const ScamRule(
    id: 'JOB_002',
    name: 'Refundable Deposit Demand',
    description: 'Detects scams asking for an initial deposit to release funds or give a job',
    keywords: ['refundable deposit', 'deposit mokalo', 'shru karva mate', 'task complete', 'deposit fee'],
    weight: 50,
    category: ScamCategory.collectRequest,
    recommendedAction: 'Never pay money to get a job. This is a classic task-scam.',
  ),
];
