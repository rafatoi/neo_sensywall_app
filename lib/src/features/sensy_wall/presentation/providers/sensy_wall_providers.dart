import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/providers/ble_providers.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/data/repositories/ble_sensy_wall_repository.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/domain/repositories/sensy_wall_repository.dart';

final sensyWallRepositoryProvider = Provider<SensyWallRepository>(
  (ref) => BleSensyWallRepository(ref.watch(bleRepositoryProvider)),
);
