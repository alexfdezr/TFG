class AppConfig {
  static const bool useLocal = false;

  static const String localBaseUrl = 'http://127.0.0.1:5000';

  static const String serverBaseUrl = 'http://158.109.8.44:8080';

  static String get baseUrl => useLocal ? localBaseUrl : serverBaseUrl;
}
