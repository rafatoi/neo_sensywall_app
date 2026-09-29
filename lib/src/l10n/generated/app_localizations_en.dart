// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sensy Wall';

  @override
  String get welcome => 'Welcome to Sensy Wall';

  @override
  String get keepBluetoothOn => 'Keep Bluetooth turned on';

  @override
  String get start => 'Start';

  @override
  String get manualConnection => 'Manual connection';

  @override
  String get connectionSettings => 'Connection settings';

  @override
  String get searchingDevices => 'Searching for Bluetooth devices...';

  @override
  String get connecting => 'Connecting...';

  @override
  String get connected => 'Connected to Sensy Wall';

  @override
  String get reconnecting => 'Reconnecting...';

  @override
  String get connectionError => 'A connection error occurred.';

  @override
  String get bluetoothPermissionDenied =>
      'Bluetooth permission is required to find and connect Sensy Wall.';

  @override
  String get bluetoothOff => 'Bluetooth is turned off.';

  @override
  String get retry => 'Try again';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get sensyWallDevice => 'Sensy Wall device';

  @override
  String signalDbm(int value) {
    return 'Signal: $value dBm';
  }

  @override
  String get availableModes => 'Available modes';

  @override
  String get selectModeDescription => 'Select the mode you want:';

  @override
  String get paintMode => 'Paint with Colors';

  @override
  String get paintModeDescription =>
      'Hit the cells to paint them. Let your imagination run free!';

  @override
  String get catchColorMode => 'Catch the Color';

  @override
  String get catchColorModeDescription =>
      'Hit the cell with the indicated color.';

  @override
  String get memoryMode => 'Memory Game';

  @override
  String get memoryModeDescription =>
      'Watch and repeat the color patterns shown.';

  @override
  String get reactionMode => 'Reaction time';

  @override
  String get reactionModeDescription =>
      'Hit the cells quickly while they are lit.';

  @override
  String get back => 'Back';

  @override
  String get generalSettings => 'General settings';

  @override
  String brightnessPercent(int value) {
    return 'Sensy Wall brightness: $value%';
  }

  @override
  String volumePercent(int value) {
    return 'Sensy Wall volume: $value%';
  }

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get enabled => 'On';

  @override
  String get disabled => 'Off';

  @override
  String get difficulty => 'Difficulty level';

  @override
  String get normalDifficulty => 'Normal';

  @override
  String get mediumDifficulty => 'Medium';

  @override
  String get hardDifficulty => 'Hard';

  @override
  String get veryHardDifficulty => 'Very hard';

  @override
  String get lightingColor => 'Lighting color';

  @override
  String get lightingColorDescription =>
      'This color is used when the cells light up.';

  @override
  String get red => 'Red';

  @override
  String get green => 'Green';

  @override
  String get blue => 'Blue';

  @override
  String get yellow => 'Yellow';

  @override
  String get purple => 'Purple';

  @override
  String get white => 'White';

  @override
  String get orange => 'Orange';

  @override
  String get cyan => 'Cyan';

  @override
  String get pink => 'Pink';

  @override
  String get multicolor => 'Multi color';

  @override
  String get developerOptions => 'Developer options';

  @override
  String get developerOptionsDescription =>
      'Changing these settings will affect your Sensy Wall experience.';

  @override
  String get masterWebServer => 'Master Web Server';

  @override
  String get sensyWallWebServer => 'SensyWall Web Server';

  @override
  String get scanCells => 'Scan cells';

  @override
  String foundCells(int count) {
    return 'Cells found: $count';
  }

  @override
  String get operationFailed => 'The operation could not be completed.';

  @override
  String get close => 'Close';
}
