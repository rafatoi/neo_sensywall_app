final class BleDevice {
  const BleDevice({required this.id, required this.name, required this.rssi});

  final String id;
  final String name;
  final int rssi;

  BleDevice copyWith({String? name, int? rssi}) =>
      BleDevice(id: id, name: name ?? this.name, rssi: rssi ?? this.rssi);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BleDevice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          rssi == other.rssi;

  @override
  int get hashCode => Object.hash(id, name, rssi);
}
