// lib/features/home/widgets/quick_access_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class QuickAccessBar extends StatelessWidget {
  const QuickAccessBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _QuickAccessItem(
            icon: Icons.trending_up_rounded,
            label: 'Betting Tips',
            color: AppTheme.primaryLight,
            onTap: () => context.push('/betting-tips'),
          ),
          _QuickAccessItem(
            icon: Icons.analytics_rounded,
            label: 'My Stats',
            color: AppTheme.accent,
            onTap: () => context.push('/betting-stats'),
          ),
          _QuickAccessItem(
            icon: Icons.bookmark_rounded,
            label: 'Watchlist',
            color: Colors.blue,
            onTap: () => context.push('/watchlist'),
          ),
          _QuickAccessItem(
            icon: Icons.star_rounded,
            label: 'Go VIP',
            color: AppTheme.accent,
            onTap: () => context.push('/vip'),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}