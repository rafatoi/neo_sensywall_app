# Neo Sensy Wall — reglas de diseño y arquitectura

## 1. Objetivo y fuentes de verdad

Este proyecto Flutter reemplazará gradualmente la aplicación Android Sensy Wall con paridad funcional y visual 1:1.

- Referencia Kotlin: `C:/Users/USER/AndroidStudioProjects/SensyWall`.
- Inventario funcional y protocolo: `C:/Users/USER/AndroidStudioProjects/SensyWall/app/src/main/java/com/example/sensywall/AGENTS.md`.
- Proyecto destino: este repositorio `neo_sensywall_app`.
- Si documentación y código difieren, comprobar la app Kotlin actual y registrar la decisión.
- El scaffold de contador no es arquitectura de producción.

## 2. Reglas no negociables

1. Usar Clean Architecture con dependencias dirigidas hacia el dominio.
2. Riverpod es la única fuente de verdad para estado, coordinación e intenciones.
3. GoRouter es el único sistema de navegación.
4. La UI es pasiva: renderiza estado y despacha acciones semánticas.
5. Ningún widget ejecuta lógica de negocio, BLE, permisos, parsing, persistencia, timers funcionales, filtrado o decisiones de navegación.
6. Mantener tema claro/oscuro, responsive, animaciones, copy y funciones ocultas.
7. Preservar el protocolo BLE byte a byte; nunca depender de `enum.index`.
8. Todo servicio externo queda detrás de una interfaz reemplazable por un fake.
9. No añadir dependencias sin revisar responsabilidad, mantenimiento, licencia y plataformas.
10. No alterar UX o corregir anomalías de Kotlin sin una decisión registrada.

## 3. Estructura objetivo

Usar organización feature-first con capas internas:

```text
lib/
├─ main.dart
└─ src/
   ├─ app/
   │  ├─ app.dart
   │  ├─ bootstrap.dart
   │  ├─ router/
   │  │  ├─ app_router.dart
   │  │  ├─ app_navigator.dart
   │  │  └─ app_routes.dart
   │  └─ theme/
   │     ├─ app_colors.dart
   │     ├─ app_dimensions.dart
   │     ├─ app_motion.dart
   │     ├─ app_theme.dart
   │     ├─ app_theme_extensions.dart
   │     └─ theme_controller.dart
   ├─ core/
   │  ├─ errors/
   │  ├─ lifecycle/
   │  ├─ logging/
   │  └─ protocol/
   ├─ features/
   │  ├─ connection/
   │  ├─ home/
   │  ├─ modes/
   │  ├─ mode_settings/
   │  └─ developer_options/
   ├─ l10n/
   └─ shared/presentation/widgets/
```

Una feature completa sigue:

```text
feature/
├─ domain/
│  ├─ entities/
│  ├─ value_objects/
│  ├─ repositories/
│  └─ use_cases/
├─ data/
│  ├─ data_sources/
│  ├─ dto/
│  ├─ mappers/
│  └─ repositories/
└─ presentation/
   ├─ controllers/
   ├─ providers/
   ├─ screens/
   └─ widgets/
```

No crear carpetas vacías por anticipado. Crear cada capa cuando aparezca una responsabilidad real.

## 4. Dependencias de Clean Architecture

```text
presentation -> domain
data         -> domain
app          -> composición de presentation, domain y data
domain       -> Dart puro
```

- `domain` no importa Flutter, Riverpod, GoRouter, plugins, plataforma ni DTO.
- Las interfaces de repositorio viven en `domain`; las implementaciones en `data`.
- `data` traduce plugins, JSON y bytes a entidades mediante mappers.
- `presentation` no importa implementaciones de `data`; recibe providers.
- Los use cases representan acciones: conectar, desconectar, seleccionar modo, cambiar brillo, detener módulo, etc.
- Use cases, repositorios y Notifiers no reciben `BuildContext` ni widgets.
- No exponer `BluetoothDevice`, excepciones de plugin o DTO a la UI.
- `core` solo contiene responsabilidades verdaderamente transversales.
- Evitar capas vacías o wrappers que no aporten contrato, prueba o responsabilidad.

## 5. Riverpod

La raíz debe usar `ProviderScope`.

Preferir:

- `NotifierProvider` para estado síncrono con acciones.
- `AsyncNotifierProvider` para operaciones con loading, error y data.
- `StreamProvider` para streams naturales como adaptador, conexión o RSSI.
- Providers simples para repositorios, data sources, clock, logger y configuración.
- Overrides para tests, preview y desarrollo sin hardware.

Evitar:

- `setState` para estado funcional o de pantalla;
- `ChangeNotifier`, singletons mutables y variables globales;
- `StateProvider` para lógica de negocio;
- listas/objetos mutables expuestos;
- efectos secundarios desde `build()`;
- acceso a plugins desde widgets;
- `BuildContext` dentro de providers, use cases o repositorios.

