import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neo_sensywall_app/src/app/theme/app_dimensions.dart';
import 'package:neo_sensywall_app/src/core/assets/app_assets.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/controllers/ble_controller.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/widgets/ble_signal_status.dart';
import 'package:neo_sensywall_app/src/features/connection/presentation/widgets/reconnection_dialog.dart';
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
    final ble = ref.watch(bleControllerProvider);
    final mode = sensyModes.firstWhere((item) => item.id == widget.modeId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) controller.leave();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(mode.title(l10n)),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: AppDimensions.space16),
                  child: BleSignalStatus(),
                ),
              ],
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;
                  final settings = _SettingsPanel(
                    state: state,
                    controller: controller,
                  );
                  final colors = _ColorsPanel(
                    state: state,
                    controller: controller,
                  );

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
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.space16,
                  AppDimensions.space8,
                  AppDimensions.space16,
                  AppDimensions.space8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: state.isStopping ? null : controller.leave,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.back),
                    ),
                    Flexible(
                      child: FilledButton.icon(
                        onPressed: controller.openAreaSelector,
                        icon: SvgPicture.asset(
                          AppAssets.sensyWall,
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: Text(
                          l10n.changePlayArea,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (state.showAreaSelector) ...[
            ModalBarrier(
              dismissible: true,
              onDismiss: controller.closeAreaSelector,
              color: const Color(0x99000000),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _AreaSheet(state: state, controller: controller),
            ),
          ],
          if (ble.showReconnectDialog)
            ReconnectionDialog(
              session: ble,
              onCancel: controller.cancelReconnection,
              onDismiss: controller.dismissReconnectDialog,
            ),
        ],
      ),
    );
  }
}

class _AreaSheet extends StatelessWidget {
  const _AreaSheet({required this.state, required this.controller});

  final ModeSettingsState state;
  final ModeSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final areas = <({String asset, String label})>[
      (asset: AppAssets.sensyWallFull, label: l10n.playAreaFull),
      (asset: AppAssets.sensyWallLowerCenter, label: l10n.playAreaLowerCenter),
      (
        asset: AppAssets.sensyWallFirstSection,
        label: l10n.playAreaFirstSection,
      ),
    ];

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 12,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 620),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.playAreaTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(l10n.playAreaDescription),
                const SizedBox(height: AppDimensions.space16),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: AppDimensions.space12,
                          mainAxisSpacing: AppDimensions.space12,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: areas.length,
                    itemBuilder: (context, index) {
                      final area = areas[index];
                      return _AreaCard(
                        asset: area.asset,
                        label: area.label,
                        selected: state.areaId == index,
                        onTap: () => controller.selectArea(index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                Center(
                  child: FilledButton(
                    onPressed: controller.closeAreaSelector,
                    child: Text(l10n.close),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({
    required this.asset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: selected ? 1 : 0.6,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        scale: selected ? 1 : 0.94,
        child: Material(
          color: selected
              ? colors.primary.withValues(alpha: 0.5)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            side: BorderSide(
              color: selected ? colors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space8),
              child: Column(
                children: [
                  Expanded(child: SvgPicture.asset(asset, fit: BoxFit.contain)),
                  Checkbox(value: selected, onChanged: (_) => onTap()),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : colors.primary,
                    ),
                  ),
                ],
              ),
            ),
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
            _SettingLabel(
              asset: AppAssets.brightness,
              label: l10n.brightnessPercent(state.brightness.round()),
            ),
            Slider(
              value: state.brightness,
              min: 5,
              max: 70,
              divisions: 20,
              onChanged: controller.changeBrightness,
              onChangeEnd: (_) => controller.commitBrightness(),
            ),
            _SettingLabel(
              asset: AppAssets.volume,
              label: l10n.volumePercent(state.volume.round()),
            ),
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
                    icon: const _ControlIcon(asset: AppAssets.minus),
                  ),
                  Text(_difficultyName(l10n, state.difficulty)),
                  IconButton(
                    onPressed: state.difficulty == 3
                        ? null
                        : controller.increaseDifficulty,
                    icon: const _ControlIcon(asset: AppAssets.plus),
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

class _SettingLabel extends StatelessWidget {
  const _SettingLabel({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          asset,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(
        Theme.of(context).colorScheme.onSurface,
        BlendMode.srcIn,
      ),
    );
  }
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
