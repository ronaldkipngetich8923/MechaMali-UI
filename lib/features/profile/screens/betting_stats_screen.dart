// lib/features/profile/screens/betting_stats_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/betting_performance.dart';
import '../providers/betting_stats_provider.dart';

class BettingStatsScreen extends ConsumerWidget {
  const BettingStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userBettingStatsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Performance'),
        backgroundColor: AppTheme.background,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(userBettingStatsProvider.future),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const BettingPerformance(),
              const SizedBox(height: 16),

              // Detailed stats
              statsAsync.when(
                data: (stats) => _DetailedStats(stats: stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                  child: Text('No betting history yet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailedStats extends StatelessWidget {
  final UserBettingStats stats;

  const _DetailedStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Statistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _StatRow(label: 'Total Stake', value: 'KES ${stats.totalStake}'),
            _StatRow(label: 'Total Won', value: 'KES ${stats.totalWon}'),
            _StatRow(label: 'Net Profit', value: 'KES ${stats.profit}',
                color: stats.profit >= 0 ? AppTheme.primaryLight : AppTheme.danger),
            _StatRow(label: 'Win Rate', value: '${stats.winRate.toStringAsFixed(1)}%'),
            _StatRow(label: 'Total Bets', value: stats.totalBets.toString()),

            const SizedBox(height: 16),
            const Text(
              '💡 Pro Tip',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'VIP users have 40% higher win rate with AI-powered insights',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatRow({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}