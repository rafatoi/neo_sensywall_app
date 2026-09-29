import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum BlePermissionDto { granted, denied, permanentlyDenied }

abstract interface class BlePermissionDataSource {
  Future<BlePermissionDto> request({required int androidSdkInt});
}

final class PermissionHandlerBleDataSource implements BlePermissionDataSource {
  const PermissionHandlerBleDataSource();

  @override
  Future<BlePermissionDto> request({required int androidSdkInt}) async {
    final permissions = switch (defaultTargetPlatform) {
      TargetPlatform.android when androidSdkInt >= 31 => <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ],
      TargetPlatform.android => <Permission>[Permission.locationWhenInUse],
      TargetPlatform.iOS => <Permission>[Permission.bluetooth],
      _ => const <Permission>[],
    };

    if (permissions.isEmpty) return BlePermissionDto.granted;

    final results = await permissions.request();
    if (results.values.any((status) => status.isPermanentlyDenied)) {
      return BlePermissionDto.permanentlyDenied;
    }
    if (results.values.every((status) => status.isGranted)) {
      return BlePermissionDto.granted;
    }
    return BlePermissionDto.denied;
  }
}
