import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Para celular Android físico conectado por USB con ADB reverse:
  // `adb reverse tcp:8080 tcp:8080`
  // Se puede forzar compilando con: flutter run --dart-define=USE_PHYSICAL_DEVICE=true
  static const bool _usePhysicalAndroid = bool.fromEnvironment('USE_PHYSICAL_DEVICE', defaultValue: false);

  // Permite anular o cambiar la URL base en tiempo de ejecución si se requiere
  static String? _overrideBaseUrl;

  static void setCustomBaseUrl(String? url) {
    if (url != null && url.trim().isNotEmpty) {
      _overrideBaseUrl = url.trim();
    } else {
      _overrideBaseUrl = null;
    }
  }

  static String get baseUrl {
    if (_overrideBaseUrl != null) {
      return _overrideBaseUrl!;
    }

    // 1. Flutter Web (Chrome, Edge, Firefox, etc.)
    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    // 2. Escritorio nativo (Windows, macOS, Linux)
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://localhost:8080';
    }

    // 3. Dispositivo Android Físico mediante ADB Reverse (http://127.0.0.1:8080)
    if (_usePhysicalAndroid) {
      return 'http://127.0.0.1:8080';
    }

    // 4. Emulador Android (10.0.2.2 accede a la máquina host)
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }

  static String get denunciasEndpoint {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$base/denuncias/';
  }
}
