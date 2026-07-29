class AiExplanation {
  final String simpleExplanation;
  final String reason;
  final String recommendedAction;
  final String shortSummary;

  AiExplanation({
    required this.simpleExplanation,
    required this.reason,
    required this.recommendedAction,
    required this.shortSummary,
  });

  factory AiExplanation.fromJson(Map<String, dynamic> json) {
    return AiExplanation(
      simpleExplanation: json['simple_explanation'] ?? 'Analysis unavailable.',
      reason: json['reason'] ?? 'Could not fetch explanation.',
      recommendedAction: json['recommended_action'] ?? 'Verify independently.',
      shortSummary: json['short_summary'] ?? 'Unknown Risk',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'simple_explanation': simpleExplanation,
      'reason': reason,
      'recommended_action': recommendedAction,
      'short_summary': shortSummary,
    };
  }
}
