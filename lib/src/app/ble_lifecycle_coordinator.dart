import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/controllers/ble_controller.dart';

final bleLifecycleCoordinatorProvider = Provider<void>((ref) {
  AppLifecycleState? previousState;
  final listener = AppLifecycleListener(
    onStateChange: (state) {
      if (state == previousState) return;
      previousState = state;
      final controller = ref.read(bleControllerProvider.notifier);
      switch (state) {
        case AppLifecycleState.resumed:
          controller.onAppForeground();
        case AppLifecycleState.inactive:
        case AppLifecycleState.hidden:
        case AppLifecycleState.paused:
        case AppLifecycleState.detached:
          controller.onAppBackground();
      }
    },
  );
  ref.onDispose(listener.dispose);
});
