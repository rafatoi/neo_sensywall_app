import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_sensywall_app/src/core/audio/audio_providers.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_device.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_states.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/widgets/reconnection_dialog.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/providers/ble_providers.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

import '../../support/fake_audio_repository.dart';
import '../../support/fake_ble_repository.dart';

void main() {
  testWidgets('dispatches cancel while reconnecting', (tester) async {
    final repository = FakeBleRepository();
    addTearDown(repository.dispose);
    var cancelled = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bleRepositoryProvider.overrideWithValue(repository),
          audioRepositoryProvider.overrideWithValue(FakeAudioRepository()),
        ],
        child: _TestApp(
          child: ReconnectionDialog(
            session: const BleSessionState(
              phase: BleConnectionPhase.reconnecting,
              connectedDevice: BleDevice(
                id: 'test-device',
                name: 'SENSY_WALL_TEST',
                rssi: -70,
              ),
              showReconnectDialog: true,
            ),
            onCancel: () => cancelled = true,
            onDismiss: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Connection lost'), findsOneWidget);
    expect(find.text('Cancel reconnection'), findsOneWidget);

    await tester.tap(find.text('Cancel reconnection'));
    expect(cancelled, isTrue);
  });

  testWidgets('renders the restored state', (tester) async {
    final repository = FakeBleRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bleRepositoryProvider.overrideWithValue(repository),
          audioRepositoryProvider.overrideWithValue(FakeAudioRepository()),
        ],
        child: _TestApp(
          child: ReconnectionDialog(
            session: const BleSessionState(
              phase: BleConnectionPhase.connected,
              connectedDevice: BleDevice(
                id: 'test-device',
                name: 'SENSY_WALL_TEST',
                rssi: -62,
              ),
              showReconnectDialog: true,
            ),
            onCancel: () {},
            onDismiss: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Connection restored'), findsNWidgets(2));
    expect(
      find.text('You can continue, but please don’t move too far away.'),
      findsOneWidget,
    );
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }
}
