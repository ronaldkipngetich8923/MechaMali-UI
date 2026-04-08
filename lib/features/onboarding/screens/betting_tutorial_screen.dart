// lib/features/onboarding/screens/betting_tutorial_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class BettingTutorialScreen extends StatelessWidget {
  const BettingTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('How to Use Betting Tips'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const TutorialCard(
                  step: '1',
                  icon: Icons.trending_up,
                  title: 'Check Match Insights',
                  description: 'View AI predictions and betting tips for each match, including win probabilities and form analysis.',
                ),
                const SizedBox(height: 16),
                const TutorialCard(
                  step: '2',
                  icon: Icons.add_chart,
                  title: 'Analyze Team Form',
                  description: 'Study head-to-head statistics, recent form, and key player information before betting.',
                ),
                const SizedBox(height: 16),
                const TutorialCard(
                  step: '3',
                  icon: Icons.star_rounded,
                  title: 'Get VIP Predictions',
                  description: 'Upgrade to VIP for detailed AI analysis, exact score predictions, and premium betting tips.',
                ),
                const SizedBox(height: 16),
                const TutorialCard(
                  step: '4',
                  icon: Icons.notifications_active,
                  title: 'Enable Notifications',
                  description: 'Get real-time alerts for match starts, goals, and betting opportunities.',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Got it!'),
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialCard extends StatelessWidget {
  final String step;
  final IconData icon;
  final String title;
  final String description;

  const TutorialCard({
    super.key,
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryLight, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Step $step',
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}