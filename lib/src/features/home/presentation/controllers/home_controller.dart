import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_sensywall_app/src/app/router/app_navigator.dart';

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

final class HomeState {
  const HomeState({this.showConnectionDialog = false});

  final bool showConnectionDialog;
}

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  void openModes() => ref.read(appNavigatorProvider).openModes();

  void openConnectionDialog() {
    state = const HomeState(showConnectionDialog: true);
  }

  void closeConnectionDialog() {
    state = const HomeState();
  }
}
