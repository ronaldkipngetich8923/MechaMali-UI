import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mechamali/features/home/widgets/quick_access_bar.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/matches_provider.dart';
import '../widgets/match_card.dart';
import '../widgets/region_filter_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchesProvider);

    // No Scaffold here — MainScaffold owns it
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => ref.refresh(matchesProvider.future),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: QuickAccessBar()),
          const SliverToBoxAdapter(child: RegionFilterBar()),

          matchesAsync.when(
            data: (matches) {
              final live     = matches.where((m) => m.isLive).toList();
              final upcoming = matches.where((m) => !m.isLive && !m.isFinished).toList();
              final finished = matches.where((m) => m.isFinished).toList();

              if (matches.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sports_soccer, color: AppTheme.textSecondary, size: 48),
                        SizedBox(height: 12),
                        Text('No matches available',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  if (live.isNotEmpty) ...[
                    _SectionHeader(title: 'Live Now', count: live.length, isLive: true),
                    ...live.map((m) => MatchCard(
                        match: m, onTap: () => context.push('/match/${m.id}'))),
                  ],
                  if (upcoming.isNotEmpty) ...[
                    _SectionHeader(title: 'Upcoming', count: upcoming.length),
                    ...upcoming.map((m) => MatchCard(
                        match: m, onTap: () => context.push('/match/${m.id}'))),
                  ],
                  if (finished.isNotEmpty) ...[
                    _SectionHeader(title: 'Results', count: finished.length),
                    ...finished.map((m) => MatchCard(
                        match: m, onTap: () => context.push('/match/${m.id}'))),
                  ],
                  const SizedBox(height: 80),
                ]),
              );
            },
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, __) => const _MatchCardShimmer(),
                childCount: 6,
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        color: AppTheme.textSecondary, size: 48),
                    const SizedBox(height: 12),
                    const Text('Could not load matches',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref.refresh(matchesProvider.future),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isLive;

  const _SectionHeader(
      {required this.title, required this.count, this.isLive = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          if (isLive) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppTheme.danger, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10)),
            child: Text('$count',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _MatchCardShimmer extends StatelessWidget {
  const _MatchCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      height: 90,
      decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12)),
    );
  }
}