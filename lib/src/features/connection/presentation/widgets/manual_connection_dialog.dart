import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:neo_sensywall_app/src/core/assets/app_assets.dart';
import 'package:neo_sensywall_app/src/app/theme/app_dimensions.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_device.dart';
import 'package:neo_sensywall_app/src/features/connection/domain/entities/ble_states.dart';
import 'package:neo_sensywall_app/src/l10n/generated/app_localizations.dart';

class ManualConnectionDialog extends StatelessWidget {
  const ManualConnectionDialog({
    required this.session,
    required this.onConnect,
    required this.onDisconnect,
    required this.onRetryPermissions,
    required this.onClose,
    super.key,
  });

  final BleSessionState session;
  final ValueChanged<BleDevice> onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onRetryPermissions;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final namedDevices = session.devices
        .where((device) => device.name.trim().isNotEmpty)
        .toList(growable: false);

    return AlertDialog(
      title: Text(l10n.manualConnection),
      content: SizedBox(
        width: 480,
        child: session.isConnected
            ? _ConnectedDevice(
                device: session.connectedDevice!,
                onDisconnect: onDisconnect,
              )
            : _DisconnectedContent(
                session: session,
                devices: namedDevices,
                onConnect: onConnect,
                onRetryPermissions: onRetryPermissions,
              ),
      ),
      actions: [TextButton(onPressed: onClose, child: Text(l10n.back))],
    );
  }
}

class _ConnectedDevice extends StatelessWidget {
  const _ConnectedDevice({required this.device, required this.onDisconnect});

  final BleDevice device;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.sensyWallDevice,
          width: 176,
          height: 176,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppDimensions.space16),
        Text(
          device.name.isEmpty ? l10n.sensyWallDevice : device.name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.space8),
        Text(l10n.signalDbm(device.rssi)),
        const SizedBox(height: AppDimensions.space16),
        OutlinedButton.icon(
          onPressed: onDisconnect,
          icon: SvgPicture.asset(
            AppAssets.plugConnection,
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          label: Text(l10n.disconnect),
        ),
      ],
    );
  }
}

class _DisconnectedContent extends StatelessWidget {
  const _DisconnectedContent({
    required this.session,
    required this.devices,
    required this.onConnect,
    required this.onRetryPermissions,
  });

  final BleSessionState session;
  final List<BleDevice> devices;
  final ValueChanged<BleDevice> onConnect;
  final VoidCallback onRetryPermissions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (session.permission == BlePermissionState.denied ||
        session.permission == BlePermissionState.permanentlyDenied) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bluetooth_disabled, size: 64),
          const SizedBox(height: AppDimensions.space12),
          Text(l10n.bluetoothPermissionDenied, textAlign: TextAlign.center),
          const SizedBox(height: AppDimensions.space12),
          FilledButton(onPressed: onRetryPermissions, child: Text(l10n.retry)),
        ],
      );
    }
    if (session.adapter == BleAdapterState.poweredOff) {
      return Center(child: Text(l10n.bluetoothOff));
    }
    if (session.phase == BleConnectionPhase.connecting ||
        session.phase == BleConnectionPhase.reconnecting) {
      return _BluetoothProgress(label: l10n.connecting);
    }
    if (devices.isEmpty) {
      return _BluetoothProgress(label: l10n.searchingDevices);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: devices.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final device = devices[index];
          final signal = _signalAsset(device.rssi);
          return ListTile(
            leading: SvgPicture.asset(
              AppAssets.bluetooth,
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            title: Text(device.name),
            subtitle: Text(l10n.signalDbm(device.rssi)),
            trailing: SvgPicture.asset(
              signal.asset,
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(signal.color, BlendMode.srcIn),
            ),
            onTap: () => onConnect(device),
          );
        },
      ),
    );
  }
}

class _BluetoothProgress extends StatelessWidget {
  const _BluetoothProgress({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(AppAssets.bluetoothAnimation, width: 104, height: 104),
        const SizedBox(height: AppDimensions.space12),
        Text(label),
      ],
    );
  }
}

({String asset, Color color}) _signalAsset(int rssi) {
  if (rssi > -70) {
    return (asset: AppAssets.signalHigh, color: Colors.green);
  }
  if (rssi > -100) {
    return (asset: AppAssets.signalMedium, color: Colors.amber);
  }
  return (asset: AppAssets.signalLow, color: Colors.red);
}
