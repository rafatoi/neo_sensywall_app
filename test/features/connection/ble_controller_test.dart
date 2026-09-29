import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_device.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_states.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/controllers/ble_controller.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/providers/ble_providers.dart';

import '../../support/fake_ble_repository.dart';

void main() {
  test('deduplicates scan results and auto-connects to Sensy Wall', () async {
    final repository = FakeBleRepository();
    final container = ProviderContainer(
      overrides: [
        bleRepositoryProvider.overrideWithValue(repository),
        bleAutoConnectDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(repository.dispose);

    final controller = container.read(bleControllerProvider.notifier);
    await controller.initialize();
    repository.adapterController.add(BleAdapterState.ready);
    await Future<void>.delayed(Duration.zero);

    repository.scanController.add(
      const BleDevice(id: 'device-1', name: 'Altavoz', rssi: -82),
    );
    repository.scanController.add(
      const BleDevice(id: 'device-1', name: 'Altavoz', rssi: -55),
    );
    repository.scanController.add(
      const BleDevice(id: 'device-2', name: 'SENSY_WALL_TEST', rssi: -67),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(bleControllerProvider);
    expect(state.devices, hasLength(2));
    expect(state.devices.first.rssi, -55);
    expect(repository.connectedDevice?.id, 'device-2');
    expect(state.phase, BleConnectionPhase.connecting);
  });

  test('does not scan when Bluetooth permission is denied', () async {
    final repository = FakeBleRepository()
      ..permissionResult = BlePermissionState.denied;
    final container = ProviderContainer(
      overrides: [bleRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    addTearDown(repository.dispose);

    final controller = container.read(bleControllerProvider.notifier);
    await controller.initialize();
    repository.adapterController.add(BleAdapterState.ready);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(bleControllerProvider);
    expect(state.permission, BlePermissionState.denied);
    expect(state.phase, BleConnectionPhase.disconnected);
  });

  test(
    'makes exactly one reconnect attempt after an unexpected loss',
    () async {
      final repository = FakeBleRepository();
      final container = ProviderContainer(
        overrides: [bleRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      final controller = container.read(bleControllerProvider.notifier);
      await controller.initialize();
      const device = BleDevice(
        id: 'device-1',
        name: 'SENSY_WALL_TEST',
        rssi: -65,
      );
      await controller.connect(device);
      repository.connectionController.add(
        const BleConnectionEvent(
          deviceId: 'device-1',
          type: BleConnectionEventType.connected,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      repository.connectionController.add(
        const BleConnectionEvent(
          deviceId: 'device-1',
          type: BleConnectionEventType.disconnected,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final state = container.read(bleControllerProvider);
      expect(repository.connectCalls, 2);
      expect(state.phase, BleConnectionPhase.reconnecting);
      expect(state.showReconnectDialog, isTrue);
    },
  );

  test('disconnects in background and reconnects once in foreground', () async {
    final repository = FakeBleRepository();
    final container = ProviderContainer(
      overrides: [bleRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    addTearDown(repository.dispose);

    final controller = container.read(bleControllerProvider.notifier);
    await controller.initialize();
    const device = BleDevice(
      id: 'device-1',
      name: 'SENSY_WALL_TEST',
      rssi: -65,
    );
    await controller.connect(device);
    repository.connectionController.add(
      const BleConnectionEvent(
        deviceId: 'device-1',
        type: BleConnectionEventType.connected,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    await controller.onAppBackground();
    expect(
      container.read(bleControllerProvider).phase,
      BleConnectionPhase.disconnected,
    );
    await controller.onAppForeground();

    expect(repository.connectCalls, 2);
    expect(
      container.read(bleControllerProvider).phase,
      BleConnectionPhase.reconnecting,
    );
  });
}
