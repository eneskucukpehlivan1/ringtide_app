import 'package:flutter/material.dart';
import '../game/ringtide_game.dart';
import '../models/game_theme.dart';
import '../services/progression_service.dart';
import '../utils/app_strings.dart';

class ThemeSelectOverlay extends StatefulWidget {
  final RingtideGame game;
  const ThemeSelectOverlay({super.key, required this.game});

  @override
  State<ThemeSelectOverlay> createState() => _ThemeSelectOverlayState();
}

class _ThemeSelectOverlayState extends State<ThemeSelectOverlay> {
  @override
  Widget build(BuildContext context) {
    final ps = ProgressionService.instance;
    final activeTheme = ps.activeTheme;

    return Scaffold(
      backgroundColor: activeTheme.bgDark.withValues(alpha: 0.95),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.game.overlays.remove('ThemeSelect');
                      widget.game.overlays.add('MainMenu');
                    },
                    child: Icon(Icons.arrow_back_ios_new, color: activeTheme.accentColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    S.themes,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: activeTheme.accentColor,
                        letterSpacing: 4),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Text(
                S.totalScore(ps.totalScore),
                style: TextStyle(fontSize: 13, color: activeTheme.accentColor.withValues(alpha: 0.6), letterSpacing: 1.5),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: kThemes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final t = kThemes[i];
                  final unlocked = ps.unlockedThemes.contains(t.id);
                  final isActive = ps.activeThemeId == t.id;
                  return _ThemeCard(
                    theme: t,
                    unlocked: unlocked,
                    isActive: isActive,
                    onTap: unlocked
                        ? () async {
                            await ps.setActiveTheme(t.id);
                            setState(() {});
                          }
                        : null,
                  );
                },
              ),
            ),
            // Sound / Haptics toggles
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 70),
              child: Row(
                children: [
                  Expanded(child: _Toggle(
                    label: S.sound,
                    value: ps.soundEnabled,
                    color: activeTheme.accentColor,
                    borderColor: activeTheme.ringColor,
                    onChanged: (v) async {
                      await ps.setSoundEnabled(v);
                      setState(() {});
                    },
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _Toggle(
                    label: S.haptics,
                    value: ps.hapticsEnabled,
                    color: activeTheme.accentColor,
                    borderColor: activeTheme.ringColor,
                    onChanged: (v) async {
                      await ps.setHapticsEnabled(v);
                      setState(() {});
                    },
                  )),
                ],
              ),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final GameTheme theme;
  final bool unlocked;
  final bool isActive;
  final VoidCallback? onTap;

  const _ThemeCard({
    required this.theme,
    required this.unlocked,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final name = locale.languageCode == 'tr' ? theme.nameTr : theme.nameEn;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? theme.ringColor
                : (unlocked ? theme.ringColor.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.1)),
            width: isActive ? 2 : 1,
          ),
          color: isActive
              ? theme.ringColor.withValues(alpha: 0.15)
              : (unlocked ? theme.bgLight.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.04)),
          boxShadow: isActive
              ? [BoxShadow(color: theme.glowColor.withValues(alpha: 0.3), blurRadius: 20)]
              : [],
        ),
        child: Row(
          children: [
            Text(theme.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: unlocked ? theme.accentColor : Colors.white.withValues(alpha: 0.4))),
                  if (!unlocked)
                    Text('${theme.unlockScore} ${S.points}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3), letterSpacing: 1)),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.ringColor.withValues(alpha: 0.25),
                ),
                child: Text(S.unlocked,
                    style: TextStyle(fontSize: 11, color: theme.accentColor, fontWeight: FontWeight.w700, letterSpacing: 1)),
              )
            else if (!unlocked)
              Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.25), size: 18),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final Color color;
  final Color borderColor;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.label,
    required this.value,
    required this.color,
    required this.borderColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor.withValues(alpha: value ? 0.7 : 0.25), width: 1),
          color: color.withValues(alpha: value ? 0.12 : 0.04),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: color.withValues(alpha: value ? 1 : 0.4),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2)),
            Icon(value ? Icons.toggle_on : Icons.toggle_off,
                color: color.withValues(alpha: value ? 1 : 0.3), size: 28),
          ],
        ),
      ),
    );
  }
}
