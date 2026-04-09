class BadgeDefinition {
  final String id;
  final String nameTr;
  final String nameEn;
  final String descTr;
  final String descEn;
  final String icon;

  const BadgeDefinition({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.descTr,
    required this.descEn,
    required this.icon,
  });
}

const List<BadgeDefinition> kBadges = [
  BadgeDefinition(
    id: 'first_tap',
    nameTr: 'İlk Adım',
    nameEn: 'First Tap',
    descTr: 'İlk oyunu tamamla',
    descEn: 'Complete your first game',
    icon: '👆',
  ),
  BadgeDefinition(
    id: 'century',
    nameTr: 'Yüzlük',
    nameEn: 'Century',
    descTr: 'Tek oyunda 100 puan',
    descEn: 'Score 100 in one game',
    icon: '💯',
  ),
  BadgeDefinition(
    id: 'sharp_eye',
    nameTr: 'Keskin Göz',
    nameEn: 'Sharp Eye',
    descTr: '5 art arda mükemmel',
    descEn: '5 perfect taps in a row',
    icon: '🎯',
  ),
  BadgeDefinition(
    id: 'speed_demon',
    nameTr: 'Hız Şeytanı',
    nameEn: 'Speed Demon',
    descTr: 'Level 30\'a ulaş',
    descEn: 'Reach level 30',
    icon: '⚡',
  ),
  BadgeDefinition(
    id: 'legend',
    nameTr: 'Efsane',
    nameEn: 'Legend',
    descTr: '50.000 toplam puan',
    descEn: 'Accumulate 50,000 total points',
    icon: '👑',
  ),
];
