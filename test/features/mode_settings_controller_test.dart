import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_sensywall_app/src/core/protocol/sensy_wall_command.dart';
import 'package:neo_sensywall_app/src/features/mode_settings/presentation/controllers/mode_settings_controller.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/data/repositories/in_memory_sensy_wall_repository.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/presentation/providers/sensy_wall_providers.dart';

void main() {
  test(
    'area selector state and command stay in the Riverpod controller',
    () async {
      final repository = InMemorySensyWallRepository();
      final container = ProviderContainer(
        overrides: [sensyWallRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        modeSettingsControllerProvider.notifier,
      );

      controller.openAreaSelector();
      expect(
        container.read(modeSettingsControllerProvider).showAreaSelector,
        isTrue,
      );

      await controller.selectArea(2);

      expect(container.read(modeSettingsControllerProvider).areaId, 2);
      expect(
        repository.lastCommand?.moduleId,
        SensyWallProtocol.sensyWallModule,
      );
      expect(
        repository.lastCommand?.parameterId,
        SensyWallProtocol.areaParameter,
      );
      expect(repository.lastCommand?.value, 2);

      controller.closeAreaSelector();
      expect(
        container.read(modeSettingsControllerProvider).showAreaSelector,
        isFalse,
      );
    },
  );
}
