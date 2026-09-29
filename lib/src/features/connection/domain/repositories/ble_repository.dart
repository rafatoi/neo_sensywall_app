import 'dart:typed_data';

import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_device.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_states.dart';

abstract interface class BleRepository {
  Stream<BleAdapterState> get adapterStates;
  Stream<BleConnectionEvent> get connectionEvents;

  Future<BlePermissionState> requestPermissions();
  Future<void> requestEnableAdapter();
  Stream<BleDevice> scan();
  Future<void> stopScan();
  Future<void> connect(BleDevice device);
  Future<void> disconnect();
  Future<int?> readRssi();
  Future<bool> writeCommand(Uint8List value);
  Future<String?> writeAndWait(Uint8List value);
  Future<void> dispose();
}
