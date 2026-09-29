// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Sensy Wall';

  @override
  String get welcome => 'Bienvenido al Sensy Wall';

  @override
  String get keepBluetoothOn => 'Mantén encendido el Bluetooth';

  @override
  String get start => 'Comenzar';

  @override
  String get manualConnection => 'Conexión manual';

  @override
  String get connectionSettings => 'Ajustes de la conexión';

  @override
  String get searchingDevices => 'Buscando dispositivos Bluetooth...';

  @override
  String get connecting => 'Conectando...';

  @override
  String get connected => 'Conectado al Sensy Wall';

  @override
  String get reconnecting => 'Reconectando...';

  @override
  String get connectionError => 'Ocurrió un error de conexión.';

  @override
  String get connectionLost => 'Conexión perdida';

  @override
  String get connectionLostDescription =>
      'Estamos intentando reconectarnos. Para hacerlo más rápido, mantente cerca del dispositivo.';

  @override
  String get cancelReconnection => 'Cancelar reconexión';

  @override
  String get connectionRestored => 'Conexión restablecida';

  @override
  String get connectionRestoredDescription =>
      'Puedes continuar, pero por favor no te alejes demasiado.';

  @override
  String get bluetoothPermissionDenied =>
      'Se necesita permiso de Bluetooth para buscar y conectar el Sensy Wall.';

  @override
  String get bluetoothOff => 'Bluetooth está apagado.';

  @override
  String get retry => 'Volver a intentar';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get sensyWallDevice => 'Dispositivo Sensy Wall';

  @override
  String signalDbm(int value) {
    return 'Señal: $value dBm';
  }

  @override
  String get signalStatus => 'Estado de señal';

  @override
  String signalHigh(String deviceName) {
    return 'Excelente conexión con $deviceName';
  }

  @override
  String get signalMedium =>
      'Conexión estable, pero podrías acercarte un poco más';

  @override
  String get signalLow =>
      'Señal débil. ¡Acerca el dispositivo para evitar desconexiones!';

  @override
  String get availableModes => 'Modalidades disponibles';

  @override
  String get selectModeDescription => 'Selecciona la modalidad que desees:';

  @override
  String get paintMode => 'Pinta de colores';

  @override
  String get paintModeDescription =>
      'Golpea las celdas para pintarlas. ¡Deja volar tu imaginación!';

  @override
  String get catchColorMode => 'Atrapar el color';

  @override
  String get catchColorModeDescription =>
      'Golpea la celda del color que se te indique.';

  @override
  String get memoryMode => 'Juego de Memoria';

  @override
  String get memoryModeDescription =>
      'Mira y repite los patrones de color que se te presenten.';

  @override
  String get reactionMode => 'Tiempo de reacción';

  @override
  String get reactionModeDescription =>
      'Golpea rápidamente las celdas mientras estén iluminadas.';

  @override
  String get back => 'Regresar';

  @override
  String get generalSettings => 'Ajustes generales';

  @override
  String get changePlayArea => 'Modificar área de juego';

  @override
  String get playAreaTitle => 'Definir área de juego';

  @override
  String get playAreaDescription =>
      'Selecciona que área del Sensy Wall que estará disponible para jugar';

  @override
  String get playAreaFull => 'Usar todo el Sensy Wall';

  @override
  String get playAreaLowerCenter => 'Usar del centro para abajo';

  @override
  String get playAreaFirstSection => 'Usar solo la primera sección';

  @override
  String brightnessPercent(int value) {
    return 'Brillo del Sensy Wall: $value%';
  }

  @override
  String volumePercent(int value) {
    return 'Volumen del Sensy Wall: $value%';
  }

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get enabled => 'Activados';

  @override
  String get disabled => 'Desactivados';

  @override
  String get difficulty => 'Nivel de dificultad';

  @override
  String get normalDifficulty => 'Normal';

  @override
  String get mediumDifficulty => 'Media';

  @override
  String get hardDifficulty => 'Difícil';

  @override
  String get veryHardDifficulty => 'Muy difícil';

  @override
  String get lightingColor => 'Color de iluminación';

  @override
  String get lightingColorDescription =>
      'Este color se muestra al iluminar las celdas.';

  @override
  String get red => 'Rojo';

  @override
  String get green => 'Verde';

  @override
  String get blue => 'Azul';

  @override
  String get yellow => 'Amarillo';

  @override
  String get purple => 'Morado';

  @override
  String get white => 'Blanco';

  @override
  String get orange => 'Naranja';

  @override
  String get cyan => 'Cian';

  @override
  String get pink => 'Rosado';

  @override
  String get multicolor => 'Multi color';

  @override
  String get developerOptions => 'Opciones de desarrollador';

  @override
  String get developerOptionsDescription =>
      'Modificar estas características afectará tu experiencia con el Sensy Wall.';

  @override
  String get masterWebServer => 'Master Web Server';

  @override
  String get sensyWallWebServer => 'SensyWall Web Server';

  @override
  String get scanCells => 'Escanear celdas';

  @override
  String foundCells(int count) {
    return 'Celdas encontradas: $count';
  }

  @override
  String get operationFailed => 'No fue posible completar la operación.';

  @override
  String get close => 'Cerrar';
}
