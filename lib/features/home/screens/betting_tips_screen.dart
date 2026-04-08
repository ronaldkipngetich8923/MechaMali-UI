// lib/features/home/screens/betting_tips_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
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
      appBar: AppBar(
        title: const Text('Betting Tips'),
        backgroundColor: AppTheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(bettingTipsProvider),
          ),
        ],
      ),
      body: tipsAsync.when(
        data: (tips) {
          if (tips.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.trending_up_rounded, size: 64, color: AppTheme.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'No betting tips available',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          final hotTips = tips.where((t) => t.confidence > 70).toList();
          final regularTips = tips.where((t) => t.confidence <= 70).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(bettingTipsProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (!isVip) ...[
                  const _VipBanner(),
                  const SizedBox(height: 16),
                ],
                if (hotTips.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '🔥 Today\'s Hot Tips',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...hotTips.map((tip) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: _TipCard(tip: tip, isVip: isVip),
                  )),
                  const SizedBox(height: 8),
                ],
                if (regularTips.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '📊 More Predictions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...regularTips.map((tip) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: _TipCard(tip: tip, isVip: isVip),
                  )),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.danger),
              const SizedBox(height: 16),
              const Text(
                'Failed to load tips',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(bettingTipsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VipBanner extends StatelessWidget {
  const _VipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(width: 8),
          // FIX: constrain the button width so it doesn't go infinite in a Row
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => context.push('/vip'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Upgrade', overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final BettingTip tip;
  final bool isVip;

  const _TipCard({
    required this.tip,
    required this.isVip,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = tip.isVipOnly && !isVip;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: tip.confidence > 80
            ? Border.all(color: AppTheme.accent, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : () => context.push('/match/${tip.matchId}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${tip.homeTeam} vs ${tip.awayTeam}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tip.isVipOnly)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prediction',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip.tipType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppTheme.divider),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Odds',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip.odds.toStringAsFixed(2),
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppTheme.divider),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Confidence',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tip.confidence.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: tip.confidence > 70 ? AppTheme.accent : AppTheme.primaryLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
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
                        const Expanded(
                          child: Text(
                            'VIP only - Upgrade to unlock',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ),
                        // FIX: also constrain this button
                        SizedBox(
                          width: 90,
                          child: TextButton(
                            onPressed: () => context.push('/vip'),
                            child: const Text('Upgrade'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}