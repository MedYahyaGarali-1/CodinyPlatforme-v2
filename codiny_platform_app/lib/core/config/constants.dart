import 'environment.dart';

class AppConstants {
  // ---------- API ----------
  static String get apiBaseUrl {
    if (Environment.isProd) {
      return 'https://api.yourdomain.com';
    }
    return 'http://10.0.2.2:3000'; // Android emulator
  }

  // ---------- APP ----------
  static const int subscriptionDays = 30;

  // ---------- STORAGE KEYS ----------
  static const String storageUserKey = 'current_user';
  static const String storageTokenKey = 'auth_token';
}
