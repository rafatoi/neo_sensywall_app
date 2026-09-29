import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/app/theme/app_dimensions.dart';
import 'package:neo_sensywall_app/src/features/mode_settings/presentation/controllers/mode_settings_controller.dart';
import 'package:neo_sensywall_app/src/features/mode_settings/presentation/mappers/sensy_color_localizations.dart';
import 'package:neo_sensywall_app/src/features/modes/presentation/mappers/sensy_mode_localizations.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/domain/entities/sensy_color_choice.dart';
import 'package:neo_sensywall_app/src/features/sensy_wall/domain/entities/sensy_mode.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

class ModeSettingsScreen extends ConsumerStatefulWidget {
  const ModeSettingsScreen({required this.modeId, super.key});

  final int modeId;

  @override
  ConsumerState<ModeSettingsScreen> createState() => _ModeSettingsScreenState();
}

class _ModeSettingsScreenState extends ConsumerState<ModeSettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(modeSettingsControllerProvider.notifier)
          .loadMode(widget.modeId),
    );
  }

  @override
  void didUpdateWidget(covariant ModeSettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modeId != widget.modeId) {
      ref.read(modeSettingsControllerProvider.notifier).loadMode(widget.modeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(modeSettingsControllerProvider);
    final controller = ref.read(modeSettingsControllerProvider.notifier);
    final mode = sensyModes.firstWhere((item) => item.id == widget.modeId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) controller.leave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: state.isStopping ? null : controller.leave,
            icon: const Icon(Icons.arrow_back),
            tooltip: l10n.back,
          ),
          title: Text(mode.title(l10n)),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              final settings = _SettingsPanel(
                state: state,
                controller: controller,
              );
              final colors = _ColorsPanel(state: state, controller: controller);

              if (wide) {
                return Padding(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 2, child: settings),
                      const SizedBox(width: AppDimensions.space16),
                      Expanded(flex: 5, child: colors),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(AppDimensions.space16),
                children: [
                  settings,
                  const SizedBox(height: AppDimensions.space16),
                  colors,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.state, required this.controller});

  final ModeSettingsState state;
  final ModeSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.generalSettings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.space16),
            Text(l10n.brightnessPercent(state.brightness.round())),
            Slider(
              value: state.brightness,
              min: 5,
              max: 70,
              divisions: 20,
              onChanged: controller.changeBrightness,
              onChangeEnd: (_) => controller.commitBrightness(),
            ),
            Text(l10n.volumePercent(state.volume.round())),
            Slider(
              value: state.volume,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: controller.changeVolume,
              onChangeEnd: (_) => controller.commitVolume(),
            ),
            const SizedBox(height: AppDimensions.space8),
            if (state.usesSoundEffects)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.soundEffects),
                subtitle: Text(
                  state.soundEffects ? l10n.enabled : l10n.disabled,
                ),
                value: state.soundEffects,
                onChanged: (_) => controller.toggleSoundEffects(),
              )
            else ...[
              Text(l10n.difficulty),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: state.difficulty == 0
                        ? null
                        : controller.decreaseDifficulty,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(_difficultyName(l10n, state.difficulty)),
                  IconButton(
                    onPressed: state.difficulty == 3
                        ? null
                        : controller.increaseDifficulty,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _difficultyName(AppLocalizations l10n, int difficulty) =>
      switch (difficulty) {
        0 => l10n.normalDifficulty,
        1 => l10n.mediumDifficulty,
        2 => l10n.hardDifficulty,
        _ => l10n.veryHardDifficulty,
      };
}

class _ColorsPanel extends StatelessWidget {
  const _ColorsPanel({required this.state, required this.controller});

  final ModeSettingsState state;
  final ModeSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = state.modeId == 102
        ? sensyColors
        : sensyColors.where((color) => !color.isMulticolor).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.lightingColor,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(l10n.lightingColorDescription),
            const SizedBox(height: AppDimensions.space16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                mainAxisSpacing: AppDimensions.space12,
                crossAxisSpacing: AppDimensions.space12,
                childAspectRatio: 0.9,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final choice = colors[index];
                final selected = state.colorId == choice.id;
                return Semantics(
                  selected: selected,
                  button: true,
                  label: choice.name(l10n),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                    onTap: () => controller.selectColor(choice.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(AppDimensions.space8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium,
                        ),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(choice.argb),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 8,
                                    color: Color(0x33000000),
                                  ),
                                ],
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space8),
                          Text(choice.name(l10n), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
