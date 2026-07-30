import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rakshak/screens/emergency/emergency_screen.dart';
import 'package:rakshak/screens/emergency/widgets/recovery_action_card.dart';

void main() {
  testWidgets('EmergencyScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EmergencyScreen(suspiciousMessage: 'Test scam msg'),
        ),
      ),
    );

    // Verify app bar title
    expect(find.text('Emergency Recovery'), findsOneWidget);

    // Verify all 5 cards are rendered by checking their titles
    expect(find.text('Contact Bank'), findsOneWidget);
    expect(find.text('Report Cyber Crime'), findsOneWidget);
    expect(find.text('Block Number'), findsOneWidget);
    expect(find.text('Notify Trusted Contact'), findsOneWidget);
    expect(find.text('Save Evidence'), findsOneWidget);

    // Verify custom recovery action cards count
    expect(find.byType(RecoveryActionCard), findsNWidgets(5));
  });
}
