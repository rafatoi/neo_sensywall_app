import 'package:flutter_test/flutter_test.dart';
import 'package:neo_sensywall_app/src/core/protocol/sensy_wall_command.dart';

void main() {
  test('serializes commands to the Kotlin-compatible 8-byte payload', () {
    const command = SensyWallCommand(
      moduleId: SensyWallProtocol.sensyWallModule,
      parameterId: SensyWallProtocol.modeParameter,
      value: 102,
    );

    expect(
      command.toBytes(),
      orderedEquals(<int>[0x00, 0x2C, 0x00, 0x02, 0x00, 0x00, 0x00, 0x66]),
    );
  });
}
