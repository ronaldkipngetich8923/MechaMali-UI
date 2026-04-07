import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar + name
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      backgroundColor: AppTheme.primary,
                      child: Icon(Icons.person_rounded, color: Colors.white, size: 44),
                    ),
                    if (user?.isVip == true)
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                          child: const Icon(Icons.star_rounded, color: AppTheme.primary, size: 14),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? 'Fan',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(user?.phone ?? '',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                if (user?.isVip == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: AppTheme.accent, size: 14),
                        SizedBox(width: 4),
                        Text('VIP Member', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => context.push('/vip'),
                    icon: const Icon(Icons.star_border_rounded, size: 16),
                    label: const Text('Upgrade to VIP'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 8),

          _SettingsTile(icon: Icons.notifications_outlined, title: 'Notifications', onTap: () {}),
          _SettingsTile(icon: Icons.language_outlined,      title: 'Language',      onTap: () {}),
          _SettingsTile(icon: Icons.shield_outlined,        title: 'Privacy Policy', onTap: () {}),
          _SettingsTile(icon: Icons.info_outline,           title: 'About MechaMali', onTap: () {}),

          const SizedBox(height: 8),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Sign out',
            color: AppTheme.danger,
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({required this.icon, required this.title, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppTheme.textSecondary, size: 22),
      title: Text(title, style: TextStyle(color: c, fontSize: 15)),
      trailing: color == null ? const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary) : null,
      onTap: onTap,
    );
  }
}
