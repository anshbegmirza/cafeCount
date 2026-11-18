import 'dart:io' show Platform;

class AppConfig {
  /// Override: `--dart-define=API_BASE=https://your-api.onrender.com/api/v1`
  /// Emulator: `--dart-define=API_BASE=http://10.0.2.2:3000/api/v1`
  static String get apiBase {
    const fromEnv = String.fromEnvironment('API_BASE');
    if (fromEnv.isNotEmpty) return fromEnv;
    // Emulator → host loopback. Physical device: --dart-define=API_BASE=http://<LAN-IP>:3000/api/v1
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api/v1';
    return 'http://127.0.0.1:3000/api/v1';
  }

  /// Override: `--dart-define=APP_NAME=My Shop`
  static String get appName {
    const fromEnv = String.fromEnvironment('APP_NAME');
    return fromEnv.isNotEmpty ? fromEnv : 'Stock Room';
  }
}
