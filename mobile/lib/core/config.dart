import 'dart:io' show Platform;

class AppConfig {
  /// Override: `--dart-define=API_BASE=https://your-api.onrender.com/api/v1`
  /// Emulator: `--dart-define=API_BASE=http://10.0.2.2:3000/api/v1`
  static String get apiBase {
    const fromEnv = String.fromEnvironment('API_BASE');
    if (fromEnv.isNotEmpty) return fromEnv;
    // ponytail: LAN IP can change with DHCP; upgrade: discover or settings screen
    if (Platform.isAndroid) return 'http://192.168.0.102:3000/api/v1';
    return 'http://127.0.0.1:3000/api/v1';
  }
}
