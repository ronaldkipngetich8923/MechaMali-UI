// lib/features/stats/services/historical_stats_service.dart
//
// FIX: This file was originally named betting_stats_provider.dart — the same
// name as lib/features/profile/providers/betting_stats_provider.dart.  That
// caused an import ambiguity and made it impossible for the analyser to resolve
// which file to use.  Renamed to historical_stats_service.dart and the class
// to HistoricalStatsService to eliminate the clash.

class HistoricalStatsService {
  final List<Map<String, dynamic>> _historicalData = [
    {'team': 'Gor Mahia',    'homeWin': 65, 'over15': 70, 'btts': 45},
    {'team': 'AFC Leopards', 'homeWin': 55, 'over15': 60, 'btts': 40},
    {'team': 'KCB',          'homeWin': 58, 'over15': 68, 'btts': 48},
  ];

  Future<Map<String, dynamic>> getTeamStats(String teamName) async {
    return _historicalData.firstWhere(
          (t) => t['team'] == teamName,
      orElse: () => {'team': teamName, 'homeWin': 50, 'over15': 50, 'btts': 40},
    );
  }

  String getBettingTip(
      Map<String, dynamic> homeStats, Map<String, dynamic> awayStats) {
    final homeWinProb = homeStats['homeWin'] as int? ?? 50;
    final over15Prob =
        ((homeStats['over15'] as int? ?? 50) + (awayStats['over15'] as int? ?? 50)) / 2;

    if (over15Prob > 65) return 'Over 1.5 Goals';
    if (homeWinProb > 60) return 'Home Win';
    if (homeWinProb < 40) return 'Away Win';
    return 'Double Chance';
  }
}