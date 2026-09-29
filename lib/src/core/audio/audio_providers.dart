import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/core/audio/audio_repository.dart';
import 'package:neo_sensywall_app/src/core/audio/audioplayers_audio_repository.dart';

final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  final repository = AudioplayersAudioRepository();
  ref.onDispose(() => unawaited(repository.dispose()));
  return repository;
});
