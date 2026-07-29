import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> generalRules = [
  const ScamRule(
    id: 'GEN_001',
    name: 'Urgent Action Indicator',
    description: 'Detects artificial sense of urgency',
    keywords: ['urgent', 'immediately', 'act now', 'expires in', 'last chance'],
    weight: 20,
    category: ScamCategory.unknown,
    recommendedAction: 'Scammers create panic. Take your time to verify.',
  ),
  const ScamRule(
    id: 'GEN_002',
    name: 'Suspicious Link/App',
    description: 'Detects requests to click links or install apps',
    keywords: ['click link', 'download apk', 'install app', 'tap here', 'visit url', 'login link'],
    weight: 30,
    category: ScamCategory.unknown,
    recommendedAction: 'Do not click unknown links or install apps from untrusted sources.',
  ),
  const ScamRule(
    id: 'GEN_003',
    name: 'Call to Action',
    description: 'Detects suspicious directives',
    keywords: ['call now', 'contact immediately', 'reach out', 'reply directly'],
    weight: 15,
    category: ScamCategory.unknown,
    recommendedAction: 'Verify contact details on official bank websites before calling.',
  ),
];
