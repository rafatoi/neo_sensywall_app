import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neo_sensywall_app/src/core/assets/app_assets.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/controllers/ble_controller.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/controllers/rssi_tooltip_controller.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

class BleSignalStatus extends ConsumerWidget {
  const BleSignalStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(bleControllerProvider);
    final showTooltip = ref.watch(rssiTooltipControllerProvider);
    final device = session.connectedDevice;
    if (!session.isConnected || device == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final status = _statusFor(device.rssi);
    final message = switch (status.level) {
      _SignalLevel.high => l10n.signalHigh(device.name),
      _SignalLevel.medium => l10n.signalMedium,
      _SignalLevel.low => l10n.signalLow,
    };

    return SizedBox.square(
      dimension: 32,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Semantics(
            button: true,
            label: l10n.signalStatus,
            child: InkResponse(
              onTap: ref.read(rssiTooltipControllerProvider.notifier).toggle,
              radius: 24,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  status.asset,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(status.color, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 40,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
                  alignment: Alignment.bottomRight,
                  child: child,
                ),
              ),
              child: showTooltip
                  ? Material(
                      key: const ValueKey('rssi-tooltip'),
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      elevation: 6,
                      borderRadius: BorderRadius.circular(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            '$message (${device.rssi} dBm)',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('rssi-hidden')),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SignalLevel { high, medium, low }

({String asset, Color color, _SignalLevel level}) _statusFor(int rssi) {
  if (rssi > -80) {
    return (
      asset: AppAssets.signalHigh,
      color: const Color(0xFF4CAF50),
      level: _SignalLevel.high,
    );
  }
  if (rssi > -95) {
    return (
      asset: AppAssets.signalMedium,
      color: const Color(0xFFFFEB3B),
      level: _SignalLevel.medium,
    );
  }
  return (
    asset: AppAssets.signalLow,
    color: const Color(0xFFF44336),
    level: _SignalLevel.low,
  );
}
