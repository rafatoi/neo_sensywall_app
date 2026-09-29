import 'package:neo_sensywall_app/src/core/audio/audio_repository.dart';

final class FakeAudioRepository implements AudioRepository {
  int disconnectionPlayCount = 0;
  bool disposed = false;

  @override
  Future<void> playDisconnection() async {
    disconnectionPlayCount++;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}
