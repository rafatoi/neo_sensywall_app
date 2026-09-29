enum BleAdapterDto {
  unknown,
  unsupported,
  unauthorized,
  poweredOff,
  locationServicesDisabled,
  ready,
}

enum BleConnectionDtoType { connecting, connected, disconnecting, disconnected }

final class BleConnectionDto {
  const BleConnectionDto({required this.deviceId, required this.type});

  final String deviceId;
  final BleConnectionDtoType type;
}

final class BleDeviceDto {
  const BleDeviceDto({
    required this.id,
    required this.name,
    required this.rssi,
  });

  final String id;
  final String name;
  final int rssi;
}
