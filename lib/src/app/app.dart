import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/app/ble_lifecycle_coordinator.dart';
import 'package:neo_sensywall_app/src/app/router/app_router.dart';
import 'package:neo_sensywall_app/src/app/theme/app_theme.dart';
import 'package:neo_sensywall_app/src/app/theme/theme_controller.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

class SensyWallApp extends ConsumerWidget {
  const SensyWallApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bleLifecycleCoordinatorProvider);
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
