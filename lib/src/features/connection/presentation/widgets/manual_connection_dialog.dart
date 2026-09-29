import 'package:flutter/material.dart';
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
        Icon(
          Icons.bluetooth_connected,
          size: 88,
          color: Theme.of(context).colorScheme.primary,
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
          icon: const Icon(Icons.link_off),
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
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppDimensions.space12),
          Text(l10n.connecting),
        ],
      );
    }
    if (devices.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppDimensions.space12),
          Text(l10n.searchingDevices),
        ],
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: devices.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final device = devices[index];
          return ListTile(
            leading: Icon(_signalIcon(device.rssi)),
            title: Text(device.name),
            subtitle: Text(l10n.signalDbm(device.rssi)),
            onTap: () => onConnect(device),
          );
        },
      ),
    );
  }
}

IconData _signalIcon(int rssi) {
  if (rssi > -70) return Icons.signal_cellular_alt;
  if (rssi > -100) return Icons.signal_cellular_alt_2_bar;
  return Icons.signal_cellular_alt_1_bar;
}
