class ApiConfig {
  static String get baseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction 
        ? 'https://itsivali.github.io/ticket_support_system/api'
        : 'http://localhost:3000/api';
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };
}