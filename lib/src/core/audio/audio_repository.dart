abstract interface class AudioRepository {
  Future<void> playDisconnection();

  Future<void> dispose();
}
