import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/match_model.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onTap;

  const MatchCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: match.isLive
              ? Border.all(color: AppTheme.danger.withOpacity(0.4), width: 1)
              : null,
        ),
        child: Column(
          children: [
            // League + time row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(match.league, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                _StatusBadge(match: match),
              ],
            ),
            const SizedBox(height: 12),
            // Teams row
            Row(
              children: [
                Expanded(child: _TeamCell(name: match.homeTeam, logoUrl: match.homeTeamLogo, align: CrossAxisAlignment.start)),
                _ScoreCell(match: match),
                Expanded(child: _TeamCell(name: match.awayTeam, logoUrl: match.awayTeamLogo, align: CrossAxisAlignment.end)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MatchModel match;
  const _StatusBadge({required this.match});

  @override
  Widget build(BuildContext context) {
    if (match.isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(match.minute != null ? "${match.minute}'" : 'LIVE',
                style: const TextStyle(color: AppTheme.danger, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }
    if (match.isFinished) {
      return const Text('FT', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11));
    }
    return Text(
      DateFormat('HH:mm').format(match.kickOff.toLocal()),
      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
    );
  }
}

class _TeamCell extends StatelessWidget {
  final String name;
  final String logoUrl;
  final CrossAxisAlignment align;
  const _TeamCell({required this.name, required this.logoUrl, required this.align});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.surface,
          backgroundImage: logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
          child: logoUrl.isEmpty ? const Icon(Icons.sports_soccer, color: AppTheme.textSecondary, size: 16) : null,
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: align == CrossAxisAlignment.start ? TextAlign.left : TextAlign.right,
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _ScoreCell extends StatelessWidget {
  final MatchModel match;
  const _ScoreCell({required this.match});

  @override
  Widget build(BuildContext context) {
    final showScore = match.isLive || match.isFinished;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: showScore
          ? Text('${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))
          : const Text('vs', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
    );
  }
}
