import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> callRules = [
  const ScamRule(
    id: 'CALL_UNKNOWN_01',
    name: 'Unknown International Target',
    description: 'Detects unexpected foreign calls starting with common scam prefixes (+92, +44, +1)',
    keywords: [],
    weight: 30,
    category: ScamCategory.unknown,
    recommendedAction: 'Be cautious of international numbers you do not recognize.',
  ),
  const ScamRule(
    id: 'CALL_HIDDEN',
    name: 'Hidden Caller ID',
    description: 'Detects explicitly hidden or private numbers',
    keywords: [],
    weight: 40,
    category: ScamCategory.unknown,
    recommendedAction: 'This caller has intentionally hidden their number. Do not share personal information.',
  ),
  const ScamRule(
    id: 'CALL_ROBOCALL_PREFIX',
    name: 'Known Spam Prefix',
    description: 'Detects numbers from recognized spam allocations (e.g. 140x in IN)',
    keywords: [],
    weight: 35,
    category: ScamCategory.unknown,
    recommendedAction: 'This number matches a known telemarketing or spam prefix.',
  ),
];
