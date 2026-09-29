import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neo_sensywall_app/src/core/assets/app_assets.dart';
import 'package:neo_sensywall_app/src/features/developer_options/presentation/controllers/developer_options_controller.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

class DeveloperOptionsDialog extends ConsumerWidget {
  const DeveloperOptionsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(developerOptionsControllerProvider);
    final controller = ref.read(developerOptionsControllerProvider.notifier);

    return AlertDialog(
      title: Text(l10n.developerOptions),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.developerOptionsDescription),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: state.isBusy ? null : controller.updateMasterWebServer,
            icon: const _ActionIcon(asset: AppAssets.globe),
            label: Text(l10n.masterWebServer),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: state.isBusy
                ? null
                : controller.updateSensyWallWebServer,
            icon: const _ActionIcon(asset: AppAssets.codeWindow),
            label: Text(l10n.sensyWallWebServer),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: state.isBusy ? null : controller.scanCells,
            icon: const _ActionIcon(asset: AppAssets.qrScan),
            label: Text(l10n.scanCells),
          ),
          if (state.foundCells case final count?) ...[
            const SizedBox(height: 12),
            Text(l10n.foundCells(count)),
          ],
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.operationFailed,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (state.isBusy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: controller.close, child: Text(l10n.close)),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 20,
      height: 20,
      colorFilter: ColorFilter.mode(
        Theme.of(context).colorScheme.onSecondaryContainer,
        BlendMode.srcIn,
      ),
    );
  }
}
