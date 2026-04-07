class InsightModel {
  final String matchId;
  final String insightText;
  final String? homeFormSummary;
  final String? awayFormSummary;
  final String? headToHeadSummary;
  final double? homeWinProbability;
  final double? drawProbability;
  final double? awayWinProbability;
  final bool isVipOnly;

  const InsightModel({
    required this.matchId,
    required this.insightText,
    this.homeFormSummary,
    this.awayFormSummary,
    this.headToHeadSummary,
    this.homeWinProbability,
    this.drawProbability,
    this.awayWinProbability,
    required this.isVipOnly,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) => InsightModel(
        matchId: json['matchId'] as String,
        insightText: json['insightText'] as String,
        homeFormSummary: json['homeFormSummary'] as String?,
        awayFormSummary: json['awayFormSummary'] as String?,
        headToHeadSummary: json['headToHeadSummary'] as String?,
        homeWinProbability: (json['homeWinProbability'] as num?)?.toDouble(),
        drawProbability: (json['drawProbability'] as num?)?.toDouble(),
        awayWinProbability: (json['awayWinProbability'] as num?)?.toDouble(),
        isVipOnly: json['isVipOnly'] as bool? ?? true,
      );
}
