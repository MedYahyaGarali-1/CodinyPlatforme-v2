enum AppEnvironment {
  dev,
  prod,
}

class Environment {
  static AppEnvironment current = AppEnvironment.dev;
  
  // 🌐 LOCAL NETWORK - Same WiFi Required!
  // ✅ Works without ngrok issues
  // ⚠️ You and friends must be on THE SAME WiFi network
  // Your PC IP: 192.168.0.201
  static const String baseUrl = 'http://192.168.0.201:3000';
  
  static bool get isDev => current == AppEnvironment.dev;
  static bool get isProd => current == AppEnvironment.prod;
}
