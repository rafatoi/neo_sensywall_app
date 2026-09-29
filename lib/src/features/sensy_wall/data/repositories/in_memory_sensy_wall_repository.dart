import 'package:neo_sensywall_app/src/core/protocol/sensy_wall_command.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/domain/repositories/sensy_wall_repository.dart';

final class InMemorySensyWallRepository implements SensyWallRepository {
  SensyWallCommand? lastCommand;

  Future<void> _record(int moduleId, int parameterId, int value) async {
    lastCommand = SensyWallCommand(
      moduleId: moduleId,
      parameterId: parameterId,
      value: value,
    );
  }

  @override
  Future<void> selectMode(int modeId) => _record(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.modeParameter,
    modeId,
  );

  @override
  Future<void> setColor(int colorId) => _record(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.colorParameter,
    colorId,
  );

  @override
  Future<void> setBrightness(int value) => _record(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.brightnessParameter,
    value,
  );

  @override
  Future<void> setVolume(int value) => _record(
    SensyWallProtocol.masterModule,
    SensyWallProtocol.volumeParameter,
    value,
  );

  @override
  Future<void> setDifficulty(int value) => _record(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.difficultyParameter,
    value,
  );

  @override
  Future<void> setSoundEffects(bool enabled) => _record(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.soundEffectsParameter,
    enabled ? 1 : 0,
  );

  @override
  Future<void> setArea(int value) => _record(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.areaParameter,
    value,
  );

  @override
  Future<void> stopAll() => _record(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.stopParameter,
    1,
  );

  @override
  Future<void> updateMasterWebServer() => _record(
    SensyWallProtocol.masterModule,
    SensyWallProtocol.updateParameter,
    1,
  );

  @override
  Future<void> updateSensyWallWebServer() => _record(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.updateParameter,
    1,
  );

  @override
  Future<int> scanCells() async {
    await _record(
      SensyWallProtocol.sensyWallModule,
      SensyWallProtocol.scanCellsParameter,
      1,
    );
    return 0;
  }
}