La UI puede:

- usar `ref.watch` para renderizar;
- usar `ref.read(controllerProvider.notifier).accion()` para despachar intención;
- usar `ref.listen` para representar un efecto efímero ya decidido por un controlador;
- poseer `AnimationController`, `ScrollController`, `FocusNode` o `TextEditingController` estrictamente visuales.

La UI no puede:

- decidir comandos BLE, IDs o payloads;
- filtrar dispositivos ni transformar valores del protocolo;
- controlar reintentos, timeouts o timers funcionales;
- cambiar rutas directamente;
- mantener modo, color, área, dificultad, tema o conexión;
- contener el contador de funciones ocultas;
- convertir errores técnicos en decisiones de producto.

Los callbacks deben limitarse a despachar intención:

```dart
onPressed: () =>
    ref.read(modeSelectionControllerProvider.notifier).selectMode(mode.id),
```

Los estados son inmutables y explícitos. Modelar permiso denegado, Bluetooth apagado, vacío, escaneando, conectando, conectado, reconectando y error; no inferir estados con booleanos contradictorios.

Usar `autoDispose` para estado exclusivo de pantalla. Mantener vivos router, tema y sesión BLE mientras corresponda. No duplicar estado entre controladores.

## 6. Controladores

- `BleController`: permisos, adaptador, scan, deduplicación, conexión, desconexión, RSSI, lifecycle y reconexión.
- `SensyWallController`: modo, color, brillo, volumen, dificultad, área, efectos y comandos.
- `HomeController`: estado de inicio y conexión manual.
- `ModeSelectionController`: selección, comando y navegación posterior.
- `ModeSettingsController`: cambios de parámetros y detención segura al salir.
- `DeveloperOptionsController`: gesto oculto y acciones administrativas.
- `ThemeController`: `ThemeMode.system`, `light` o `dark`.

Un controlador puede coordinar use cases, pero no contener detalles del plugin. No crear un mega-controller para toda la aplicación.

## 7. Navegación con GoRouter

- Usar `MaterialApp.router`.
- Crear una sola instancia de `GoRouter` mediante `appRouterProvider`.
- Centralizar nombres y paths en `app_routes.dart`.
- Rutas mínimas: `/` (`home`), `/modalidades` (`modes`) y `/modalidades/:modeId/ajustes` (`mode-settings`).
- Validar parámetros en el router y entregar IDs tipados al dominio.
- Prohibido usar `Navigator.push/pop`, `context.go/push` o strings de rutas dentro de widgets.
- `AppNavigator` es la fachada semántica sobre GoRouter y se expone con Riverpod.
- Los controladores llaman `openModes()`, `openModeSettings(id)`, `backToHome()`, etc.
- Redirects y guards dependen de providers, nunca de globals.
- Para back/gestos usar `PopScope`: el widget despacha `onBackRequested`; el controlador ejecuta `stopAll` u otros efectos y luego navega.
- Conservar el flujo de cancelación de reconexión aprobado para cada pantalla.
- Probar rutas, parámetros inválidos, deep links, back y efectos de salida.

La UI no decide el destino: solo informa la intención del usuario.

## 8. Sistema de diseño

La app Kotlin es referencia inicial. No modernizar ni cambiar interacciones durante la réplica sin autorización.

### Tokens

- No usar colores, radios, spacing, elevaciones, tamaños o duraciones mágicas en screens/widgets.
- `app_colors.dart`: paletas.
- `app_dimensions.dart`: spacing, radios, breakpoints y tamaños.
- `app_motion.dart`: duraciones y curvas.
- `app_theme.dart`: `ThemeData` claro/oscuro.
- `app_theme_extensions.dart`: tokens que Material no cubre.
- Los widgets leen `Theme.of(context)` y `ThemeExtension`; no importan paletas internas.
- Los colores físicos del Sensy Wall son datos de dominio; un mapper de presentation los convierte a `Color`.

Tokens principales:

- Claro: primary `#006876`, onPrimary `#FFFFFF`, primaryContainer `#FFFFFF`, background/surface `#F5FAFC`, onBackground `#171D1E`.
- Oscuro: primary `#FFFFFF`, onPrimary/primaryContainer `#282B2B`, background/surface `#0F1416`, onBackground `#DEE3E6`.
- Mantener color dinámico desactivado inicialmente.
- El modo inicial sigue al sistema.
- Conservar logos claro/oscuro, contraste, estados disabled, feedback y safe areas.

### Responsive

Usar `LayoutBuilder` y constraints en presentation.

- portrait: phone;
- landscape menor de 600: phone;
- 600 a menor de 840: tablet small;
- 840 a menor de 1200: tablet medium;
- 1200 a menor de 1600: tablet big;
- definir y probar 1600 o mayor.

