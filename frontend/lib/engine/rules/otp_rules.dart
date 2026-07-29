import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> otpRules = [
  const ScamRule(
    id: 'OTP_001',
    name: 'OTP Request',
    description: 'Detects requests for One-Time Passwords',
    keywords: [
      'otp',
      'one time password',
      'verification code',
      'share code',
      'login code',
      'ઓટીપી'
    ],
    weight: 25,
    category: ScamCategory.otpScam,
    recommendedAction: 'Never share your OTP with anyone.',
  ),
  const ScamRule(
    id: 'OTP_002',
    name: 'OTP Warning Bypass',
    description: 'Detects scammers trying to bypass the "never share" warning',
    keywords: [
      'ignore warning',
      'safe to share',
      'i am from bank',
      'verify account'
    ],
    weight: 30,
    category: ScamCategory.otpScam,
    recommendedAction: 'Bank officials will never ask for your OTP.',
  ),
];
