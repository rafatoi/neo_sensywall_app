import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/presentation/providers/sensy_wall_providers.dart';

final developerOptionsControllerProvider =
    NotifierProvider<DeveloperOptionsController, DeveloperOptionsState>(
      DeveloperOptionsController.new,
    );

final class DeveloperOptionsState {
  const DeveloperOptionsState({
    this.tapCount = 0,
    this.isOpen = false,
    this.isBusy = false,
    this.foundCells,
    this.error,
  });

  final int tapCount;
  final bool isOpen;
  final bool isBusy;
  final int? foundCells;
  final Object? error;

  DeveloperOptionsState copyWith({
    int? tapCount,
    bool? isOpen,
    bool? isBusy,
    int? foundCells,
    bool clearFoundCells = false,
    Object? error,
    bool clearError = false,
  }) {
    return DeveloperOptionsState(
      tapCount: tapCount ?? this.tapCount,
      isOpen: isOpen ?? this.isOpen,
      isBusy: isBusy ?? this.isBusy,
      foundCells: clearFoundCells ? null : foundCells ?? this.foundCells,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class DeveloperOptionsController extends Notifier<DeveloperOptionsState> {
  Timer? _resetTimer;

  @override
  DeveloperOptionsState build() {
    ref.onDispose(() => _resetTimer?.cancel());
    return const DeveloperOptionsState();
  }

  void registerTap() {
    if (state.isOpen) return;

    _resetTimer?.cancel();
    final nextCount = state.tapCount + 1;
    if (nextCount >= 10) {
      state = state.copyWith(tapCount: 0, isOpen: true, clearError: true);
      return;
    }

    state = state.copyWith(tapCount: nextCount);
    _resetTimer = Timer(const Duration(seconds: 2), () {
      state = state.copyWith(tapCount: 0);
    });
  }

  void close() {
    _resetTimer?.cancel();
    state = const DeveloperOptionsState();
  }

  Future<void> updateMasterWebServer() =>
      _run(() => ref.read(sensyWallRepositoryProvider).updateMasterWebServer());

  Future<void> updateSensyWallWebServer() => _run(
    () => ref.read(sensyWallRepositoryProvider).updateSensyWallWebServer(),
  );

  Future<void> scanCells() async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final count = await ref.read(sensyWallRepositoryProvider).scanCells();
      state = state.copyWith(isBusy: false, foundCells: count);
    } catch (error) {
      state = state.copyWith(isBusy: false, error: error);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await action();
      state = state.copyWith(isBusy: false);
    } catch (error) {
      state = state.copyWith(isBusy: false, error: error);
    }
  }
}