Tablet small debe mostrar contenido; no copiar el vacío accidental de Kotlin sin registrarlo.

### Componentes y animación

- Crear componentes para botones, títulos, cards, sliders, switch, RSSI, cuadrícula, diálogos y bottom sheet.
- Separar widgets visuales puros de widgets conectados a providers.
- Un widget puro recibe datos y callbacks; no conoce protocolo ni repositorios.
- Mantener accesibilidad, contraste, targets táctiles y escalado de texto.
- Evitar bloquear scroll ante desbordes.
- Animaciones decorativas pueden vivir en widgets; la decisión funcional de iniciarlas/detenerlas proviene de Riverpod.
- Conservar timings documentados y respetar reducción de movimiento.

## 9. Tema

- `ThemeController` es la única autoridad de `ThemeMode`.
- `AppTheme` construye `lightTheme` y `darkTheme` sin estado mutable.
- `MaterialApp.router` observa providers de tema y router.
- No decidir tema por pantalla ni repetir `ThemeData` en features.
- Persistir selección manual solo mediante repositorio de preferencias; mientras no exista usar `ThemeMode.system`.
- Añadir golden tests de pantallas principales en claro y oscuro.

## 10. Funciones ocultas

Conservar el acceso de desarrollador original:

- taps repetidos sobre “Sensy Wall” desbloquean el diálogo;
- la referencia cuenta 10 taps y reinicia el timeout 2 segundos después del último tap;
- contador, timeout y estado del diálogo viven en `DeveloperOptionsController`;
- inyectar `Clock`/scheduler para probar sin esperas reales;
- cerrar el diálogo limpia el estado requerido;
- no mostrar pistas del gesto en producción.

Acciones ocultas:

- web server MASTER: módulo 1, parámetro 9999, valor 1;
- web server SENSY_WALL: módulo 44, parámetro 9999, valor 1;
- escanear celdas: módulo 44, parámetro 73, valor 1; mostrar respuesta `bsub`.

El diálogo solo despacha acciones. No conoce IDs, no forma bytes y no llama BLE.

## 11. BLE y protocolo

```text
UI -> Controller Riverpod -> Use case -> BleRepository -> Data source/plugin
```

- UUID, módulos, parámetros y codec están fuera de UI.
- Usar valores explícitos; nunca `enum.index`.
- Paquete: exactamente 8 bytes big-endian, int16 module + int16 param + int32 value.
- Aislar el plugin en `data_sources`.
- Traducir excepciones a fallos tipados.
- Cancelar/liberar scan, GATT, reconexión, streams y RSSI.
- Ningún widget mantiene `StreamSubscription`.
- No agregar timeout o cambiar reconexión sin decisión de compatibilidad.
- No registrar MAC reales ni payloads sensibles en producción.
- Crear tests byte a byte antes del hardware.

## 12. Errores, efectos y lifecycle

- Modelar fallos de permiso, adaptador apagado/no disponible, scan, conexión, discovery, característica, write, timeout y respuesta inválida.
- Repositorios no muestran Snackbars ni diálogos.
- Controladores convierten fallos a estados/efectos localizables.
- Widgets solo representan estados y efectos.
- No usar `print`; inyectar logger.
- Foreground/background se observa mediante un servicio de lifecycle coordinado por Riverpod.
- Toda operación asíncrona maneja cancelación, dispose y respuestas tardías.
- Evitar llamadas duplicadas por rebuild.

## 13. Localización y assets

- Usar ARB, `flutter_localizations` y `gen_l10n`.
- Español es base e inglés debe conservarse.
- No hardcodear texto visible, errores, tooltips ni semantics.
- Mantener copy, acentos y saltos de Kotlin durante la primera réplica.
- Migrar todos los VectorDrawable, PNG, WebP, Lottie y MP3 inventariados en el AGENTS Kotlin.
- Convertir VectorDrawable a SVG con manifiesto origen/destino y validación visual.
- Registrar assets en `pubspec.yaml` y centralizar sus paths.
- Mantener logos claro/oscuro.
- No eliminar recursos sin uso hasta cerrar la auditoría de paridad.

## 14. Pruebas

Cada feature requiere, según corresponda:

- unit tests de entidades, value objects y use cases;
- tests de repositorio con data sources fake;
- tests de Notifier/AsyncNotifier con `ProviderContainer` y overrides;
- widget tests de render y despacho de intenciones;
- golden tests de paridad;
- tests de router;
- integration tests;
- hardware real para BLE antes de declarar la fase terminada.

Casos obligatorios:

- codec BLE de 8 bytes;
- permisos concedidos/denegados;
- conexión, pérdida, reconexión y cancelación;
- background/foreground;
- back desde ajustes envía stop antes de navegar;
- tema claro/oscuro;
- todos los breakpoints;
- gesto oculto de 10 taps y timeout;
- acciones MASTER/SENSY_WALL y respuesta `bsub`.

