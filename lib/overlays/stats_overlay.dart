import 'package:flutter/material.dart';
import '../game/ringtide_game.dart';
import '../models/badge_definition.dart';
import '../services/progression_service.dart';
import '../utils/app_strings.dart';

class StatsOverlay extends StatelessWidget {
  final RingtideGame game;
  const StatsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final ps = ProgressionService.instance;
    final theme = ps.activeTheme;

    return Scaffold(
      backgroundColor: theme.bgDark.withValues(alpha: 0.95),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      game.overlays.remove('StatsOverlay');
                      game.overlays.add('MainMenu');
                    },
                    child: Icon(Icons.arrow_back_ios_new, color: theme.accentColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(S.stats,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: theme.accentColor,
                          letterSpacing: 4)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _statsGrid(ps, theme),
                    const SizedBox(height: 24),
                    // Badges section
                    Text(S.newBadge,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: theme.accentColor.withValues(alpha: 0.7),
                            letterSpacing: 3)),
                    const SizedBox(height: 12),
                    _badgesSection(ps, theme),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsGrid(ProgressionService ps, dynamic theme) {
    final items = [
      (S.statsTotalGames, '${ps.totalGames}'),
      (S.statsTotalTaps, '${ps.totalTaps}'),
      (S.statsBestCombo, '${ps.bestComboEver}'),
      (S.statsTotalScore, '${ps.totalScore}'),
      (S.statsLongestStreak, '${ps.longestStreak} 🔥'),
      (S.weeklyBest, '${ps.weeklyBest}'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final (label, value) = items[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (theme.ringColor as Color).withValues(alpha: 0.25)),
            color: (theme.ringColor as Color).withValues(alpha: 0.08),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: (theme.accentColor as Color).withValues(alpha: 0.6),
                      letterSpacing: 1.5)),
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: theme.accentColor as Color)),
            ],
          ),
        );
      },
    );
  }

  Widget _badgesSection(ProgressionService ps, dynamic theme) {
    final isTr = S.isTr == 'tr';
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: kBadges.map((b) {
        final earned = ps.earnedBadges.contains(b.id);
        final badgeName = isTr ? b.nameTr : b.nameEn;
        final badgeDesc = isTr ? b.descTr : b.descEn;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: earned
                  ? (theme.ringColor as Color).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.1),
            ),
            color: earned
                ? (theme.ringColor as Color).withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.03),
          ),
          child: Row(
            children: [
              Text(_badgeEmoji(b.id),
                  style: TextStyle(fontSize: 24, color: earned ? null : const Color(0x40FFFFFF))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(badgeName,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: earned
                                ? (theme.accentColor as Color)
                                : Colors.white.withValues(alpha: 0.3))),
                    Text(badgeDesc,
                        style: TextStyle(
                            fontSize: 12,
                            color: earned
                                ? (theme.accentColor as Color).withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.2))),
                  ],
                ),
              ),
              if (earned) Icon(Icons.check_circle_outline, color: theme.accentColor as Color, size: 20),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _badgeEmoji(String id) {
    switch (id) {
      case 'first_tap': return '👆';
      case 'century': return '💯';
      case 'sharp_eye': return '🎯';
      case 'speed_demon': return '⚡';
      case 'legend': return '🏆';
      default: return '🏅';
    }
  }
}
