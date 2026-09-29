import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/core/audio/audio_providers.dart';
import 'package:neo_sensywall_app/src/core/audio/audio_repository.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_device.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_states.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/repositories/ble_repository.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/providers/ble_providers.dart';

final bleControllerProvider = NotifierProvider<BleController, BleSessionState>(
  BleController.new,
);

final bleReconnectSuccessDurationProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);

class BleController extends Notifier<BleSessionState> {
  StreamSubscription<BleAdapterState>? _adapterSubscription;
  StreamSubscription<BleConnectionEvent>? _connectionSubscription;
  StreamSubscription<BleDevice>? _scanSubscription;
  Timer? _rssiTimer;
  Timer? _reconnectDialogTimer;
  BleRepository? _repository;
  AudioRepository? _audioRepository;
  BleDevice? _lastConnectedDevice;
  bool _manualDisconnect = false;
  bool _initialized = false;
  bool _connectionRequested = false;

  @override
  BleSessionState build() {
    _repository = ref.read(bleRepositoryProvider);
    _audioRepository = ref.read(audioRepositoryProvider);
    ref.onDispose(_dispose);
    Future<void>.microtask(initialize);
    return const BleSessionState();
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    final repository = _repository!;
    _adapterSubscription = repository.adapterStates.listen(
      _onAdapterState,
      onError: (Object error, StackTrace stackTrace) => _onError(error),
    );
    _connectionSubscription = repository.connectionEvents.listen(
      _onConnectionEvent,
      onError: (Object error, StackTrace stackTrace) => _onError(error),
    );

    try {
      final permission = await repository.requestPermissions();
      state = state.copyWith(permission: permission, clearError: true);
      if (permission != BlePermissionState.granted) return;
      if (state.adapter == BleAdapterState.poweredOff) {
        await repository.requestEnableAdapter();
      } else if (state.adapter == BleAdapterState.ready) {
        await startScan();
      }
    } catch (error) {
      _onError(error);
    }
  }

  Future<void> retryPermissions() async {
    try {
      final permission = await _repository!.requestPermissions();
      state = state.copyWith(permission: permission, clearError: true);
      if (permission != BlePermissionState.granted) return;
      if (state.adapter == BleAdapterState.poweredOff) {
        await _repository!.requestEnableAdapter();
      } else if (state.adapter == BleAdapterState.ready) {
        await startScan();
      }
    } catch (error) {
      _onError(error);
    }
  }

  Future<void> _onAdapterState(BleAdapterState adapter) async {
    state = state.copyWith(adapter: adapter, clearError: true);
    if (state.permission != BlePermissionState.granted) return;
    if (adapter == BleAdapterState.ready && !state.isConnected) {
      await startScan();
    } else if (adapter == BleAdapterState.poweredOff) {
      await stopScan();
      await _repository!.requestEnableAdapter();
    }
  }

  Future<void> startScan() async {
    if (state.permission != BlePermissionState.granted ||
        state.adapter != BleAdapterState.ready ||
        state.isConnected ||
        state.phase == BleConnectionPhase.connecting ||
        state.phase == BleConnectionPhase.reconnecting) {
      return;
    }
    await stopScan(updatePhase: false);
    state = state.copyWith(
      phase: BleConnectionPhase.scanning,
      devices: const [],
      clearError: true,
    );
    _scanSubscription = _repository!.scan().listen(
      _onDeviceFound,
      onError: (Object error, StackTrace stackTrace) => _onError(error),
    );
  }

  void _onDeviceFound(BleDevice device) {
    final index = state.devices.indexWhere((item) => item.id == device.id);
    final devices = [...state.devices];
    if (index == -1) {
      devices.add(device);
    } else {
      devices[index] = device;
    }
    state = state.copyWith(devices: List.unmodifiable(devices));

    if (!_connectionRequested &&
        device.name.toUpperCase().contains('SENSY_WALL')) {
      _connectionRequested = true;
      unawaited(_autoConnect(device));
    }
  }

  Future<void> _autoConnect(BleDevice device) async {
    await stopScan(updatePhase: false);
    await Future<void>.delayed(ref.read(bleAutoConnectDelayProvider));
    await connect(device);
  }

