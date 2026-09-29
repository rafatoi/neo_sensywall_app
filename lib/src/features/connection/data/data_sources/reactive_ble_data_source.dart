import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:neo_sensywall_app/src/features/connection/data/dto/ble_dto.dart';

abstract interface class BleDataSource {
  Stream<BleAdapterDto> get adapterStates;
  Stream<BleConnectionDto> get connectionEvents;
  Stream<BleDeviceDto> scan();
  Future<void> stopScan();
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  Future<int?> readRssi();
  Future<bool> writeCommand(Uint8List value);
  Future<String?> writeAndWait(Uint8List value);
  Future<void> dispose();
}

final class ReactiveBleDataSource implements BleDataSource {
  ReactiveBleDataSource(this._ble);

  final FlutterReactiveBle _ble;

  static final _fileService = Uuid.parse(
    '3cc0bb30-39e3-4f66-ab6e-90113ace963e',
  );
  static final _messagingService = Uuid.parse(
    '6b26ea0f-b9ee-4a18-8c6e-bcf0df876a19',
  );
  static final _deferredResponse = Uuid.parse(
    '8afd0392-864c-41b9-a510-33f901bde01f',
  );
  static final _command = Uuid.parse('e53447ca-54aa-42e0-ab0a-e7844c05e6cf');
  static final _file = Uuid.parse('4bb3b1aa-5690-4d17-9e88-956d89b6531a');

  final _connectionController = StreamController<BleConnectionDto>.broadcast();
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamController<BleDeviceDto>? _scanController;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _responseSubscription;
  StreamSubscription<List<int>>? _fileSubscription;
  Completer<String>? _pendingResponse;
  String? _deviceId;

  @override
  Stream<BleAdapterDto> get adapterStates => _ble.statusStream.map(
    (status) => switch (status) {
      BleStatus.unknown => BleAdapterDto.unknown,
      BleStatus.unsupported => BleAdapterDto.unsupported,
      BleStatus.unauthorized => BleAdapterDto.unauthorized,
      BleStatus.poweredOff => BleAdapterDto.poweredOff,
      BleStatus.locationServicesDisabled =>
        BleAdapterDto.locationServicesDisabled,
      BleStatus.ready => BleAdapterDto.ready,
    },
  );

  @override
  Stream<BleConnectionDto> get connectionEvents => _connectionController.stream;

  @override
  Stream<BleDeviceDto> scan() {
    final controller = StreamController<BleDeviceDto>.broadcast();
    _scanController = controller;
    _scanSubscription = _ble
        .scanForDevices(
          withServices: const [],
          scanMode: ScanMode.lowLatency,
          requireLocationServicesEnabled: true,
        )
        .listen(
          (device) => controller.add(
            BleDeviceDto(id: device.id, name: device.name, rssi: device.rssi),
          ),
          onError: controller.addError,
          onDone: controller.close,
        );
    return controller.stream;
  }

  @override
  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    final controller = _scanController;
    _scanController = null;
    if (controller != null && !controller.isClosed) await controller.close();
  }

  @override
  Future<void> connect(String deviceId) async {
    await _connectionSubscription?.cancel();
    await _cancelNotifications();
    _deviceId = deviceId;
    _connectionSubscription = _ble
        .connectToDevice(
          id: deviceId,
          servicesWithCharacteristicsToDiscover: {
            _messagingService: [_deferredResponse, _command],
            _fileService: [_file],
          },
        )
        .listen((update) {
          final type = switch (update.connectionState) {
            DeviceConnectionState.connecting => BleConnectionDtoType.connecting,
            DeviceConnectionState.connected => BleConnectionDtoType.connected,
            DeviceConnectionState.disconnecting =>
              BleConnectionDtoType.disconnecting,
            DeviceConnectionState.disconnected =>
              BleConnectionDtoType.disconnected,
          };
          _connectionController.add(
            BleConnectionDto(deviceId: deviceId, type: type),
          );
          if (update.connectionState == DeviceConnectionState.connected) {
            unawaited(
              _enableNotifications().catchError(
                (Object error, StackTrace stackTrace) =>
                    _connectionController.addError(error, stackTrace),
              ),
            );
          } else if (update.connectionState ==
              DeviceConnectionState.disconnected) {
            unawaited(_cancelNotifications());
          }
        }, onError: _connectionController.addError);
  }

  Future<void> _enableNotifications() async {
    final deviceId = _deviceId;
    if (deviceId == null) return;

    final responseCharacteristic = _characteristic(
      serviceId: _messagingService,
      characteristicId: _deferredResponse,
    );
    _responseSubscription = _ble
        .subscribeToCharacteristic(responseCharacteristic)
        .listen(
          (_) => unawaited(_readDeferredResponse(responseCharacteristic)),
        );

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_deviceId != deviceId) return;
    _fileSubscription = _ble
        .subscribeToCharacteristic(
          _characteristic(serviceId: _fileService, characteristicId: _file),
        )
        .listen((_) {});
  }

  Future<void> _readDeferredResponse(
    QualifiedCharacteristic characteristic,
  ) async {
    final bytes = await _ble.readCharacteristic(characteristic);
    if (bytes.isEmpty) return;
    final response = utf8.decode(bytes, allowMalformed: true);
    final pending = _pendingResponse;
    if (pending != null && !pending.isCompleted) pending.complete(response);
  }

  QualifiedCharacteristic _characteristic({
    required Uuid serviceId,
    required Uuid characteristicId,
  }) {
    final deviceId = _deviceId;
    if (deviceId == null) throw StateError('No BLE device is connected.');
    return QualifiedCharacteristic(
      serviceId: serviceId,
      characteristicId: characteristicId,
      deviceId: deviceId,
    );
  }

  @override
  Future<void> disconnect() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    await _cancelNotifications();
    _deviceId = null;
  }

  Future<void> _cancelNotifications() async {
    await _responseSubscription?.cancel();
    await _fileSubscription?.cancel();
    _responseSubscription = null;
    _fileSubscription = null;
  }

  @override
  Future<int?> readRssi() async {
    final deviceId = _deviceId;
    if (deviceId == null) return null;
    return _ble.readRssi(deviceId);
  }

  @override
  Future<bool> writeCommand(Uint8List value) async {
    if (_deviceId == null) return false;
    await _ble.writeCharacteristicWithoutResponse(
      _characteristic(serviceId: _messagingService, characteristicId: _command),
      value: value,
    );
    return true;
  }

  @override
  Future<String?> writeAndWait(Uint8List value) async {
    if (_deviceId == null) return null;
    final pending = Completer<String>();
    _pendingResponse = pending;
    await _ble.writeCharacteristicWithResponse(
      _characteristic(
        serviceId: _messagingService,
        characteristicId: _deferredResponse,
      ),
      value: value,
    );
    try {
      return await pending.future;
    } finally {
      if (identical(_pendingResponse, pending)) _pendingResponse = null;
    }
  }

  @override
  Future<void> dispose() async {
    await stopScan();
    await disconnect();
    await _connectionController.close();
  }
}
