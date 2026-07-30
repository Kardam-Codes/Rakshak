import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/screens/family/widgets/emergency_countdown_dialog.dart';

void main() {
  group('EmergencyCountdownDialog Widget Tests', () {
    testWidgets('Renders countdown dialog with title and initial 10s state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyCountdownDialog(
              userName: 'Senior User',
              category: 'Collect Request',
              riskLevel: 'CRITICAL',
              initialSeconds: 10,
              onConfirm: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Notify Your Trusted Family?'), findsOneWidget);
      expect(find.text('Notify Now'), findsOneWidget);
      expect(find.text('Cancel Alert'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('Tapping Cancel Alert invokes onCancel callback', (WidgetTester tester) async {
      bool isCancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyCountdownDialog(
              userName: 'Senior User',
              category: 'Collect Request',
              riskLevel: 'HIGH',
              initialSeconds: 10,
              onConfirm: () {},
              onCancel: () {
                isCancelled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancel Alert'));
      await tester.pumpAndSettle();

      expect(isCancelled, isTrue);
    });
  });
}
