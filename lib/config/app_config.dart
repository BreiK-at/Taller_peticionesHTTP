import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl {
    if (dotenv.isInitialized) {
      return dotenv.env['API_BASE_URL'] ?? 'https://api-colombia.com/api/v1';
    }
    return 'https://api-colombia.com/api/v1';
  }

  static String get appName {
    if (dotenv.isInitialized) {
      return dotenv.env['APP_NAME'] ?? 'Datos Abiertos Colombia';
    }
    return 'Datos Abiertos Colombia';
  }

  static String get appVersion {
    if (dotenv.isInitialized) {
      return dotenv.env['APP_VERSION'] ?? '1.0.0';
    }
    return '1.0.0';
  }

  // Endpoints de API Colombia
  static const String endpointDepartment = '/Department';
  static const String endpointPresident = '/President';
  static const String endpointTouristicAttraction = '/TouristicAttraction';
  static const String endpointTypicalDish = '/TypicalDish';

  // Configuración de red
  static const Duration timeoutDuration = Duration(seconds: 15);
}
