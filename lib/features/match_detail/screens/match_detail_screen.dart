import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/match_model.dart';
import '../../../core/models/insight_model.dart';
import '../../home/providers/matches_provider.dart';
import '../../home/providers/watchlist_provider.dart';
import '../providers/insight_provider.dart';

class MatchDetailScreen extends ConsumerWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchAsync   = ref.watch(matchDetailProvider(matchId));
    final insightAsync = ref.watch(insightProvider(matchId));
    final isWatched    = ref.watch(watchlistNotifierProvider).contains(matchId);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: matchAsync.when(
        data: (match) => CustomScrollView(
          slivers: [
            // Hero app bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppTheme.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(isWatched ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isWatched ? AppTheme.accent : Colors.white),
                  onPressed: () => ref.read(watchlistNotifierProvider.notifier).toggle(matchId),
                  tooltip: isWatched ? 'Remove from watchlist' : 'Add to watchlist',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _MatchHero(match: match),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // League + venue
                  Row(
                    children: [
                      const Icon(Icons.stadium_rounded, color: AppTheme.textSecondary, size: 14),
                      const SizedBox(width: 6),
                      Text(match.venue ?? match.league,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // AI Insight card
                  const Text('AI Match Insight',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  insightAsync.when(
                    data: (insight) => _InsightCard(insight: insight),
                    loading: () => const _InsightShimmer(),
                    error: (_, __) => _InsightError(onRetry: () => ref.refresh(insightProvider(matchId))),
                  ),

                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}

class _MatchHero extends StatelessWidget {
  final MatchModel match;
  const _MatchHero({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(match.league, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeroTeam(name: match.homeTeam, logoUrl: match.homeTeamLogo),
              Column(
                children: [
                  if (match.isLive || match.isFinished)
                    Text('${match.homeScore ?? 0}  -  ${match.awayScore ?? 0}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800))
                  else
                    const Text('vs', style: TextStyle(color: AppTheme.textSecondary, fontSize: 24)),
                  const SizedBox(height: 4),
                  if (match.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(6)),
                      child: Text(match.minute != null ? "${match.minute}'" : 'LIVE',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              _HeroTeam(name: match.awayTeam, logoUrl: match.awayTeamLogo),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroTeam extends StatelessWidget {
  final String name, logoUrl;
  const _HeroTeam({required this.name, required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28, backgroundColor: AppTheme.surfaceCard,
          backgroundImage: logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
          child: logoUrl.isEmpty ? const Icon(Icons.sports_soccer, color: AppTheme.textSecondary) : null,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final InsightModel insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final isTeaser = insight.insightText.contains('[Upgrade to VIP');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppTheme.primaryLight, size: 18),
              const SizedBox(width: 6),
              const Text('AI Analysis', style: TextStyle(color: AppTheme.primaryLight, fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (insight.isVipOnly)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: const Text('VIP', style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(insight.insightText,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6)),

          if (isTeaser) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/vip'),
              icon: const Icon(Icons.star_rounded, size: 16),
              label: const Text('Unlock Full Insight — Go VIP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],

          // Win probability bars
          if (insight.homeWinProbability != null) ...[
            const SizedBox(height: 20),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 12),
            _ProbabilityBar(
              homeProb: insight.homeWinProbability!,
              drawProb: insight.drawProbability ?? 0,
              awayProb: insight.awayWinProbability ?? 0,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProbabilityBar extends StatelessWidget {
  final double homeProb, drawProb, awayProb;
  const _ProbabilityBar({required this.homeProb, required this.drawProb, required this.awayProb});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${(homeProb * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            const Text('Draw', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            Text('${(awayProb * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(flex: (homeProb * 100).round(), child: Container(height: 6, color: AppTheme.primary)),
              Expanded(flex: (drawProb * 100).round(), child: Container(height: 6, color: AppTheme.textSecondary)),
              Expanded(flex: (awayProb * 100).round(), child: Container(height: 6, color: AppTheme.accent)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightShimmer extends StatelessWidget {
  const _InsightShimmer();
  @override
  Widget build(BuildContext context) => Container(
        height: 160, decoration: BoxDecoration(color: AppTheme.surfaceCard, borderRadius: BorderRadius.circular(12)));
}

class _InsightError extends StatelessWidget {
  final VoidCallback onRetry;
  const _InsightError({required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surfaceCard, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          const Text('Could not load insight', style: TextStyle(color: AppTheme.textSecondary)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}
