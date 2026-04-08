// lib/features/home/screens/betting_tips_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/betting_tips_provider.dart';
import '../../auth/providers/auth_provider.dart';

class BettingTipsScreen extends ConsumerWidget {
  const BettingTipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(bettingTipsProvider);
    final user = ref.watch(authProvider).user;
    final isVip = user?.isVip ?? false;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Betting Tips'),
            floating: true,
            backgroundColor: AppTheme.background,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // VIP Banner (if not VIP)
                  if (!isVip)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.accent.withOpacity(0.2), AppTheme.primary.withOpacity(0.2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.accent, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Upgrade to VIP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Get premium tips with 75% accuracy',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => context.push('/vip'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: AppTheme.primary,
                            ),
                            child: const Text('Upgrade'),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Today's Hot Tips Section
                  const Text(
                    '🔥 Today\'s Hot Tips',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          tipsAsync.when(
            data: (tips) {
              final hotTips = tips.where((t) => t.confidence > 70).toList();
              final regularTips = tips.where((t) => t.confidence <= 70).toList();

              return SliverList(
                delegate: SliverChildListDelegate([
                  // Hot tips
                  if (hotTips.isNotEmpty)
                    Column(
                      children: [
                        ...hotTips.map((tip) => BettingTipCard(
                          tip: tip,
                          isVip: isVip,
                          onTap: () => context.push('/match/${tip.matchId}'),
                        )),
                        const SizedBox(height: 20),
                        const Text(
                          '📊 More Predictions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Regular tips
                  ...regularTips.map((tip) => BettingTipCard(
                    tip: tip,
                    isVip: isVip,
                    onTap: () => context.push('/match/${tip.matchId}'),
                  )),

                  const SizedBox(height: 80),
                ]),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SliverFillRemaining(
              child: Center(child: Text('Failed to load tips')),
            ),
          ),
        ],
      ),
    );
  }
}

class BettingTipCard extends StatelessWidget {
  final BettingTip tip;
  final bool isVip;
  final VoidCallback onTap;

  const BettingTipCard({
    super.key,
    required this.tip,
    required this.isVip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = tip.isVipOnly && !isVip;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: tip.confidence > 80
              ? Border.all(color: AppTheme.accent, width: 1)
              : null,
        ),
        child: Column(
          children: [
            // Match info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${tip.homeTeam} vs ${tip.awayTeam}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (tip.isVipOnly)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: AppTheme.accent, size: 12),
                        SizedBox(width: 2),
                        Text('VIP', style: TextStyle(color: AppTheme.accent, fontSize: 10)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Tip and odds
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prediction', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        tip.tipType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.divider,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Odds', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        KenyanCurrencyFormatter.formatOdds(tip.odds),
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.divider,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Confidence', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${tip.confidence.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: _getConfidenceColor(tip.confidence),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (isLocked) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded, color: AppTheme.textSecondary, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'VIP only - Upgrade to unlock',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push('/vip'),
                      child: const Text('Upgrade'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return AppTheme.accent;
    if (confidence >= 60) return AppTheme.primaryLight;
    return AppTheme.textSecondary;
  }
}