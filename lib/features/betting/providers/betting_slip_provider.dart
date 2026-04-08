// lib/features/betting/providers/betting_slip_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BettingSlipItem {
  final String matchId;
  final String betType;
  final double odds;
  final double stake;

  BettingSlipItem({required this.matchId, required this.betType, required this.odds, required this.stake});

  double get potentialWin => odds * stake;
}

final bettingSlipProvider = StateNotifierProvider<BettingSlipNotifier, List<BettingSlipItem>>((ref) {
  return BettingSlipNotifier();
});

class BettingSlipNotifier extends StateNotifier<List<BettingSlipItem>> {
  BettingSlipNotifier() : super([]);

  void addBet(BettingSlipItem bet) {
    state = [...state, bet];
  }

  void removeBet(int index) {
    state = [...state]..removeAt(index);
  }

  void clearSlip() {
    state = [];
  }

  double get totalOdds => state.fold(1.0, (sum, item) => sum * item.odds);
  double get totalStake => state.fold(0.0, (sum, item) => sum + item.stake);
  double get potentialWin => totalOdds * totalStake;
}