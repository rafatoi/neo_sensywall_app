import 'package:flutter/services.dart';

abstract interface class PlatformBleDataSource {
  Future<int> androidSdkInt();
  Future<void> requestEnableBluetooth();
}

final class MethodChannelPlatformBleDataSource
    implements PlatformBleDataSource {
  const MethodChannelPlatformBleDataSource();

  static const _channel = MethodChannel('sensy_wall/platform');

  @override
  Future<int> androidSdkInt() async =>
      await _channel.invokeMethod<int>('androidSdkInt') ?? 31;

  @override
  Future<void> requestEnableBluetooth() =>
      _channel.invokeMethod<void>('requestEnableBluetooth');
}
