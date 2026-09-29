import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_sensywall_app/src/app/app.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/providers/ble_providers.dart';

import 'support/fake_ble_repository.dart';

void main() {
  testWidgets('navigates from home to mode selection', (tester) async {
    final repository = FakeBleRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bleRepositoryProvider.overrideWithValue(repository)],
        child: const SensyWallApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Start'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Available modes'), findsOneWidget);
    expect(find.text('Paint with Colors'), findsOneWidget);
  });
}
