import 'dart:io' show Platform;

class AppConfig {
  /// Override: `--dart-define=API_BASE=https://your-api.onrender.com/api/v1`
  /// Emulator: `mobile/run-emulator.ps1` → `http://10.0.2.2:3000/api/v1`
  /// Physical phone: `mobile/run-device.ps1` → `http://<PC-LAN-IP>:3000/api/v1`
  static String get apiBase {
    const fromEnv = String.fromEnvironment('API_BASE');
    if (fromEnv.isNotEmpty) return fromEnv;
    // Default is emulator-only. Physical device must use run-device.ps1 (or API_BASE dart-define).
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api/v1';
    return 'http://127.0.0.1:3000/api/v1';
  }

  /// Override: `--dart-define=APP_NAME=My Shop`
  static String get appName {
    const fromEnv = String.fromEnvironment('APP_NAME');
    return fromEnv.isNotEmpty ? fromEnv : 'Stock Room';
  }

  /// Keep in sync with `pubspec.yaml` `version:` (name part before `+`).
  static const String appVersion = '1.0.0';
}
