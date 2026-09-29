import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_device.dart';

enum BleAdapterState {
  unknown,
  unsupported,
  unauthorized,
  poweredOff,
  locationServicesDisabled,
  ready,
}

enum BlePermissionState { unknown, granted, denied, permanentlyDenied }

enum BleConnectionPhase {
  disconnected,
  scanning,
  connecting,
  connected,
  reconnecting,
  error,
}

enum BleConnectionEventType {
  connecting,
  connected,
  disconnecting,
  disconnected,
}

final class BleConnectionEvent {
  const BleConnectionEvent({required this.deviceId, required this.type});

  final String deviceId;
  final BleConnectionEventType type;
}

final class BleSessionState {
  const BleSessionState({
    this.permission = BlePermissionState.unknown,
    this.adapter = BleAdapterState.unknown,
    this.phase = BleConnectionPhase.disconnected,
    this.devices = const [],
    this.connectedDevice,
    this.showReconnectDialog = false,
    this.error,
  });

  final BlePermissionState permission;
  final BleAdapterState adapter;
  final BleConnectionPhase phase;
  final List<BleDevice> devices;
  final BleDevice? connectedDevice;
  final bool showReconnectDialog;
  final Object? error;

  bool get isConnected => phase == BleConnectionPhase.connected;

  BleSessionState copyWith({
    BlePermissionState? permission,
    BleAdapterState? adapter,
    BleConnectionPhase? phase,
    List<BleDevice>? devices,
    BleDevice? connectedDevice,
    bool clearConnectedDevice = false,
    bool? showReconnectDialog,
    Object? error,
    bool clearError = false,
  }) {
    return BleSessionState(
      permission: permission ?? this.permission,
      adapter: adapter ?? this.adapter,
      phase: phase ?? this.phase,
      devices: devices ?? this.devices,
      connectedDevice: clearConnectedDevice
          ? null
          : connectedDevice ?? this.connectedDevice,
      showReconnectDialog: showReconnectDialog ?? this.showReconnectDialog,
      error: clearError ? null : error ?? this.error,
    );
  }
}
