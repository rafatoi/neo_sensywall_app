import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neo_sensywall_app/src/app/router/app_router.dart';
import 'package:neo_sensywall_app/src/app/router/app_routes.dart';

final appNavigatorProvider = Provider<AppNavigator>(
  (ref) => AppNavigator(ref.watch(appRouterProvider)),
);

class AppNavigator {
  AppNavigator(this._router);

  final GoRouter _router;

  void openModes() => _router.goNamed(AppRoutes.modesName);

  void openModeSettings(int modeId) => _router.goNamed(
    AppRoutes.modeSettingsName,
    pathParameters: {'modeId': '$modeId'},
  );

  void backToHome() => _router.goNamed(AppRoutes.homeName);

  void backToModes() => _router.goNamed(AppRoutes.modesName);
}
