import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/app/router/app_navigator.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/controllers/ble_controller.dart';
import 'package:neo_sensywall_app/src/features/mode_settings/presentation/controllers/mode_settings_controller.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/domain/entities/sensy_mode.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/presentation/providers/sensy_wall_providers.dart';

final modeSelectionControllerProvider =
    AsyncNotifierProvider<ModeSelectionController, void>(
      ModeSelectionController.new,
    );

class ModeSelectionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> selectMode(SensyMode mode) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(sensyWallRepositoryProvider).selectMode(mode.id);
      ref.read(modeSettingsControllerProvider.notifier).loadMode(mode.id);
      ref.read(appNavigatorProvider).openModeSettings(mode.id);
    });
  }

  void back() => ref.read(appNavigatorProvider).backToHome();

  Future<void> cancelReconnection() async {
    await ref.read(bleControllerProvider.notifier).cancelReconnection();
    ref.read(appNavigatorProvider).backToHome();
  }

  void dismissReconnectDialog() {
    ref.read(bleControllerProvider.notifier).dismissReconnectDialog();
  }
}
