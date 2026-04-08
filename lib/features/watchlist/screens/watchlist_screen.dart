// lib/features/watchlist/screens/watchlist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/providers/watchlist_provider.dart';
import '../../home/widgets/match_card.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Watchlist'),
        backgroundColor: AppTheme.background,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(watchlistProvider.future),
        child: watchlistAsync.when(
          data: (matches) {
            if (matches.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border_rounded, size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'No matches saved',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the bookmark icon on matches to add them',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return MatchCard(
                  match: matches[index],
                  onTap: () => context.push('/match/${matches[index].id}'),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text('Failed to load watchlist'),
          ),
        ),
      ),
    );
  }
}