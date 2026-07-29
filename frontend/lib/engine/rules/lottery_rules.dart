import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> lotteryRules = [
  const ScamRule(
    id: 'LOTTERY_001',
    name: 'Lottery Winner Notification',
    description: 'Detects fake lottery or prize win claims',
    keywords: [
      'congratulations',
      'winner',
      'prize',
      'lucky draw',
      'claim now',
      'free money',
      'jackpot',
      'you have won',
      'lottery won'
    ],
    weight: 45,
    category: ScamCategory.lotteryScam,
    recommendedAction: 'Ignore this message. You cannot win a lottery you did not enter.',
  ),
];
