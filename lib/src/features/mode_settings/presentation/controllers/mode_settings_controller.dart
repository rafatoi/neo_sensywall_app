import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/app/router/app_navigator.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/presentation/providers/sensy_wall_providers.dart';

final modeSettingsControllerProvider =
    NotifierProvider<ModeSettingsController, ModeSettingsState>(
      ModeSettingsController.new,
    );

final class ModeSettingsState {
  const ModeSettingsState({
    this.modeId = 102,
    this.brightness = 60,
    this.volume = 20,
    this.difficulty = 0,
    this.colorId = 1,
    this.soundEffects = false,
    this.isStopping = false,
  });

  final int modeId;
  final double brightness;
  final double volume;
  final int difficulty;
  final int colorId;
  final bool soundEffects;
  final bool isStopping;

  bool get usesSoundEffects => modeId == 102;

  ModeSettingsState copyWith({
    int? modeId,
    double? brightness,
    double? volume,
    int? difficulty,
    int? colorId,
    bool? soundEffects,
    bool? isStopping,
  }) {
    return ModeSettingsState(
      modeId: modeId ?? this.modeId,
      brightness: brightness ?? this.brightness,
      volume: volume ?? this.volume,
      difficulty: difficulty ?? this.difficulty,
      colorId: colorId ?? this.colorId,
      soundEffects: soundEffects ?? this.soundEffects,
      isStopping: isStopping ?? this.isStopping,
    );
  }
}

class ModeSettingsController extends Notifier<ModeSettingsState> {
  @override
  ModeSettingsState build() => const ModeSettingsState();

  void loadMode(int modeId) {
    if (state.modeId != modeId) state = state.copyWith(modeId: modeId);
  }

  void changeBrightness(double value) {
    state = state.copyWith(brightness: value);
  }

  Future<void> commitBrightness() => ref
      .read(sensyWallRepositoryProvider)
      .setBrightness(state.brightness.round());

  void changeVolume(double value) {
    state = state.copyWith(volume: value);
  }

  Future<void> commitVolume() => ref
      .read(sensyWallRepositoryProvider)
      .setVolume((state.volume / 5).round());

  Future<void> selectColor(int colorId) async {
    state = state.copyWith(colorId: colorId);
    await ref.read(sensyWallRepositoryProvider).setColor(colorId);
  }

  Future<void> toggleSoundEffects() async {
    final enabled = !state.soundEffects;
    state = state.copyWith(soundEffects: enabled);
    await ref.read(sensyWallRepositoryProvider).setSoundEffects(enabled);
  }

  Future<void> increaseDifficulty() async {
    if (state.difficulty >= 3) return;
    final value = state.difficulty + 1;
    state = state.copyWith(difficulty: value);
    await ref.read(sensyWallRepositoryProvider).setDifficulty(value);
  }

  Future<void> decreaseDifficulty() async {
    if (state.difficulty <= 0) return;
    final value = state.difficulty - 1;
    state = state.copyWith(difficulty: value);
    await ref.read(sensyWallRepositoryProvider).setDifficulty(value);
  }

  Future<void> leave() async {
    if (state.isStopping) return;
    state = state.copyWith(isStopping: true);
    try {
      await ref.read(sensyWallRepositoryProvider).stopAll();
      ref.read(appNavigatorProvider).backToModes();
    } finally {
      state = state.copyWith(isStopping: false);
    }
  }
}
