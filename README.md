# Denunciasapp — Aplicación Flutter

Aplicación para gestionar denuncias ciudadanas consumiendo la API REST `denunciaservice`.

## Tecnologías y requisitos

- Flutter con Dart compatible con `^3.13.5` (según `pubspec.yaml`).
- Material Design, paquete HTTP y flutter_test.
- Android Studio, Android SDK y emulador Android o celular con depuración USB.
- API Spring Boot en ejecución en el puerto 8080 y MySQL configurado en el servidor.

Se incluyen carpetas de plataforma Android, Windows y Web. La guía de demostración se centra en Android.

## Instalación

Clona el repositorio, entra en su carpeta y ejecuta:

```powershell
flutter doctor
flutter pub get
flutter devices
```

Mantén `pubspec.lock` para reproducir las dependencias de la aplicación.

## Conexión con la API

`lib/config/api_config.dart` contiene la configuración existente:

- Emulador Android: `http://10.0.2.2:8080` (accede al equipo anfitrión).
- Escritorio: `http://localhost:8080`.
- Celular Android por USB: `http://127.0.0.1:8080`, usando ADB reverse y la opción indicada abajo.

Primero inicia `denunciaservice` y comprueba sus endpoints desde Swagger. La app se conecta a `/denuncias/`. Las credenciales de MySQL pertenecen al servidor y no deben introducirse en Flutter.

## Ejecución en emulador

Inicia un emulador en Android Studio y ejecuta:

```powershell
flutter run -d <id_del_dispositivo>
```

Sustituye el marcador por un ID mostrado por `flutter devices`.

## Ejecución en celular por USB

Conecta el teléfono y autoriza la depuración USB:

```powershell
adb reverse tcp:8080 tcp:8080
flutter run -d <id_del_dispositivo> --dart-define=USE_PHYSICAL_DEVICE=true
```

ADB debe estar en el PATH o ejecutarse desde la carpeta platform-tools del Android SDK. Mantén la API activa durante la demostración.

## Funcionalidades

- Listado paginado de denuncias.
- Registro de una denuncia ciudadana.
- Consulta del detalle por ID.
- Búsqueda por DNI.
- Cambio de estado a atendida.
- Manejo de errores de conexión y tiempos de espera.

La app consume GET y POST `/denuncias/`, GET `/denuncias/{id}`, GET `/denuncias/ciudadano/{dni}` y PUT `/denuncias/{id}`.

## Verificación y compilación

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

El APK se genera en `build/app/outputs/flutter-apk/`. Para verificar el flujo completo necesitas la API y MySQL. La compilación release y su firma requieren configuración propia; no publiques keystores ni `key.properties`.

## Estructura

- `lib/screens/`: listado, formulario, búsqueda y detalle.
- `lib/models/`: modelo de denuncia.
- `lib/services/`: consumo HTTP.
- `lib/config/`: dirección de la API.
- `lib/widgets/`: componentes visuales.
- `test/`: prueba de interfaz existente.

## Seguridad y entrega

Se excluyen compilaciones, cachés, configuración local del SDK, archivos temporales y claves de firma. Publicar el código en GitHub no publica la API ni una aplicación en una tienda. Para la entrega académica ejecuta el proyecto en un emulador o celular junto con la API.
