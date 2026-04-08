// lib/features/profile/widgets/betting_performance.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/betting_stats_provider.dart';

class BettingPerformance extends ConsumerWidget {
  const BettingPerformance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userBettingStatsProvider);

    return Card(
      color: AppTheme.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_rounded, color: AppTheme.accent, size: 20),
                SizedBox(width: 8),
                Text(
                  'Your Betting Performance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            statsAsync.when(
              data: (stats) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatCard(
                    title: 'Win Rate',
                    value: '${stats.winRate.toStringAsFixed(1)}%',
                    icon: Icons.emoji_events_rounded,
                    color: AppTheme.accent,
                  ),
                  StatCard(
                    title: 'Total Bets',
                    value: stats.totalBets.toString(),
                    icon: Icons.receipt_rounded,
                    color: AppTheme.primaryLight,
                  ),
                  StatCard(
                    title: 'Profit/Loss',
                    value: KenyanCurrencyFormatter.format(stats.profit),
                    icon: stats.profit >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: stats.profit >= 0 ? AppTheme.primaryLight : AppTheme.danger,
                  ),
                ],
              ),
              loading: () => const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatCardShimmer(),
                  StatCardShimmer(),
                  StatCardShimmer(),
                ],
              ),
              error: (_, __) => const Center(
                child: Text(
                  'Place your first bet to see stats',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 12),

            const Text(
              'Recent Bets',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            statsAsync.when(
              data: (stats) => stats.recentBets.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No recent bets',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
                  : Column(
                children: stats.recentBets.take(3).map((bet) => RecentBetItem(bet: bet)).toList(),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class StatCardShimmer extends StatelessWidget {
  const StatCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.divider,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 11,
          decoration: BoxDecoration(
            color: AppTheme.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class RecentBetItem extends StatelessWidget {
  final BetRecord bet;

  const RecentBetItem({super.key, required this.bet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bet.isWon ? AppTheme.primary.withOpacity(0.15) : AppTheme.danger.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              bet.isWon ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: bet.isWon ? AppTheme.primaryLight : AppTheme.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bet.betType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stake: ${KenyanCurrencyFormatter.format(bet.stake)} @ ${bet.odds.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                bet.isWon ? 'Won' : 'Lost',
                style: TextStyle(
                  color: bet.isWon ? AppTheme.primaryLight : AppTheme.danger,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(bet.date),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}