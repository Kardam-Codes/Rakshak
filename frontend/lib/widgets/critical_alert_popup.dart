import 'package:flutter/material.dart';
import '../../models/notification_entity.dart';
import '../../core/constants/spacing.dart';

class CriticalAlertPopup extends StatelessWidget {
  final NotificationEntity entity;

  const CriticalAlertPopup({Key? key, required this.entity}) : super(key: key);

  static void show(BuildContext context, NotificationEntity entity) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CriticalAlertPopup(entity: entity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning, color: Colors.red, size: 48),
      title: const Text('Critical Threat Detected!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entity.reason,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red.shade900),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            entity.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(entity.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Dismiss', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            // Navigator routing to detail handled in higher layer
          },
          child: const Text('View Details'),
        ),
      ],
    );
  }
}
