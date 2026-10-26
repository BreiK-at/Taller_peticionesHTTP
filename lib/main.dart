import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_config.dart';
import 'routes/app_router.dart';
import 'themes/app_theme.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga de variables de entorno con fallback de seguridad
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Advertencia: No se pudo cargar el archivo .env: $e");
  }

  final initialRoute = args.isNotEmpty ? args.first : AppRoutes.dashboard;
  runApp(TallerPeticionesApp(initialRoute: initialRoute));
}

class TallerPeticionesApp extends StatelessWidget {
  final String initialRoute;

  const TallerPeticionesApp({
    super.key,
    this.initialRoute = AppRoutes.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: createRouter(initialLocation: initialRoute),
    );
  }
}