Compilar o verse parecido no es suficiente: debe tener paridad funcional y pruebas.

## 15. Convenciones y flujo

- Ejecutar `dart format .`, `flutter analyze` y `flutter test` antes de cerrar una tarea.
- Archivos pequeños y con una responsabilidad.
- Preferir composición sobre herencia.
- Usar nombres de negocio; evitar `VM`, `Scr` y `MD` fuera del protocolo.
- Documentar motivos, no lo obvio.
- No silenciar lints globalmente para ocultar problemas.
- No introducir generación de código sin justificarla y documentar comandos.
- Usar imports por package entre features; evitar rutas relativas profundas.
- Separar refactors, comportamiento y assets cuando sea posible.

Flujo de una vertical slice:

1. Leer Kotlin y el AGENTS de referencia.
2. Escribir contrato/test de dominio.
3. Implementar entidad y use case.
4. Implementar repositorio fake.
5. Implementar controlador Riverpod.
6. Implementar UI pasiva.
7. Conectar data source real.
8. Verificar router, tema, responsive y funciones ocultas.
9. Comparar con Android y documentar diferencias.
10. Ejecutar format, analyze y tests.

No migrar varias pantallas y BLE real simultáneamente.

## 16. Prohibiciones

- Lógica de negocio o navegación en widgets.
- BLE, permisos, almacenamiento o audio desde UI.
- `setState` para estado funcional.
- IDs, UUID o payloads hardcodeados en presentation.
- Providers definidos dentro de archivos de widgets.
- Mega-controller global.
- Duplicar estado BLE por pantalla.
- Dependencias de data desde domain.
- Cambiar UX/anomalías sin decisión registrada.
- Declarar paridad sin pruebas visuales y funcionales.

## 17. Definition of Done

Una funcionalidad está terminada cuando:

- respeta la dirección de dependencias;
- lógica y estado están en Riverpod, use cases o repositorios;
- UI solo renderiza y despacha intenciones;
- navegación usa AppNavigator/GoRouter;
- funciona en tema claro y oscuro;
- funciona en tamaños objetivo;
- textos están localizados;
- loading y errores están definidos;
- recursos/suscripciones se liberan;
- tiene pruebas proporcionales al riesgo;
- `dart format .`, `flutter analyze` y `flutter test` pasan;
- no hay diferencias con Kotlin que no estén documentadas.

## 18. Estado actual

La primera base de migración ya está implementada:

- `ProviderScope`, `flutter_riverpod` y controladores iniciales;
- `MaterialApp.router`, GoRouter central y `AppNavigator`;
- rutas de inicio, modalidades y ajustes;
- tema claro/oscuro centralizado con `ThemeMode.system`;
- localización ARB en español e inglés;
- dominio inicial de modalidades, colores y protocolo;
- repositorio Sensy Wall en memoria conservado como fake para pruebas y desarrollo sin hardware;
- ajustes iniciales de brillo, volumen, dificultad, sonido y color;
- menú oculto de desarrollador controlado por Riverpod;
- codec BLE de 8 bytes con prueba de compatibilidad;
- data source real con `flutter_reactive_ble 5.6.0` (BSD-3-Clause);
- permisos con `permission_handler 13.0.2` (MIT), diferenciando Android anterior y posterior a API 31;
- canal Android aislado para consultar SDK y abrir la solicitud del sistema para encender Bluetooth;
- estados explícitos de permiso, adaptador, escaneo, conexión, reconexión y error;
- escaneo sin timeout, deduplicación por identificador, actualización de RSSI y auto-conexión a nombres que contengan `SENSY_WALL`;
- conexión manual, desconexión, lectura RSSI cada 2 segundos y reconexión de un solo intento;
- suscripción a respuesta postergada y archivo en el orden y separación de 300 ms de Kotlin;
- comandos normales sin respuesta y flujo de `bsub` con escritura con respuesta;
- lifecycle background/foreground coordinado desde Riverpod;
- implementación real de `SensyWallRepository` sobre BLE;
- Android `compileSdk 37` y AGP `9.1.1`, manteniendo `targetSdk` administrado por Flutter;
- analyze, 9 tests y APK debug verificados.

La elección de `flutter_reactive_ble` evita la licencia comercial que actualmente exige `flutter_blue_plus` para uso por organizaciones con fines de lucro. No cambiar de plugin sin repetir revisión de licencia, mantenimiento y prueba con hardware.

Todavía no están validados scan, GATT, notificaciones, RSSI y reconexión con hardware Sensy Wall real. Tampoco están implementados el audio de desconexión, la migración completa de assets ni la paridad visual final. No declarar terminada la fase BLE hasta ejecutar la matriz física de la sección 14.
