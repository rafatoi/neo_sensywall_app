import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/app/theme/app_dimensions.dart';
import 'package:neo_sensywall_app/src/features/modes/presentation/controllers/mode_selection_controller.dart';
import 'package:neo_sensywall_app/src/features/modes/presentation/mappers/sensy_mode_localizations.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/domain/entities/sensy_mode.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

class ModesScreen extends ConsumerWidget {
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selection = ref.watch(modeSelectionControllerProvider);
    final controller = ref.read(modeSelectionControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.back,
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.back,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.availableModes),
            Text(
              l10n.selectModeDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 520
                ? 2
                : 1;
            return GridView.builder(
              padding: const EdgeInsets.all(AppDimensions.space16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppDimensions.space16,
                mainAxisSpacing: AppDimensions.space16,
                childAspectRatio: columns == 1 ? 2.4 : 0.85,
              ),
              itemCount: sensyModes.length,
              itemBuilder: (context, index) {
                final mode = sensyModes[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: selection.isLoading
                        ? null
                        : () => controller.selectMode(mode),
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _iconFor(mode.kind),
                            size: columns == 1 ? 48 : 84,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: AppDimensions.space12),
                          Text(
                            mode.title(l10n),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppDimensions.space8),
                          Text(
                            mode.description(l10n),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _iconFor(SensyModeKind kind) => switch (kind) {
    SensyModeKind.paint => Icons.palette_outlined,
    SensyModeKind.catchColor => Icons.ads_click,
    SensyModeKind.memory => Icons.psychology_outlined,
    SensyModeKind.reaction => Icons.timer_outlined,
  };
}
