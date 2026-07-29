import 'package:flutter/material.dart';
import '../../../widgets/info_card.dart';
import '../../../core/constants/icons.dart';

class SafetyTipCard extends StatelessWidget {
  const SafetyTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoCard(
      title: 'Safety Tip',
      subtitle: 'Never share your OTP with anyone over the phone. Banks will never ask for it.',
      icon: AppIcons.info,
    );
  }
}
