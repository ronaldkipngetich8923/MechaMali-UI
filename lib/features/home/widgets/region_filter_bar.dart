import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/matches_provider.dart';

class RegionFilterBar extends ConsumerWidget {
  const RegionFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedRegionProvider);

    final labels = {
      LeagueRegion.all:           'All',
      LeagueRegion.kenya:         '🇰🇪 Kenya',
      LeagueRegion.africa:        '🌍 Africa',
      LeagueRegion.international: '🌐 World',
    };

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: labels.entries.map((e) {
          final isSelected = selected == e.key;
          return GestureDetector(
            onTap: () => ref.read(selectedRegionProvider.notifier).state = e.key,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(e.value,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
