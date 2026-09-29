import 'dart:typed_data';

final class SensyWallCommand {
  const SensyWallCommand({
    required this.moduleId,
    required this.parameterId,
    required this.value,
  });

  final int moduleId;
  final int parameterId;
  final int value;

  Uint8List toBytes() {
    final data = ByteData(8)
      ..setInt16(0, moduleId, Endian.big)
      ..setInt16(2, parameterId, Endian.big)
      ..setInt32(4, value, Endian.big);
    return data.buffer.asUint8List();
  }
}

abstract final class SensyWallProtocol {
  static const masterModule = 1;
  static const sensyWallModule = 44;
  static const modeParameter = 2;
  static const colorParameter = 3;
  static const brightnessParameter = 5;
  static const difficultyParameter = 6;
  static const volumeParameter = 47;
  static const stopParameter = 59;
  static const soundEffectsParameter = 65;
  static const areaParameter = 68;
  static const scanCellsParameter = 73;
  static const updateParameter = 9999;
}
