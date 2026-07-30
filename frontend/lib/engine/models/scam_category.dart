enum ScamCategory {
  otpScam,
  kycScam,
  lotteryScam,
  investmentScam,
  refundScam,
  qrScam,
  collectRequest,
  fakeLoan,
  giftScam,
  jobScam,
  phishingWebsite,
  suspiciousDomain,
  maliciousUrl,
  unknown
}

extension ScamCategoryExtension on ScamCategory {
  String get displayName {
    switch (this) {
      case ScamCategory.otpScam:
        return 'OTP Scam';
      case ScamCategory.kycScam:
        return 'KYC Scam';
      case ScamCategory.lotteryScam:
        return 'Lottery Scam';
      case ScamCategory.investmentScam:
        return 'Investment Scam';
      case ScamCategory.refundScam:
        return 'Refund Scam';
      case ScamCategory.qrScam:
        return 'QR Scam';
      case ScamCategory.collectRequest:
        return 'Collect Request';
      case ScamCategory.fakeLoan:
        return 'Fake Loan';
      case ScamCategory.giftScam:
        return 'Gift Scam';
      case ScamCategory.jobScam:
        return 'Job Scam';
      case ScamCategory.phishingWebsite:
        return 'Phishing Website';
      case ScamCategory.suspiciousDomain:
        return 'Suspicious Domain';
      case ScamCategory.maliciousUrl:
        return 'Malicious URL';
      case ScamCategory.unknown:
        return 'Unknown';
    }
  }
}
