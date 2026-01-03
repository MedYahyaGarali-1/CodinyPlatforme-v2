enum AppEnvironment {
  dev,
  prod,
}

class Environment {
  static AppEnvironment current = AppEnvironment.prod;
  
  // 🚀 PRODUCTION - Railway Deployment
  // ✅ Works from ANYWHERE in the world!
  // ✅ Permanent URL - never changes
  // ✅ Your friends can test from their homes!
  static const String baseUrl = 'https://codinyplatforme-v2-production.up.railway.app';
  
  static bool get isDev => current == AppEnvironment.dev;
  static bool get isProd => current == AppEnvironment.prod;
}
