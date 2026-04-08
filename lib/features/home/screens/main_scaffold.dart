// lib/features/home/screens/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/match_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/matches_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: AppTheme.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.accent,
                      child: Icon(Icons.person, color: AppTheme.primary, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Guest',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      user?.phone ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    if (user?.isVip == true)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('VIP',
                            style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              _DrawerItem(
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () { Navigator.pop(context); context.go('/home'); },
              ),
              _DrawerItem(
                icon: Icons.trending_up_rounded,
                label: 'Betting Tips',
                onTap: () { Navigator.pop(context); context.push('/betting-tips'); },
              ),
              _DrawerItem(
                icon: Icons.analytics_rounded,
                label: 'My Performance',
                onTap: () { Navigator.pop(context); context.push('/betting-stats'); },
              ),

              const Divider(),

              _DrawerItem(
                icon: Icons.star_rounded,
                label: 'Go VIP',
                highlight: true,
                onTap: () { Navigator.pop(context); context.push('/vip'); },
              ),
              _DrawerItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () { Navigator.pop(context); context.go('/profile'); },
              ),
              _DrawerItem(
                icon: Icons.bookmark_rounded,
                label: 'My Watchlist',
                onTap: () { Navigator.pop(context); context.push('/watchlist'); },
              ),
              _DrawerItem(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                onTap: () { Navigator.pop(context); context.push('/notifications'); },
              ),
              _DrawerItem(
                icon: Icons.help_outline_rounded,
                label: 'Betting Tutorial',
                onTap: () { Navigator.pop(context); context.push('/tutorial'); },
              ),

              const Divider(),

              _DrawerItem(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(authProvider.notifier).signOut();
                },
              ),

              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('MechaMali v1.0.0',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'MechaMali',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () => _showSearchDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.star_rounded, color: AppTheme.accent),
            onPressed: () => context.push('/vip'),
            tooltip: 'Go VIP',
          ),
        ],
      ),
      body: child,
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    // FIX: pass the current matches list into the dialog so it can filter
    final matchesAsync = ref.read(matchesProvider);
    final matches = matchesAsync.valueOrNull ?? [];
    showDialog(
      context: context,
      builder: (context) => SearchDialog(allMatches: matches),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: highlight ? AppTheme.accent : AppTheme.textSecondary),
      title: Text(label,
          style: TextStyle(
            color: highlight ? AppTheme.accent : AppTheme.textPrimary,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
          )),
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// FIX: SearchDialog — was a stub that closed on submit with no action.
// Now filters the loaded matches list by team name or league and shows
// tappable results that navigate to the match detail screen.
// ---------------------------------------------------------------------------
class SearchDialog extends StatefulWidget {
  final List<MatchModel> allMatches;

  const SearchDialog({super.key, required this.allMatches});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _controller = TextEditingController();
  List<MatchModel> _results = [];

  @override
  void initState() {
    super.initState();
    _results = widget.allMatches;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _results = q.isEmpty
          ? widget.allMatches
          : widget.allMatches.where((m) {
        return m.homeTeam.toLowerCase().contains(q) ||
            m.awayTeam.toLowerCase().contains(q) ||
            m.league.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search teams, leagues...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary),
                  onPressed: () {
                    _controller.clear();
                    _onQueryChanged('');
                  },
                )
                    : null,
              ),
              onChanged: _onQueryChanged,
            ),
          ),

          // Results
          if (widget.allMatches.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No matches loaded yet.',
                  style: TextStyle(color: AppTheme.textSecondary)),
            )
          else if (_results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No matches found.',
                  style: TextStyle(color: AppTheme.textSecondary)),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: _results.length,
                separatorBuilder: (_, __) =>
                const Divider(color: AppTheme.divider, height: 1),
                itemBuilder: (_, i) {
                  final m = _results[i];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.surfaceCard,
                      backgroundImage: m.homeTeamLogo.isNotEmpty
                          ? NetworkImage(m.homeTeamLogo)
                          : null,
                      child: m.homeTeamLogo.isEmpty
                          ? const Icon(Icons.sports_soccer,
                          size: 14, color: AppTheme.textSecondary)
                          : null,
                    ),
                    title: Text(
                      '${m.homeTeam} vs ${m.awayTeam}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    subtitle: Text(
                      m.league,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                    trailing: m.isLive
                        ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('LIVE',
                          style: TextStyle(
                              color: AppTheme.danger,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/match/${m.id}');
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}