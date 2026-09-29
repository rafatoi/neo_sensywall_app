import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neo_sensywall_app/src/app/router/app_routes.dart';
import 'package:neo_sensywall_app/src/features/home/presentation/screens/home_screen.dart';
import 'package:neo_sensywall_app/src/features/mode_settings/presentation/screens/mode_settings_screen.dart';
import 'package:neo_sensywall_app/src/features/modes/presentation/screens/modes_screen.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/domain/entities/sensy_mode.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.homePath,
    routes: [
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.modesPath,
        name: AppRoutes.modesName,
        builder: (context, state) => const ModesScreen(),
      ),
      GoRoute(
        path: AppRoutes.modeSettingsPath,
        name: AppRoutes.modeSettingsName,
        redirect: (context, state) {
          final modeId = int.tryParse(state.pathParameters['modeId'] ?? '');
          return modeId != null && isSupportedModeId(modeId)
              ? null
              : AppRoutes.modesPath;
        },
        builder: (context, state) => ModeSettingsScreen(
          modeId: int.parse(state.pathParameters['modeId']!),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
