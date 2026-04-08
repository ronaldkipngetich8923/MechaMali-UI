// lib/features/stats/providers/betting_stats_provider.dart
class BettingStatsProvider {
  final List<Map<String, dynamic>> _historicalData = [
    {'team': 'Gor Mahia', 'homeWin': 65, 'over15': 70, 'btts': 45},
    {'team': 'AFC Leopards', 'homeWin': 55, 'over15': 60, 'btts': 40},
    {'team': 'KCB', 'homeWin': 58, 'over15': 68, 'btts': 48},
  ];

  Future<Map<String, dynamic>> getTeamStats(String teamName) async {
    // Fetch from your backend or compute
    return _historicalData.firstWhere((t) => t['team'] == teamName);
  }

  String getBettingTip(Map<String, dynamic> homeStats, Map<String, dynamic> awayStats) {
    final homeWinProb = homeStats['homeWin'] ?? 50;
    final over15Prob = (homeStats['over15'] + awayStats['over15']) / 2;

    if (over15Prob > 65) return 'Over 1.5 Goals';
    if (homeWinProb > 60) return 'Home Win';
    if (homeWinProb < 40) return 'Away Win';
    return 'Double Chance';
  }
}