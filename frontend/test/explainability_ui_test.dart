import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/widgets/explainability/explanation_card.dart';
import '../lib/widgets/explainability/recommendation_card.dart';
import '../lib/widgets/explainability/prevention_tips_card.dart';
import '../lib/widgets/explainability/confidence_badge.dart';

void main() {
  group('Explainability UI Widgets', () {
    testWidgets('ExplanationCard displays title and text semantics', (WidgetTester tester) async {
       await tester.pumpWidget(const MaterialApp(
         home: Scaffold(
           body: ExplanationCard(
             title: 'AI Analysis',
             explanation: 'This is a test explanation.',
             isAiGenerated: true,
           )
         )
       ));

       expect(find.text('AI Analysis'), findsOneWidget);
       expect(find.text('This is a test explanation.'), findsOneWidget);
       expect(find.byType(ExplanationCard), findsOneWidget);
    });

    testWidgets('RecommendationCard displays correctly', (WidgetTester tester) async {
       await tester.pumpWidget(const MaterialApp(
         home: Scaffold(
           body: RecommendationCard(
             recommendedAction: 'Do not panic.',
           )
         )
       ));

       expect(find.text('Recommended Action'), findsOneWidget);
       expect(find.text('Do not panic.'), findsOneWidget);
    });

    testWidgets('PreventionTipsCard renders list of tips', (WidgetTester tester) async {
       await tester.pumpWidget(const MaterialApp(
         home: Scaffold(
           body: PreventionTipsCard(
             tips: ['Tip 1', 'Tip 2'],
           )
         )
       ));

       expect(find.text('Safety Prevention Tips'), findsOneWidget);
       expect(find.text('Tip 1'), findsOneWidget);
       expect(find.text('Tip 2'), findsOneWidget);
    });

    testWidgets('ConfidenceBadge maps proper percentages', (WidgetTester tester) async {
       await tester.pumpWidget(const MaterialApp(
         home: Scaffold(
           body: ConfidenceBadge(
             confidence: 0.85,
           )
         )
       ));

       expect(find.text('85% Match'), findsOneWidget);
    });
  });
}
