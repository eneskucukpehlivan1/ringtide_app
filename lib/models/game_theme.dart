import 'package:flutter/material.dart';

class GameTheme {
  final String id;
  final String nameTr;
  final String nameEn;
  final int unlockScore;
  final Color bgDark;
  final Color bgLight;
  final Color ringColor;
  final Color glowColor;
  final Color accentColor;
  final String emoji;

  const GameTheme({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.unlockScore,
    required this.bgDark,
    required this.bgLight,
    required this.ringColor,
    required this.glowColor,
    required this.accentColor,
    required this.emoji,
  });
}

const List<GameTheme> kThemes = [
  GameTheme(
    id: 'purple',
    nameTr: 'Neon Mor',
    nameEn: 'Neon Purple',
    unlockScore: 0,
    bgDark: Color(0xFF0D0D1A),
    bgLight: Color(0xFF12101F),
    ringColor: Color(0xFF8B5CF6),
    glowColor: Color(0xFF8B5CF6),
    accentColor: Color(0xFFA78BFA),
    emoji: '💜',
  ),
  GameTheme(
    id: 'ocean',
    nameTr: 'Okyanus',
    nameEn: 'Ocean',
    unlockScore: 2000,
    bgDark: Color(0xFF0A1628),
    bgLight: Color(0xFF0D1F3C),
    ringColor: Color(0xFF06B6D4),
    glowColor: Color(0xFF22D3EE),
    accentColor: Color(0xFF67E8F9),
    emoji: '🌊',
  ),
  GameTheme(
    id: 'inferno',
    nameTr: 'İnferno',
    nameEn: 'Inferno',
    unlockScore: 7500,
    bgDark: Color(0xFF1A0800),
    bgLight: Color(0xFF2D1000),
    ringColor: Color(0xFFF97316),
    glowColor: Color(0xFFFB923C),
    accentColor: Color(0xFFFED7AA),
    emoji: '🔥',
  ),
  GameTheme(
    id: 'void',
    nameTr: 'Boşluk',
    nameEn: 'Void',
    unlockScore: 18000,
    bgDark: Color(0xFF050505),
    bgLight: Color(0xFF0F0F0F),
    ringColor: Color(0xFFE5E7EB),
    glowColor: Color(0xFFD1D5DB),
    accentColor: Color(0xFFF9FAFB),
    emoji: '🌑',
  ),
  GameTheme(
    id: 'matrix',
    nameTr: 'Matris',
    nameEn: 'Matrix',
    unlockScore: 40000,
    bgDark: Color(0xFF001A00),
    bgLight: Color(0xFF002200),
    ringColor: Color(0xFF22C55E),
    glowColor: Color(0xFF4ADE80),
    accentColor: Color(0xFF86EFAC),
    emoji: '💚',
  ),
];
