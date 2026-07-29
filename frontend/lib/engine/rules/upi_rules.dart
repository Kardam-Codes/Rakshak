import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> upiRules = [
  const ScamRule(
    id: 'UPI_COLLECT_REQUEST',
    name: 'Suspicious Collect Request',
    description: 'Detects unexpected collect requests where the user is asked to pay instead of receive money.',
    keywords: ['requested', 'requesting', 'pay', 'send money', 'collect', 'approve', 'enter pin to receive'],
    weight: 35,
    category: ScamCategory.collectRequest,
    recommendedAction: 'Do NOT enter your PIN. You never need a PIN to receive money. Decline the request if unknown.',
  ),
  const ScamRule(
    id: 'UPI_REFUND_TRICK',
    name: 'Refund Scam',
    description: 'Scammers claim to send a refund but actually initiate a collect request.',
    keywords: ['refund', 'return', 'failed transaction', 'claim money', 'reverse'],
    weight: 35,
    category: ScamCategory.refundScam,
    recommendedAction: 'Verify refunds directly in your bank statement. Do not approve payment requests for refunds.',
  ),
  const ScamRule(
    id: 'UPI_REWARD_SCAM',
    name: 'Fake Reward/Cashback',
    description: 'Promises cashback or lottery money but asks for a payment to claim.',
    keywords: ['cashback', 'reward', 'lottery', 'winner', 'claim prize', 'scratch card', 'won', 'bonus'],
    weight: 40,
    category: ScamCategory.lotteryScam,
    recommendedAction: 'This is a common scam. Legitimate organizations do not ask for money to release a prize.',
  ),
  const ScamRule(
    id: 'UPI_URGENCY',
    name: 'Artificial Urgency',
    description: 'Creates pressure to pay immediately to avoid consequences.',
    keywords: ['urgent', 'immediately', 'block', 'suspend', 'expire', 'last warning', 'action required'],
    weight: 30,
    category: ScamCategory.unknown,
    recommendedAction: 'Take your time. Scammers use urgency to force mistakes.',
  ),
  const ScamRule(
    id: 'UPI_KYC_FEE',
    name: 'KYC or Processing Fee',
    description: 'Asks for a small fee for KYC, account unblocking, or loan processing.',
    keywords: ['kyc', 'processing fee', 'activation fee', 'unblock', 'verification fee', 'document charge'],
    weight: 45,
    category: ScamCategory.kycScam,
    recommendedAction: 'Banks and legit lenders do not ask for advance UPI fees for processing or KYC.',
  ),
  const ScamRule(
    id: 'UPI_FAKE_CUSTOMER_SUPPORT',
    name: 'Fake Customer Support',
    description: 'Pretends to be bank or app support resolving an issue.',
    keywords: ['support', 'helpline', 'customer care', 'representative', 'executive', 'team', 'service desk'],
    weight: 25,
    category: ScamCategory.unknown,
    recommendedAction: 'Ensure this is official customer support. Do not install any remote desktop apps if asked.',
  ),
  const ScamRule(
    id: 'UPI_UNKNOWN_ID',
    name: 'Unknown UPI ID',
    description: 'Flags UPI IDs that do not belong to trusted personal contacts or verified merchants.',
    keywords: [],
    weight: 15,
    category: ScamCategory.unknown,
    recommendedAction: 'You are paying someone not in your contacts. Double-check the Merchant name and UPI ID.',
  )
];
