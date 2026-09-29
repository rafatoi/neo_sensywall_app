import 'dart:typed_data';

import 'package:neo_sensywall_app/src/features/connection/data/data_sources/ble_permission_data_source.dart';
import 'package:neo_sensywall_app/src/features/connection/data/data_sources/platform_ble_data_source.dart';
import 'package:neo_sensywall_app/src/features/connection/data/data_sources/reactive_ble_data_source.dart';
import 'package:neo_sensywall_app/src/features/connection/data/dto/ble_dto.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_device.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_states.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/repositories/ble_repository.dart';

final class ReactiveBleRepository implements BleRepository {
  const ReactiveBleRepository({
    required BleDataSource dataSource,
    required BlePermissionDataSource permissionDataSource,
    required PlatformBleDataSource platformDataSource,
  }) : this._(dataSource, permissionDataSource, platformDataSource);

  const ReactiveBleRepository._(
    this._dataSource,
    this._permissionDataSource,
    this._platformDataSource,
  );

  final BleDataSource _dataSource;
  final BlePermissionDataSource _permissionDataSource;
  final PlatformBleDataSource _platformDataSource;

  @override
  Stream<BleAdapterState> get adapterStates => _dataSource.adapterStates.map(
    (state) => switch (state) {
      BleAdapterDto.unknown => BleAdapterState.unknown,
      BleAdapterDto.unsupported => BleAdapterState.unsupported,
      BleAdapterDto.unauthorized => BleAdapterState.unauthorized,
      BleAdapterDto.poweredOff => BleAdapterState.poweredOff,
      BleAdapterDto.locationServicesDisabled =>
        BleAdapterState.locationServicesDisabled,
      BleAdapterDto.ready => BleAdapterState.ready,
    },
  );

  @override
  Stream<BleConnectionEvent> get connectionEvents =>
      _dataSource.connectionEvents.map(
        (event) => BleConnectionEvent(
          deviceId: event.deviceId,
          type: switch (event.type) {
            BleConnectionDtoType.connecting =>
              BleConnectionEventType.connecting,
            BleConnectionDtoType.connected => BleConnectionEventType.connected,
            BleConnectionDtoType.disconnecting =>
              BleConnectionEventType.disconnecting,
            BleConnectionDtoType.disconnected =>
              BleConnectionEventType.disconnected,
          },
        ),
      );

  @override
  Future<BlePermissionState> requestPermissions() async {
    final sdk = await _platformDataSource.androidSdkInt();
    final result = await _permissionDataSource.request(androidSdkInt: sdk);
    return switch (result) {
      BlePermissionDto.granted => BlePermissionState.granted,
      BlePermissionDto.denied => BlePermissionState.denied,
      BlePermissionDto.permanentlyDenied =>
        BlePermissionState.permanentlyDenied,
    };
  }

  @override
  Future<void> requestEnableAdapter() =>
      _platformDataSource.requestEnableBluetooth();

  @override
  Stream<BleDevice> scan() => _dataSource.scan().map(
    (device) => BleDevice(id: device.id, name: device.name, rssi: device.rssi),
  );

  @override
  Future<void> stopScan() => _dataSource.stopScan();

  @override
  Future<void> connect(BleDevice device) => _dataSource.connect(device.id);

  @override
  Future<void> disconnect() => _dataSource.disconnect();

  @override
  Future<int?> readRssi() => _dataSource.readRssi();

  @override
  Future<bool> writeCommand(Uint8List value) => _dataSource.writeCommand(value);

  @override
  Future<String?> writeAndWait(Uint8List value) =>
      _dataSource.writeAndWait(value);

  @override
  Future<void> dispose() => _dataSource.dispose();
}
