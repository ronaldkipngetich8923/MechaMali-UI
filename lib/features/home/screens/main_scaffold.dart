import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
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
                    Text(user?.name ?? 'Guest',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(user?.phone ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    if (user?.isVip == true)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('VIP', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              _DrawerItem(icon: Icons.home_rounded,        label: 'Home',       onTap: () { context.go('/home');    Navigator.pop(context); }),
              _DrawerItem(icon: Icons.star_rounded,        label: 'Go VIP',     onTap: () { context.push('/vip');  Navigator.pop(context); }, highlight: true),
              _DrawerItem(icon: Icons.person_rounded,      label: 'Profile',    onTap: () { context.go('/profile'); Navigator.pop(context); }),
              _DrawerItem(icon: Icons.notifications_rounded, label: 'Notifications', onTap: () { Navigator.pop(context); }),

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
                child: Text('MechaMali v1.0.0', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  const _DrawerItem({required this.icon, required this.label, required this.onTap, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: highlight ? AppTheme.accent : AppTheme.textSecondary),
      title: Text(label, style: TextStyle(color: highlight ? AppTheme.accent : AppTheme.textPrimary, fontWeight: highlight ? FontWeight.w600 : FontWeight.normal)),
      onTap: onTap,
    );
  }
}
