import 'package:audioplayers/audioplayers.dart';
import 'package:neo_sensywall_app/src/core/audio/audio_repository.dart';

final class AudioplayersAudioRepository implements AudioRepository {
  AudioplayersAudioRepository({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> playDisconnection() async {
    await _player.play(AssetSource('audio/disconnection.mp3'));
  }

  @override
  Future<void> dispose() => _player.dispose();
}
