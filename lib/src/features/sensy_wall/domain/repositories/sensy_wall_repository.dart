abstract interface class SensyWallRepository {
  Future<void> selectMode(int modeId);
  Future<void> setColor(int colorId);
  Future<void> setBrightness(int value);
  Future<void> setVolume(int value);
  Future<void> setDifficulty(int value);
  Future<void> setSoundEffects(bool enabled);
  Future<void> setArea(int value);
  Future<void> stopAll();
  Future<void> updateMasterWebServer();
  Future<void> updateSensyWallWebServer();
  Future<int> scanCells();
}
