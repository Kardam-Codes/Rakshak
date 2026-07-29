import 'package:flutter_test/flutter_test.dart';
import '../lib/engine/explainability/templates/explanation_templates.dart';
import '../lib/engine/explainability/prompt_builder.dart';
import '../lib/engine/models/scam_category.dart';

void main() {
  group('ExplanationTemplateBuilder Tests', () {
    test('Should return fallback templates for OTP accurately', () {
      final data = ExplanationTemplateBuilder.build(ScamCategory.otpScam);
      
      expect(data['explanation'], contains('OTP'));
      expect(data['recommendation'], contains('Never share'));
      expect(data['preventionTips'] is List<String>, true);
      expect((data['preventionTips'] as List).isNotEmpty, true);
    });

    test('Should return generalized templates for unknown categories', () {
      final data = ExplanationTemplateBuilder.build(ScamCategory.unknown);
      
      expect(data['explanation'], contains('suspicious flags'));
      expect(data['recommendation'], contains('caution'));
    });
  });

  group('PromptBuilder Tests', () {
    test('Should format correct centralized Prompt injection variables', () {
       final prompt = PromptBuilder.buildCentralizedPrompt(
          contextType: 'upi_transaction',
          content: 'fake_person 500 dollars',
          category: ScamCategory.collectRequest.name,
          riskLevel: 'critical',
          confidence: 0.98,
          matchedRules: ['UPI_COLLECT_01'],
       );

       // Expect correct bindings injected
       expect(prompt.contains('Analyze the requested upi_transaction'), isTrue);
       expect(prompt.contains('fake_person 500 dollars'), isTrue);
       expect(prompt.contains('critical'), isTrue);
       expect(prompt.contains('0.98'), isTrue);
       expect(prompt.contains('UPI_COLLECT_01'), isTrue);
       // Expect strict json adherence guidelines
       expect(prompt.contains('schema'), isTrue);
       expect(prompt.contains('simpleExplanation'), isTrue);
    });
  });
}
