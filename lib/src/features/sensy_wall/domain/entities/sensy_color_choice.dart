final class SensyColorChoice {
  const SensyColorChoice({
    required this.id,
    required this.argb,
    required this.localizationKey,
    this.isMulticolor = false,
  });

  final int id;
  final int argb;
  final String localizationKey;
  final bool isMulticolor;
}

const sensyColors = <SensyColorChoice>[
  SensyColorChoice(id: 1, argb: 0xFFFF1100, localizationKey: 'red'),
  SensyColorChoice(id: 2, argb: 0xFF008000, localizationKey: 'green'),
  SensyColorChoice(id: 3, argb: 0xFF007BFF, localizationKey: 'blue'),
  SensyColorChoice(id: 4, argb: 0xFFFFD700, localizationKey: 'yellow'),
  SensyColorChoice(id: 5, argb: 0xFF9C27B0, localizationKey: 'purple'),
  SensyColorChoice(id: 6, argb: 0xFFFFFFFF, localizationKey: 'white'),
  SensyColorChoice(id: 7, argb: 0xFFFF5722, localizationKey: 'orange'),
  SensyColorChoice(id: 8, argb: 0xFF00BCD4, localizationKey: 'cyan'),
  SensyColorChoice(id: 9, argb: 0xFFFF1D5E, localizationKey: 'pink'),
  SensyColorChoice(
    id: 99,
    argb: 0xFF00BCD4,
    localizationKey: 'multicolor',
    isMulticolor: true,
  ),
];
