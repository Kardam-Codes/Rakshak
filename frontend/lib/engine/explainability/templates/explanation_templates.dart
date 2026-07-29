import '../../../engine/models/scam_category.dart';

class ExplanationTemplateBuilder {
  ExplanationTemplateBuilder._();

  static Map<String, dynamic> build(ScamCategory category) {
    switch (category) {
      case ScamCategory.otpScam:
        return {
          'explanation': 'This message asks for an OTP or PIN, which is a common method used by scammers to hijack your accounts.',
          'recommendation': 'Never share your OTP with anyone. Delete this message immediately.',
          'preventionTips': <String>[
            'Banks will never ask for your OTP over phone or SMS.',
            'Do not forward SMS messages containing verification codes.',
            'Enable Two-Factor Authentication using an authenticator app.',
          ],
        };
      case ScamCategory.refundScam:
        return {
          'explanation': 'This claims you have a pending refund or failed payment and creates a false sense of urgency.',
          'recommendation': 'Do not click the link or call the number. Contact the official app directly.',
          'preventionTips': <String>[
            'Scammers create fake refund alerts to steal bank details.',
            'Always check refunds directly inside the official app.',
          ],
        };
      case ScamCategory.investmentScam:
        return {
          'explanation': 'This message offers guaranteed high returns on an investment, which is a classic Ponzi scam tactic.',
          'recommendation': 'Ignore this offer. Legitimate investments never guarantee zero risk.',
          'preventionTips': <String>[
            'High returns with zero risk are always a scam.',
            'Do not invest through unknown Telegram or WhatsApp groups.',
          ],
        };
      case ScamCategory.collectRequest:
        return {
          'explanation': 'This is a UPI Collect Request. The sender is trying to take money FROM your account.',
          'recommendation': 'Decline the request. Do NOT enter your UPI PIN.',
          'preventionTips': <String>[
            'You do NOT need to enter your UPI PIN to receive money.',
            'Entering a PIN always deducts money from your account.',
          ],
        };
      case ScamCategory.lotteryScam:
        return {
          'explanation': 'This claims you have won a lottery or prize you did not enter.',
          'recommendation': 'Do not reply or pay any "tax" to claim the prize.',
          'preventionTips': <String>[
            'You cannot win a lottery you never entered.',
            'Scammers ask for an initial fee to release fake winnings.',
          ],
        };
      case ScamCategory.fakeLoan:
        return {
          'explanation': 'This offers an instant loan without paperwork, often used to trap victims in extortion schemes.',
          'recommendation': 'Do not click the link or install their app.',
          'preventionTips': <String>[
            'Fake loan apps steal your contacts and photos to blackmail you.',
            'Only borrow from RBI-registered organizations.',
          ],
        };
      case ScamCategory.kycScam:
        return {
          'explanation': 'This claims your bank account, SIM, or wallet will be blocked unless you complete KYC via a link.',
          'recommendation': 'Do not click the link. Your account is likely safe.',
          'preventionTips': <String>[
            'Banks do not suspend accounts via SMS links.',
            'Visit the bank branch directly for any KYC updates.',
          ],
        };
      default:
        return {
          'explanation': 'This interaction exhibited multiple suspicious flags matching known scam techniques.',
          'recommendation': 'Exercise extreme caution. Do not share personal details, passwords, or money.',
          'preventionTips': <String>[
            'Verify the identity of the sender through a trusted channel.',
            'Never act under pressure or urgency.',
          ],
        };
    }
  }
}
