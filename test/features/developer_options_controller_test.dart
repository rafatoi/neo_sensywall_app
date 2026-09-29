import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_sensywall_app/src/features/developer_options/presentation/controllers/developer_options_controller.dart';

void main() {
  test('opens developer options after ten consecutive taps', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(
      developerOptionsControllerProvider.notifier,
    );
    for (var tap = 0; tap < 10; tap++) {
      controller.registerTap();
    }

    final state = container.read(developerOptionsControllerProvider);
    expect(state.isOpen, isTrue);
    expect(state.tapCount, 0);
  });
}
