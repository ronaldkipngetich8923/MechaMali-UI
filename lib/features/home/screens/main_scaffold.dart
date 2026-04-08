// lib/features/home/screens/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../screens/betting_tips_screen.dart'; // We'll create this

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

              // Main Navigation Items
              _DrawerItem(
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/home');
                },
              ),

              _DrawerItem(
                icon: Icons.trending_up_rounded,
                label: 'Betting Tips',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/betting-tips');
                },
              ),

              _DrawerItem(
                icon: Icons.analytics_rounded,
                label: 'My Performance',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/betting-stats');
                },
              ),

              const Divider(),

              _DrawerItem(
                icon: Icons.star_rounded,
                label: 'Go VIP',
                highlight: true,
                onTap: () {
                  Navigator.pop(context);
                  context.push('/vip');
                },
              ),

              _DrawerItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/profile');
                },
              ),

              _DrawerItem(
                icon: Icons.bookmark_rounded,
                label: 'My Watchlist',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/watchlist');
                },
              ),

              _DrawerItem(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/notifications');
                },
              ),

              _DrawerItem(
                icon: Icons.help_outline_rounded,
                label: 'Betting Tutorial',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/tutorial');
                },
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
            onPressed: () => _showSearchDialog(context),
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

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SearchDialog(),
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
      leading: Icon(icon,
          color: highlight ? AppTheme.accent : AppTheme.textSecondary),
      title: Text(label,
          style: TextStyle(
            color: highlight ? AppTheme.accent : AppTheme.textPrimary,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
          )),
      onTap: onTap,
    );
  }
}

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search teams, leagues...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onSubmitted: (value) {
                // Implement search
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}