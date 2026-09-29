import 'package:neo_sensywall_app/src/features/sensy_wall/domain/entities/sensy_color_choice.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

extension SensyColorLocalizations on SensyColorChoice {
  String name(AppLocalizations l10n) => switch (localizationKey) {
    'red' => l10n.red,
    'green' => l10n.green,
    'blue' => l10n.blue,
    'yellow' => l10n.yellow,
    'purple' => l10n.purple,
    'white' => l10n.white,
    'orange' => l10n.orange,
    'cyan' => l10n.cyan,
    'pink' => l10n.pink,
    'multicolor' => l10n.multicolor,
    _ => localizationKey,
  };
}