  Future<void> stopScan({bool updatePhase = true}) async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _repository?.stopScan();
    if (updatePhase && state.phase == BleConnectionPhase.scanning) {
      state = state.copyWith(phase: BleConnectionPhase.disconnected);
    }
  }

  Future<void> connect(BleDevice device) async {
    await stopScan(updatePhase: false);
    _manualDisconnect = false;
    _connectionRequested = true;
    state = state.copyWith(
      phase: BleConnectionPhase.connecting,
      connectedDevice: device,
      showReconnectDialog: false,
      clearError: true,
    );
    try {
      await _repository!.connect(device);
    } catch (error) {
      _connectionRequested = false;
      _onError(error);
    }
  }

  Future<void> _onConnectionEvent(BleConnectionEvent event) async {
    switch (event.type) {
      case BleConnectionEventType.connecting:
        state = state.copyWith(phase: BleConnectionPhase.connecting);
      case BleConnectionEventType.connected:
        final device = _deviceFor(event.deviceId);
        final showRestored =
            state.showReconnectDialog ||
            state.phase == BleConnectionPhase.reconnecting;
        _lastConnectedDevice = device;
        _manualDisconnect = false;
        _connectionRequested = false;
        state = state.copyWith(
          phase: BleConnectionPhase.connected,
          connectedDevice: device,
          showReconnectDialog: showRestored,
          clearError: true,
        );
        _startRssiPolling();
        if (showRestored) {
          _reconnectDialogTimer?.cancel();
          _reconnectDialogTimer = Timer(
            ref.read(bleReconnectSuccessDurationProvider),
            dismissReconnectDialog,
          );
        }
      case BleConnectionEventType.disconnecting:
        _rssiTimer?.cancel();
      case BleConnectionEventType.disconnected:
        _rssiTimer?.cancel();
        _reconnectDialogTimer?.cancel();
        _connectionRequested = false;
        state = state.copyWith(
          phase: BleConnectionPhase.disconnected,
          clearConnectedDevice: true,
          showReconnectDialog:
              !_manualDisconnect && _lastConnectedDevice != null,
        );
        if (!_manualDisconnect && _lastConnectedDevice != null) {
          await _reconnectOnce();
        }
    }
  }

  BleDevice _deviceFor(String id) {
    final scanned = state.devices.where((device) => device.id == id);
    if (scanned.isNotEmpty) return scanned.first;
    if (state.connectedDevice?.id == id) return state.connectedDevice!;
    if (_lastConnectedDevice?.id == id) return _lastConnectedDevice!;
    return BleDevice(id: id, name: '', rssi: -100);
  }

  Future<void> _reconnectOnce() async {
    final device = _lastConnectedDevice;
    if (device == null) return;
    state = state.copyWith(
      phase: BleConnectionPhase.reconnecting,
      connectedDevice: device,
      showReconnectDialog: true,
    );
    try {
      await _repository!.connect(device);
    } catch (error) {
      _onError(error);
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _connectionRequested = false;
    _rssiTimer?.cancel();
    await _playDisconnection();
    await _repository!.disconnect();
    state = state.copyWith(
      phase: BleConnectionPhase.disconnected,
      clearConnectedDevice: true,
      showReconnectDialog: false,
      clearError: true,
    );
  }

  Future<void> cancelReconnection() async {
    _manualDisconnect = true;
    await _repository!.disconnect();
    state = state.copyWith(
      phase: BleConnectionPhase.disconnected,
      clearConnectedDevice: true,
      showReconnectDialog: false,
    );
  }

  void dismissReconnectDialog() {
    _reconnectDialogTimer?.cancel();
    _reconnectDialogTimer = null;
    state = state.copyWith(showReconnectDialog: false);
  }

  Future<void> onAppBackground() async {
    if (!state.isConnected) return;
    _manualDisconnect = true;
    _rssiTimer?.cancel();
    await _playDisconnection();
    await _repository!.disconnect();
    state = state.copyWith(
      phase: BleConnectionPhase.disconnected,
      clearConnectedDevice: true,
      showReconnectDialog: false,
    );
  }

  Future<void> onAppForeground() async {
    if (_lastConnectedDevice == null || state.isConnected) return;
    _manualDisconnect = false;
    await _reconnectOnce();
  }

  void _startRssiPolling() {
    _rssiTimer?.cancel();
    _rssiTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final rssi = await _repository!.readRssi();
        final connected = state.connectedDevice;
        if (rssi != null && connected != null) {
          state = state.copyWith(
            connectedDevice: connected.copyWith(rssi: rssi),
          );
        }
      } catch (error) {
        _onError(error, keepPhase: true);
      }
    });
  }

  void _onError(Object error, {bool keepPhase = false}) {
    state = state.copyWith(
      phase: keepPhase ? state.phase : BleConnectionPhase.error,
      error: error,
    );
  }

  Future<void> _playDisconnection() async {
    try {
      await _audioRepository?.playDisconnection();
    } catch (_) {
      // Audio is a secondary effect and must never prevent the BLE disconnect.
    }
  }

  void _dispose() {
    _rssiTimer?.cancel();
    _reconnectDialogTimer?.cancel();
    unawaited(_adapterSubscription?.cancel());
    unawaited(_connectionSubscription?.cancel());
    unawaited(_scanSubscription?.cancel());
  }
}
