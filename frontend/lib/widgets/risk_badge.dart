import 'package:flutter/material.dart';
import '../engine/models/risk_level.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel riskLevel;

  const RiskBadge({Key? key, required this.riskLevel}) : super(key: key);

  Color get _color {
    switch (riskLevel) {
      case RiskLevel.safe:
        return Colors.green;
      case RiskLevel.low:
        return Colors.blue;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.critical:
        return Colors.red.shade900;
    }
  }

  String get _label {
    return riskLevel.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Text(
        _label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
