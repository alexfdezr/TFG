class AppConfig {
  // Canvia aquesta variable segons si vols treballar en local o amb servidor
  static const bool useLocal = true;

  // IP local per treballar amb Flask localment
  static const String localBaseUrl = 'http://127.0.0.1:5000';
  //static const String localBaseUrl = 'http://192.168.11.161:5000';
  //static const String localBaseUrl = 'http://192.168.1.43:5000';

  // URL del servidor
  static const String serverBaseUrl = 'https://el-meu-servidor.com';

  // Mètode per obtenir la base URL segons entorn
  static String get baseUrl => useLocal ? localBaseUrl : serverBaseUrl;
}
