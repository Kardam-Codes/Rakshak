import '../models/scam_rule.dart';
import '../models/scam_category.dart';

final List<ScamRule> scanRules = [
  // --- URL Rules ---
  const ScamRule(
    id: 'SCAN_IP_URL_01',
    name: 'IP Address Hostname',
    description: 'URL uses a raw IP address instead of a standard domain name',
    keywords: [],
    regex: r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}',
    weight: 45,
    category: ScamCategory.phishingWebsite,
    recommendedAction: 'Do not open this URL. Legitimate services use secure registered domains.',
  ),
  const ScamRule(
    id: 'SCAN_SUSPICIOUS_TLD_02',
    name: 'High Risk Domain Extension',
    description: 'URL uses a TLD frequently associated with phishing and scam campaigns',
    keywords: [],
    regex: r'https?://[a-zA-Z0-9\.\-]+\.(top|xyz|club|info|work|click|site|online|vip|icu|tk|ml|ga|cf|gq)(/|$)',
    weight: 35,
    category: ScamCategory.suspiciousDomain,
    recommendedAction: 'Be extremely cautious. Verify the website owner before entering any information.',
  ),
  const ScamRule(
    id: 'SCAN_SHORTENED_URL_03',
    name: 'Shortened / Masked URL',
    description: 'URL uses a link shortener to obscure the true destination',
    keywords: ['bit.ly', 'tinyurl.com', 'is.gd', 'cutt.ly', 'rb.gy', 't.co', 'shorturl.at', 'ow.ly'],
    weight: 25,
    category: ScamCategory.maliciousUrl,
    recommendedAction: 'Do not click shortened links from untrusted sources.',
  ),
  const ScamRule(
    id: 'SCAN_TYPOSQUATTING_04',
    name: 'Brand Typosquatting / Impersonation',
    description: 'Domain mimics legitimate banking or payment brand names',
    keywords: [
      'paytmm', 'sbii', 'hdfcc', 'icicibank-security', 'gpay-reward',
      'ybl-verify', 'phonepe-help', 'amazon-pay-claim', 'bank-kyc-update'
    ],
    regex: r'(paytm|sbi|hdfc|icici|gpay|phonepe|bhim|kotak|axis)[a-zA-Z0-9\-]*\.(info|xyz|top|site|online|tech|biz)',
    weight: 45,
    category: ScamCategory.phishingWebsite,
    recommendedAction: 'This link impersonates a financial service. Do not enter credentials.',
  ),
  const ScamRule(
    id: 'SCAN_APK_DOWNLOAD_05',
    name: 'Direct APK / Malicious Executable Download',
    description: 'Link attempts to download an Android APK application package file',
    keywords: ['.apk', 'download-app', 'install-apk'],
    regex: r'https?://[^\s]+\.apk(\?.*)?$',
    weight: 50,
    category: ScamCategory.maliciousUrl,
    recommendedAction: 'Never install application packages (APKs) outside the official Google Play Store.',
  ),

  // --- UPI & QR Code Rules ---
  const ScamRule(
    id: 'SCAN_UPI_COLLECT_06',
    name: 'UPI Collect Payment Request',
    description: 'QR code or link initiates a payment collect request instead of receiving money',
    keywords: ['mode=02', 'collect', 'request'],
    regex: r'upi://pay\?[^\s]*(mode=02|collect|request)',
    weight: 45,
    category: ScamCategory.collectRequest,
    recommendedAction: 'Entering your UPI PIN will DEDUCT money from your account. Do not enter PIN to receive funds.',
  ),
  const ScamRule(
    id: 'SCAN_FAKE_UPI_MERCHANT_07',
    name: 'Suspicious / Unverified UPI QR',
    description: 'UPI QR code contains suspicious parameters or mismatched VPA handles',
    keywords: [],
    regex: r'upi://pay\?pa=[a-zA-Z0-9\.\-_]+@(ybl|paytm|okaxis|okicici|oksbi|ibl|postbank)',
    weight: 15,
    category: ScamCategory.qrScam,
    recommendedAction: 'Verify recipient details on screen before confirming any transaction.',
  ),
  const ScamRule(
    id: 'SCAN_NON_HTTPS_08',
    name: 'Insecure Connection (HTTP)',
    description: 'Website uses unencrypted HTTP protocol',
    keywords: [],
    regex: r'^http://[^\s]+',
    weight: 20,
    category: ScamCategory.suspiciousDomain,
    recommendedAction: 'Avoid submitting sensitive banking or personal information on non-HTTPS websites.',
  ),

  // --- Content / OCR / Keyword Rules ---
  const ScamRule(
    id: 'SCAN_URGENCY_LOTTERY_09',
    name: 'Urgent Reward / Lottery Scam Content',
    description: 'Content promises large rewards, prizes, or urgent money transfers',
    keywords: [
      'lottery', 'winner', 'claimed prize', 'cashback reward', 'urgent transfer',
      'lucky draw', 'congratulations you won', 'inr 2500000', 'kbc lottery'
    ],
    weight: 40,
    category: ScamCategory.lotteryScam,
    recommendedAction: 'Legitimate lotteries or banks do not send unexpected financial rewards via links.',
  ),
  const ScamRule(
    id: 'SCAN_KYC_SUSPENSION_10',
    name: 'Bank Account Suspension / KYC Trap',
    description: 'Content threatens immediate account freeze or demands KYC verification',
    keywords: [
      'kyc suspended', 'account blocked', 'pan not updated', 'update pan card',
      'electricity bill pending', 'power cut tonight', 'deactivated within 24 hours'
    ],
    weight: 45,
    category: ScamCategory.kycScam,
    recommendedAction: 'Contact your bank directly via their official customer helpline. Do not click links.',
  ),
  const ScamRule(
    id: 'SCAN_REFUND_LOAN_11',
    name: 'Fake Refund or Instant Loan Offer',
    description: 'Promises instant pre-approved loans or automatic refund processing',
    keywords: [
      'instant loan approval', 'zero percent interest', 'guaranteed refund',
      'click to claim refund', 'tax refund pending'
    ],
    weight: 35,
    category: ScamCategory.refundScam,
    recommendedAction: 'Do not pay upfront fees or share OTPs for loan approvals or refunds.',
  ),
];
