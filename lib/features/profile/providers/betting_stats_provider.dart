// lib/features/profile/providers/betting_stats_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class UserBettingStats {
  final double winRate;
  final int totalBets;
  final int profit;
  final int totalStake;
  final int totalWon;
  final List<BetRecord> recentBets;

  const UserBettingStats({
    required this.winRate,
    required this.totalBets,
    required this.profit,
    required this.totalStake,
    required this.totalWon,
    required this.recentBets,
  });

  factory UserBettingStats.fromJson(Map<String, dynamic> json) => UserBettingStats(
    winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
    totalBets: json['totalBets'] as int? ?? 0,
    profit: json['profit'] as int? ?? 0,
    totalStake: json['totalStake'] as int? ?? 0,
    totalWon: json['totalWon'] as int? ?? 0,
    recentBets: (json['recentBets'] as List?)
        ?.map((e) => BetRecord.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
  );
}

class BetRecord {
  final String matchId;
  final String betType;
  final double odds;
  final int stake;
  final bool isWon;
  final DateTime date;

  BetRecord({
    required this.matchId,
    required this.betType,
    required this.odds,
    required this.stake,
    required this.isWon,
    required this.date,
  });

  factory BetRecord.fromJson(Map<String, dynamic> json) => BetRecord(
    matchId: json['matchId'] as String,
    betType: json['betType'] as String,
    odds: (json['odds'] as num).toDouble(),
    stake: json['stake'] as int,
    isWon: json['isWon'] as bool,
    date: DateTime.parse(json['date'] as String),
  );
}

final userBettingStatsProvider = FutureProvider<UserBettingStats>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/user/betting-stats');
    return UserBettingStats.fromJson(response.data as Map<String, dynamic>);
  } catch (e) {
    // Return empty stats if API not ready yet
    return const UserBettingStats(
      winRate: 0,
      totalBets: 0,
      profit: 0,
      totalStake: 0,
      totalWon: 0,
      recentBets: [],
    );
  }
});