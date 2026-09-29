import 'dart:convert';

import 'package:neo_sensywall_app/src/core/protocol/sensy_wall_command.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/repositories/ble_repository.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/domain/repositories/sensy_wall_repository.dart';

final class BleSensyWallRepository implements SensyWallRepository {
  const BleSensyWallRepository(this._bleRepository);

  final BleRepository _bleRepository;

  Future<void> _send(int moduleId, int parameterId, int value) async {
    final command = SensyWallCommand(
      moduleId: moduleId,
      parameterId: parameterId,
      value: value,
    );
    await _bleRepository.writeCommand(command.toBytes());
  }

  @override
  Future<void> selectMode(int modeId) => _send(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.modeParameter,
    modeId,
  );

  @override
  Future<void> setColor(int colorId) => _send(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.colorParameter,
    colorId,
  );

  @override
  Future<void> setBrightness(int value) => _send(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.brightnessParameter,
    value,
  );

  @override
  Future<void> setVolume(int value) => _send(
    SensyWallProtocol.masterModule,
    SensyWallProtocol.volumeParameter,
    value,
  );

  @override
  Future<void> setDifficulty(int value) => _send(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.difficultyParameter,
    value,
  );

  @override
  Future<void> setSoundEffects(bool enabled) => _send(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.soundEffectsParameter,
    enabled ? 1 : 0,
  );

  @override
  Future<void> setArea(int value) => _send(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.areaParameter,
    value,
  );

  @override
  Future<void> stopAll() => _send(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.stopParameter,
    1,
  );

  @override
  Future<void> updateMasterWebServer() => _send(
    SensyWallProtocol.masterModule,
    SensyWallProtocol.updateParameter,
    1,
  );

  @override
  Future<void> updateSensyWallWebServer() => _send(
    SensyWallProtocol.sensyWallModule,
    SensyWallProtocol.updateParameter,
    1,
  );

  @override
  Future<int> scanCells() async {
    final command = SensyWallCommand(
      moduleId: SensyWallProtocol.sensyWallModule,
      parameterId: SensyWallProtocol.scanCellsParameter,
      value: 1,
    );
    final response = await _bleRepository.writeAndWait(command.toBytes());
    if (response == null) return 0;
    final decoded = jsonDecode(response);
    if (decoded case {'bsub': final int count}) return count;
    return 0;
  }
}
