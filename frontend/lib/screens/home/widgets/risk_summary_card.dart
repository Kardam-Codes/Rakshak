import 'package:flutter/material.dart';
import '../../../widgets/risk_card.dart';
import '../../../core/constants/icons.dart';

class RiskSummaryCard extends StatelessWidget {
  const RiskSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return RiskCard(
      title: 'Your Device is Safe',
      description: 'Rakshak AI has not detected any suspicious activity in the last 24 hours.',
      level: RiskLevel.safe,
      icon: AppIcons.safe,
      action: () {},
      actionText: 'Scan Now',
    );
  }
}
