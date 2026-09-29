import 'package:flutter_test/flutter_test.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/data/repositories/ble_sensy_wall_repository.dart';

import '../../support/fake_ble_repository.dart';

void main() {
  test('encodes volume command for MASTER byte by byte', () async {
    final ble = FakeBleRepository();
    addTearDown(ble.dispose);
    final repository = BleSensyWallRepository(ble);

    await repository.setVolume(20);

    expect(ble.lastCommand, <int>[0, 1, 0, 47, 0, 0, 0, 20]);
  });

  test('parses bsub from deferred JSON response', () async {
    final ble = FakeBleRepository()..response = '{"bsub": 18}';
    addTearDown(ble.dispose);
    final repository = BleSensyWallRepository(ble);

    final count = await repository.scanCells();

    expect(count, 18);
    expect(ble.lastCommand, <int>[0, 44, 0, 73, 0, 0, 0, 1]);
  });
}
