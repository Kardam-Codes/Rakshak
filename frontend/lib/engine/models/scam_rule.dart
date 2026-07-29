import 'scam_category.dart';

class ScamRule {
  final String id;
  final String name;
  final String description;
  final List<String> keywords;
  final String? regex;
  final int weight;
  final ScamCategory category;
  final String recommendedAction;
  final bool enabled;

  const ScamRule({
    required this.id,
    required this.name,
    required this.description,
    required this.keywords,
    this.regex,
    required this.weight,
    required this.category,
    required this.recommendedAction,
    this.enabled = true,
  });
}
