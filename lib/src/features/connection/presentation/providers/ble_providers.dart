import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/features/connection/data/data_sources/ble_permission_data_source.dart';
import 'package:neo_sensywall_app/src/features/connection/data/data_sources/platform_ble_data_source.dart';
import 'package:neo_sensywall_app/src/features/connection/data/data_sources/reactive_ble_data_source.dart';
import 'package:neo_sensywall_app/src/features/connection/data/repositories/reactive_ble_repository.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/repositories/ble_repository.dart';

final bleDataSourceProvider = Provider<BleDataSource>(
  (ref) => ReactiveBleDataSource(FlutterReactiveBle()),
);

final blePermissionDataSourceProvider = Provider<BlePermissionDataSource>(
  (ref) => const PermissionHandlerBleDataSource(),
);

final platformBleDataSourceProvider = Provider<PlatformBleDataSource>(
  (ref) => const MethodChannelPlatformBleDataSource(),
);

final bleRepositoryProvider = Provider<BleRepository>((ref) {
  final repository = ReactiveBleRepository(
    dataSource: ref.watch(bleDataSourceProvider),
    permissionDataSource: ref.watch(blePermissionDataSourceProvider),
    platformDataSource: ref.watch(platformBleDataSourceProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final bleAutoConnectDelayProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 200),
);
