import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:neo_sensywall_app/src/app/theme/app_dimensions.dart';
import 'package:neo_sensywall_app/src/core/assets/app_assets.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_states.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/widgets/ble_signal_status.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

class ReconnectionDialog extends StatelessWidget {
  const ReconnectionDialog({
    required this.session,
    required this.onCancel,
    required this.onDismiss,
    super.key,
  });

  final BleSessionState session;
  final VoidCallback onCancel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final restored = session.isConnected;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(
          dismissible: true,
          onDismiss: onDismiss,
          color: const Color(0x99000000),
        ),
        Center(
          child: Dialog(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 560,
                maxHeight: MediaQuery.sizeOf(context).height * 0.65,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.plugConnection,
                          width: 25,
                          height: 25,
                          colorFilter: ColorFilter.mode(
                            colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: Text(
                            restored
                                ? l10n.connectionRestored
                                : l10n.connectionLost,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const BleSignalStatus(),
                      ],
                    ),
                    const Divider(height: AppDimensions.space24),
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: restored
                            ? _RestoredContent(key: const ValueKey('restored'))
                            : _ReconnectingContent(
                                key: const ValueKey('reconnecting'),
                                onCancel: onCancel,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReconnectingContent extends StatelessWidget {
  const _ReconnectingContent({required this.onCancel, super.key});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.connectionLostDescription, textAlign: TextAlign.center),
        Flexible(
          child: Lottie.asset(
            AppAssets.bluetoothAnimation,
            repeat: true,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: AppDimensions.space8),
        OutlinedButton(
          onPressed: onCancel,
          child: Text(l10n.cancelReconnection),
        ),
      ],
    );
  }
}

class _RestoredContent extends StatelessWidget {
  const _RestoredContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          child: SvgPicture.asset(AppAssets.verified, width: 150, height: 150),
        ),
        const SizedBox(height: AppDimensions.space16),
        Text(
          l10n.connectionRestored,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(l10n.connectionRestoredDescription, textAlign: TextAlign.center),
      ],
    );
  }
}
