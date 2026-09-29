import 'package:neo_sensywall_app/src/features/sensy_wall/domain/entities/sensy_mode.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

extension SensyModeLocalizations on SensyMode {
  String title(AppLocalizations l10n) => switch (kind) {
    SensyModeKind.paint => l10n.paintMode,
    SensyModeKind.catchColor => l10n.catchColorMode,
    SensyModeKind.memory => l10n.memoryMode,
    SensyModeKind.reaction => l10n.reactionMode,
  };

  String description(AppLocalizations l10n) => switch (kind) {
    SensyModeKind.paint => l10n.paintModeDescription,
    SensyModeKind.catchColor => l10n.catchColorModeDescription,
    SensyModeKind.memory => l10n.memoryModeDescription,
    SensyModeKind.reaction => l10n.reactionModeDescription,
  };
}
