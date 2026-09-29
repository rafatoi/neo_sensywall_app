import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final rssiTooltipControllerProvider =
    NotifierProvider<RssiTooltipController, bool>(RssiTooltipController.new);

final rssiTooltipDurationProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 3),
);

final class RssiTooltipController extends Notifier<bool> {
  Timer? _timer;

  @override
  bool build() {
    ref.onDispose(() => _timer?.cancel());
    return false;
  }

  void toggle() {
    if (state) {
      close();
      return;
    }
    state = true;
    _timer?.cancel();
    _timer = Timer(ref.read(rssiTooltipDurationProvider), close);
  }

  void close() {
    _timer?.cancel();
    _timer = null;
    state = false;
  }
}
