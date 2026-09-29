import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Sensy Wall'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido al Sensy Wall'**
  String get welcome;

  /// No description provided for @keepBluetoothOn.
  ///
  /// In es, this message translates to:
  /// **'Mantén encendido el Bluetooth'**
  String get keepBluetoothOn;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get start;

  /// No description provided for @manualConnection.
  ///
  /// In es, this message translates to:
  /// **'Conexión manual'**
  String get manualConnection;

  /// No description provided for @connectionSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes de la conexión'**
  String get connectionSettings;

  /// No description provided for @searchingDevices.
  ///
  /// In es, this message translates to:
  /// **'Buscando dispositivos Bluetooth...'**
  String get searchingDevices;

  /// No description provided for @connecting.
  ///
  /// In es, this message translates to:
  /// **'Conectando...'**
  String get connecting;

  /// No description provided for @connected.
  ///
  /// In es, this message translates to:
  /// **'Conectado al Sensy Wall'**
  String get connected;

  /// No description provided for @reconnecting.
  ///
  /// In es, this message translates to:
  /// **'Reconectando...'**
  String get reconnecting;

  /// No description provided for @connectionError.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error de conexión.'**
  String get connectionError;

  /// No description provided for @connectionLost.
  ///
  /// In es, this message translates to:
  /// **'Conexión perdida'**
  String get connectionLost;

  /// No description provided for @connectionLostDescription.
  ///
  /// In es, this message translates to:
  /// **'Estamos intentando reconectarnos. Para hacerlo más rápido, mantente cerca del dispositivo.'**
  String get connectionLostDescription;

  /// No description provided for @cancelReconnection.
  ///
  /// In es, this message translates to:
  /// **'Cancelar reconexión'**
  String get cancelReconnection;

  /// No description provided for @connectionRestored.
  ///
  /// In es, this message translates to:
  /// **'Conexión restablecida'**
  String get connectionRestored;

  /// No description provided for @connectionRestoredDescription.
  ///
  /// In es, this message translates to:
  /// **'Puedes continuar, pero por favor no te alejes demasiado.'**
  String get connectionRestoredDescription;

  /// No description provided for @bluetoothPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Se necesita permiso de Bluetooth para buscar y conectar el Sensy Wall.'**
  String get bluetoothPermissionDenied;

  /// No description provided for @bluetoothOff.
  ///
  /// In es, this message translates to:
  /// **'Bluetooth está apagado.'**
  String get bluetoothOff;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Volver a intentar'**
  String get retry;

  /// No description provided for @disconnect.
  ///
  /// In es, this message translates to:
  /// **'Desconectar'**
  String get disconnect;

  /// No description provided for @sensyWallDevice.
  ///
  /// In es, this message translates to:
  /// **'Dispositivo Sensy Wall'**
  String get sensyWallDevice;

  /// No description provided for @signalDbm.
  ///
  /// In es, this message translates to:
  /// **'Señal: {value} dBm'**
  String signalDbm(int value);

  /// No description provided for @signalStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado de señal'**
  String get signalStatus;

  /// No description provided for @signalHigh.
  ///
  /// In es, this message translates to:
  /// **'Excelente conexión con {deviceName}'**
  String signalHigh(String deviceName);

  /// No description provided for @signalMedium.
  ///
  /// In es, this message translates to:
  /// **'Conexión estable, pero podrías acercarte un poco más'**
  String get signalMedium;

  /// No description provided for @signalLow.
  ///
  /// In es, this message translates to:
  /// **'Señal débil. ¡Acerca el dispositivo para evitar desconexiones!'**
  String get signalLow;

  /// No description provided for @availableModes.
  ///
  /// In es, this message translates to:
  /// **'Modalidades disponibles'**
  String get availableModes;

  /// No description provided for @selectModeDescription.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la modalidad que desees:'**
  String get selectModeDescription;

  /// No description provided for @paintMode.
  ///
  /// In es, this message translates to:
  /// **'Pinta de colores'**
  String get paintMode;

  /// No description provided for @paintModeDescription.
  ///
  /// In es, this message translates to:
  /// **'Golpea las celdas para pintarlas. ¡Deja volar tu imaginación!'**
  String get paintModeDescription;

  /// No description provided for @catchColorMode.
  ///
  /// In es, this message translates to:
  /// **'Atrapar el color'**
  String get catchColorMode;

  /// No description provided for @catchColorModeDescription.
  ///
  /// In es, this message translates to:
  /// **'Golpea la celda del color que se te indique.'**
  String get catchColorModeDescription;

  /// No description provided for @memoryMode.
  ///
  /// In es, this message translates to:
  /// **'Juego de Memoria'**
  String get memoryMode;

  /// No description provided for @memoryModeDescription.
  ///
  /// In es, this message translates to:
  /// **'Mira y repite los patrones de color que se te presenten.'**
  String get memoryModeDescription;

  /// No description provided for @reactionMode.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de reacción'**
  String get reactionMode;

  /// No description provided for @reactionModeDescription.
  ///
  /// In es, this message translates to:
  /// **'Golpea rápidamente las celdas mientras estén iluminadas.'**
  String get reactionModeDescription;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Regresar'**
  String get back;

  /// No description provided for @generalSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes generales'**
  String get generalSettings;

  /// No description provided for @changePlayArea.
  ///
  /// In es, this message translates to:
  /// **'Modificar área de juego'**
  String get changePlayArea;

  /// No description provided for @playAreaTitle.
  ///
  /// In es, this message translates to:
  /// **'Definir área de juego'**
  String get playAreaTitle;

  /// No description provided for @playAreaDescription.
  ///
  /// In es, this message translates to:
  /// **'Selecciona que área del Sensy Wall que estará disponible para jugar'**
  String get playAreaDescription;

  /// No description provided for @playAreaFull.
  ///
  /// In es, this message translates to:
  /// **'Usar todo el Sensy Wall'**
  String get playAreaFull;

  /// No description provided for @playAreaLowerCenter.
  ///
  /// In es, this message translates to:
  /// **'Usar del centro para abajo'**
  String get playAreaLowerCenter;

  /// No description provided for @playAreaFirstSection.
  ///
  /// In es, this message translates to:
  /// **'Usar solo la primera sección'**
  String get playAreaFirstSection;

  /// No description provided for @brightnessPercent.
  ///
  /// In es, this message translates to:
  /// **'Brillo del Sensy Wall: {value}%'**
  String brightnessPercent(int value);

  /// No description provided for @volumePercent.
  ///
  /// In es, this message translates to:
  /// **'Volumen del Sensy Wall: {value}%'**
  String volumePercent(int value);

  /// No description provided for @soundEffects.
  ///
  /// In es, this message translates to:
  /// **'Efectos de sonido'**
  String get soundEffects;

  /// No description provided for @enabled.
  ///
  /// In es, this message translates to:
  /// **'Activados'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In es, this message translates to:
  /// **'Desactivados'**
  String get disabled;

  /// No description provided for @difficulty.
  ///
  /// In es, this message translates to:
  /// **'Nivel de dificultad'**
  String get difficulty;

  /// No description provided for @normalDifficulty.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get normalDifficulty;

  /// No description provided for @mediumDifficulty.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get mediumDifficulty;

  /// No description provided for @hardDifficulty.
  ///
  /// In es, this message translates to:
  /// **'Difícil'**
  String get hardDifficulty;

  /// No description provided for @veryHardDifficulty.
  ///
  /// In es, this message translates to:
  /// **'Muy difícil'**
  String get veryHardDifficulty;

  /// No description provided for @lightingColor.
  ///
  /// In es, this message translates to:
  /// **'Color de iluminación'**
  String get lightingColor;

  /// No description provided for @lightingColorDescription.
  ///
  /// In es, this message translates to:
  /// **'Este color se muestra al iluminar las celdas.'**
  String get lightingColorDescription;

  /// No description provided for @red.
  ///
  /// In es, this message translates to:
  /// **'Rojo'**
  String get red;

  /// No description provided for @green.
  ///
  /// In es, this message translates to:
  /// **'Verde'**
  String get green;

  /// No description provided for @blue.
  ///
  /// In es, this message translates to:
  /// **'Azul'**
  String get blue;

  /// No description provided for @yellow.
  ///
  /// In es, this message translates to:
  /// **'Amarillo'**
  String get yellow;

  /// No description provided for @purple.
  ///
  /// In es, this message translates to:
  /// **'Morado'**
  String get purple;

  /// No description provided for @white.
  ///
  /// In es, this message translates to:
  /// **'Blanco'**
  String get white;

  /// No description provided for @orange.
  ///
  /// In es, this message translates to:
  /// **'Naranja'**
  String get orange;

  /// No description provided for @cyan.
  ///
  /// In es, this message translates to:
  /// **'Cian'**
  String get cyan;

  /// No description provided for @pink.
  ///
  /// In es, this message translates to:
  /// **'Rosado'**
  String get pink;

  /// No description provided for @multicolor.
  ///
  /// In es, this message translates to:
  /// **'Multi color'**
  String get multicolor;

  /// No description provided for @developerOptions.
  ///
  /// In es, this message translates to:
  /// **'Opciones de desarrollador'**
  String get developerOptions;

  /// No description provided for @developerOptionsDescription.
  ///
  /// In es, this message translates to:
  /// **'Modificar estas características afectará tu experiencia con el Sensy Wall.'**
  String get developerOptionsDescription;

  /// No description provided for @masterWebServer.
  ///
  /// In es, this message translates to:
  /// **'Master Web Server'**
  String get masterWebServer;

  /// No description provided for @sensyWallWebServer.
  ///
  /// In es, this message translates to:
  /// **'SensyWall Web Server'**
  String get sensyWallWebServer;

  /// No description provided for @scanCells.
  ///
  /// In es, this message translates to:
  /// **'Escanear celdas'**
  String get scanCells;

  /// No description provided for @foundCells.
  ///
  /// In es, this message translates to:
  /// **'Celdas encontradas: {count}'**
  String foundCells(int count);

  /// No description provided for @operationFailed.
  ///
  /// In es, this message translates to:
  /// **'No fue posible completar la operación.'**
  String get operationFailed;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
