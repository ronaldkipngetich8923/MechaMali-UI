// lib/features/home/widgets/betting_insight_card.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechamali/core/models/match_model.dart';

import 'package:mechamali/core/models/match_model.dart';
import 'package:mechamali/core/theme/app_theme.dart';

class BettingInsightCard extends StatelessWidget {
  late final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Existing match info...

          // Betting-specific insights
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: AppTheme.accent, size: 16),
                    SizedBox(width: 8),
                    Text('Betting Tips',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TipChip('Over 1.5', '1.32', true),
                    _TipChip('BTTS', '1.85', false),
                    _TipChip('GG', '2.10', false),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TipChip('Correct Score', '5.50', false),
                    _TipChip('Half-time Draw', '2.20', true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  final String label;
  final String odds;
  final bool isHotTip;

  const _TipChip(this.label, this.odds, this.isHotTip);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHotTip ? AppTheme.accent.withOpacity(0.15) : AppTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: isHotTip ? Border.all(color: AppTheme.accent) : null,
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          Text(odds,
              style: TextStyle(
                color: isHotTip ? AppTheme.accent : AppTheme.primaryLight,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              )),
        ],
      ),
    );
  }
}