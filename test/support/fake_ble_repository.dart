import 'dart:async';
import 'dart:typed_data';

import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_device.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_states.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/repositories/ble_repository.dart';

final class FakeBleRepository implements BleRepository {
  final adapterController = StreamController<BleAdapterState>.broadcast();
  final connectionController = StreamController<BleConnectionEvent>.broadcast();
  final scanController = StreamController<BleDevice>.broadcast();

  BlePermissionState permissionResult = BlePermissionState.granted;
  BleDevice? connectedDevice;
  Uint8List? lastCommand;
  String? response;
  int? rssi;
  bool enableAdapterRequested = false;
  bool scanStopped = false;
  int connectCalls = 0;

  @override
  Stream<BleAdapterState> get adapterStates => adapterController.stream;

  @override
  Stream<BleConnectionEvent> get connectionEvents =>
      connectionController.stream;

  @override
  Future<BlePermissionState> requestPermissions() async => permissionResult;

  @override
  Future<void> requestEnableAdapter() async {
    enableAdapterRequested = true;
  }

  @override
  Stream<BleDevice> scan() => scanController.stream;

  @override
  Future<void> stopScan() async {
    scanStopped = true;
  }

  @override
  Future<void> connect(BleDevice device) async {
    connectCalls++;
    connectedDevice = device;
  }

  @override
  Future<void> disconnect() async {
    connectedDevice = null;
  }

  @override
  Future<int?> readRssi() async => rssi;

  @override
  Future<bool> writeCommand(Uint8List value) async {
    lastCommand = value;
    return connectedDevice != null;
  }

  @override
  Future<String?> writeAndWait(Uint8List value) async {
    lastCommand = value;
    return response;
  }

  @override
  Future<void> dispose() async {
    await adapterController.close();
    await connectionController.close();
    await scanController.close();
  }
}
