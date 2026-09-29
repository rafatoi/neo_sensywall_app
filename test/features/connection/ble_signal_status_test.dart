import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_sensywall_app/src/core/audio/audio_providers.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_device.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_states.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/controllers/ble_controller.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/controllers/rssi_tooltip_controller.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/providers/ble_providers.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/widgets/ble_signal_status.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

import '../../support/fake_audio_repository.dart';
import '../../support/fake_ble_repository.dart';

void main() {
  testWidgets('shows RSSI copy and closes it after three-second state', (
    tester,
  ) async {
    final repository = FakeBleRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bleRepositoryProvider.overrideWithValue(repository),
          audioRepositoryProvider.overrideWithValue(FakeAudioRepository()),
          rssiTooltipDurationProvider.overrideWithValue(
            const Duration(seconds: 1),
          ),
        ],
        child: const _TestApp(),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(BleSignalStatus)),
    );

    final controller = container.read(bleControllerProvider.notifier);
    await controller.initialize();
    const device = BleDevice(
      id: 'test-device',
      name: 'SENSY_WALL_TEST',
      rssi: -65,
    );
    await controller.connect(device);
    repository.connectionController.add(
      const BleConnectionEvent(
        deviceId: 'test-device',
        type: BleConnectionEventType.connected,
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Signal status'), findsOneWidget);
    expect(find.textContaining('Excellent connection'), findsNothing);

    await tester.tap(find.byType(InkResponse));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(container.read(rssiTooltipControllerProvider), isTrue);
    expect(find.textContaining('Excellent connection'), findsOneWidget);
    expect(find.textContaining('-65 dBm'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump(const Duration(milliseconds: 200));

    expect(container.read(rssiTooltipControllerProvider), isFalse);
    expect(find.textContaining('Excellent connection'), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: Align(alignment: Alignment.bottomRight, child: BleSignalStatus()),
      ),
    );
  }
}
