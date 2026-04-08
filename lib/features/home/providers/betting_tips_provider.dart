// lib/features/home/providers/betting_tips_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class BettingTip {
  final String id;
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final String tipType;
  final double odds;
  final double confidence;
  final bool isVipOnly;
  final DateTime kickOff;

  BettingTip({
    required this.id,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.tipType,
    required this.odds,
    required this.confidence,
    required this.isVipOnly,
    required this.kickOff,
  });

  factory BettingTip.fromJson(Map<String, dynamic> json) => BettingTip(
    id: json['id'] as String,
    matchId: json['matchId'] as String,
    homeTeam: json['homeTeam'] as String,
    awayTeam: json['awayTeam'] as String,
    tipType: json['tipType'] as String,
    odds: (json['odds'] as num).toDouble(),
    confidence: (json['confidence'] as num).toDouble(),
    isVipOnly: json['isVipOnly'] as bool? ?? false,
    kickOff: DateTime.parse(json['kickOff'] as String),
  );
}

final bettingTipsProvider = FutureProvider<List<BettingTip>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/betting/tips');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => BettingTip.fromJson(e as Map<String, dynamic>)).toList();
  } catch (e) {
    // Return mock data for development
    return _getMockTips();
  }
});

// Mock data for development
List<BettingTip> _getMockTips() {
  final now = DateTime.now();
  return [
    BettingTip(
      id: '1',
      matchId: '1',
      homeTeam: 'Gor Mahia',
      awayTeam: 'AFC Leopards',
      tipType: 'Over 1.5 Goals',
      odds: 1.45,
      confidence: 82,
      isVipOnly: false,
      kickOff: now.add(const Duration(hours: 2)),
    ),
    BettingTip(
      id: '2',
      matchId: '2',
      homeTeam: 'KCB',
      awayTeam: 'Tusker',
      tipType: 'Home Win',
      odds: 2.10,
      confidence: 68,
      isVipOnly: false,
      kickOff: now.add(const Duration(hours: 4)),
    ),
    BettingTip(
      id: '3',
      matchId: '3',
      homeTeam: 'Manchester City',
      awayTeam: 'Liverpool',
      tipType: 'Both Teams to Score',
      odds: 1.85,
      confidence: 91,
      isVipOnly: true,
      kickOff: now.add(const Duration(hours: 5)),
    ),
  ];
}