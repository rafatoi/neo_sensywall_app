import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:neo_sensywall_app/src/app/theme/app_dimensions.dart';
import 'package:neo_sensywall_app/src/core/assets/app_assets.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_states.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/controllers/ble_controller.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/widgets/ble_signal_status.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/widgets/manual_connection_dialog.dart';
import 'package:neo_sensywall_app/src/features/developer_options/presentation/controllers/developer_options_controller.dart';
import 'package:neo_sensywall_app/src/features/developer_options/presentation/widgets/developer_options_dialog.dart';
import 'package:neo_sensywall_app/src/features/home/presentation/controllers/home_controller.dart';
import 'package:neo_sensywall_app/src/features/home/presentation/widgets/sensy_grid_background.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final developerOptions = ref.watch(developerOptionsControllerProvider);
    final home = ref.watch(homeControllerProvider);
    final ble = ref.watch(bleControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const SensyGridBackground(),
            ColoredBox(
              color: Theme.of(context).colorScheme.surface
                  .withValues(alpha: 0.82),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space24),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Theme.of(context).brightness == Brightness.dark
                              ? AppAssets.sensoryLogoDark
                              : AppAssets.sensoryLogoLight,
                          height: 112,
                          semanticsLabel: l10n.appTitle,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.space16,
                          ),
                          child: SizedBox(width: 280, child: Divider()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (ble.isConnected) ...[
                              SvgPicture.asset(
                                AppAssets.verified,
                                width: 25,
                                height: 25,
                              ),
                              const SizedBox(width: AppDimensions.space16),
                            ],
                            Flexible(
                              child: Text(
                                _connectionMessage(l10n, ble),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!ble.isConnected) ...[
                          Flexible(
                            child: Lottie.asset(
                              AppAssets.bluetoothAnimation,
                              repeat: true,
                              animate: !home.showConnectionDialog,
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: ref
                                .read(homeControllerProvider.notifier)
                                .openModes,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(l10n.start),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: ref
                            .read(developerOptionsControllerProvider.notifier)
                            .registerTap,
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.space12),
                          child: Text(
                            l10n.appTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const BleSignalStatus(),
                      TextButton.icon(
                        onPressed: ref
                            .read(homeControllerProvider.notifier)
                            .openConnectionDialog,
                        icon: SvgPicture.asset(
                          AppAssets.bluetooth,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: Text(
                          ble.isConnected
                              ? l10n.connectionSettings
                              : l10n.manualConnection,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (home.showConnectionDialog) ...[
              const ModalBarrier(dismissible: false, color: Color(0x99000000)),
              Center(
                child: ManualConnectionDialog(
                  session: ble,
                  onConnect: ref.read(bleControllerProvider.notifier).connect,
                  onDisconnect: ref
                      .read(bleControllerProvider.notifier)
                      .disconnect,
                  onRetryPermissions: ref
                      .read(bleControllerProvider.notifier)
                      .retryPermissions,
                  onClose: ref
                      .read(homeControllerProvider.notifier)
                      .closeConnectionDialog,
                ),
              ),
            ],
            if (developerOptions.isOpen) ...[
              const ModalBarrier(dismissible: false, color: Color(0x99000000)),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: DeveloperOptionsDialog(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _connectionMessage(AppLocalizations l10n, BleSessionState state) {
  if (state.permission == BlePermissionState.denied ||
      state.permission == BlePermissionState.permanentlyDenied) {
    return l10n.bluetoothPermissionDenied;
  }
  return switch (state.phase) {
    BleConnectionPhase.scanning => l10n.searchingDevices,
    BleConnectionPhase.connecting => l10n.connecting,
    BleConnectionPhase.connected => l10n.connected,
    BleConnectionPhase.reconnecting => l10n.reconnecting,
    BleConnectionPhase.error => l10n.connectionError,
    BleConnectionPhase.disconnected => l10n.keepBluetoothOn,
  };
}
