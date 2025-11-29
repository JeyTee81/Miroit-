import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/commerciale_screen.dart';
import 'screens/stock_screen.dart';
import 'screens/menuiserie_screen.dart';
import 'screens/travaux_screen.dart';
import 'screens/planning_screen.dart';
import 'screens/tournees_screen.dart';
import 'screens/crm_screen.dart';
import 'screens/vitrages_screen.dart';
import 'screens/optimisation_screen.dart';
import 'screens/inertie_screen.dart';
import 'screens/parametres_screen.dart';
import 'screens/logs_screen.dart';
import 'screens/server_config_screen.dart';
import 'widgets/route_guard.dart';
import 'services/config_service.dart';
import 'services/log_service.dart';
import 'theme/app_theme.dart';
import 'dart:async';

void main() {
  // Configurer le handler global d'erreurs Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _logErrorToBackend(
      message: details.exceptionAsString(),
      exceptionType: details.exception.runtimeType.toString(),
      exceptionMessage: details.exception.toString(),
      traceback: details.stack.toString(),
      library: details.library,
    );
  };

  // Capturer les erreurs asynchrones non gérées
  runZonedGuarded(() {
    runApp(const MiroiterieApp());
  }, (error, stack) {
    _logErrorToBackend(
      message: error.toString(),
      exceptionType: error.runtimeType.toString(),
      exceptionMessage: error.toString(),
      traceback: stack.toString(),
    );
  });
}

/// Fonction helper pour logger les erreurs au backend
void _logErrorToBackend({
  required String message,
  String? exceptionType,
  String? exceptionMessage,
  String? traceback,
  String? library,
}) {
  // Envoyer l'erreur au backend de manière asynchrone
  // Ne pas utiliser await pour éviter de bloquer
  final logService = LogService();
  logService.logFrontendError(
    message: message,
    exceptionType: exceptionType,
    exceptionMessage: exceptionMessage,
    traceback: traceback,
    module: library,
    extraData: {
      'platform': 'flutter',
      'timestamp': DateTime.now().toIso8601String(),
    },
  ).catchError((e) {
    // Ignorer les erreurs de logging pour éviter une boucle infinie
    print('Impossible d\'envoyer le log au backend: $e');
  });
}

class MiroiterieApp extends StatelessWidget {
  const MiroiterieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'Miroiterie/Menuiserie',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/config': (context) => const ServerConfigScreen(),
          '/home': (context) =>
              const RouteGuard(child: HomeScreen(), route: '/home'),
          '/commerciale': (context) => const RouteGuard(
              child: CommercialeScreen(), route: '/commerciale'),
          '/stock': (context) =>
              const RouteGuard(child: StockScreen(), route: '/stock'),
          '/menuiserie': (context) =>
              const RouteGuard(child: MenuiserieScreen(), route: '/menuiserie'),
          '/travaux': (context) =>
              const RouteGuard(child: TravauxScreen(), route: '/travaux'),
          '/planning': (context) =>
              const RouteGuard(child: PlanningScreen(), route: '/planning'),
          '/tournees': (context) =>
              const RouteGuard(child: TourneesScreen(), route: '/tournees'),
          '/crm': (context) =>
              const RouteGuard(child: CrmScreen(), route: '/crm'),
          '/vitrages': (context) =>
              const RouteGuard(child: VitragesScreen(), route: '/vitrages'),
          '/optimisation': (context) => const RouteGuard(
              child: OptimisationScreen(), route: '/optimisation'),
          '/inertie': (context) =>
              const RouteGuard(child: InertieScreen(), route: '/inertie'),
          '/parametres': (context) =>
              const RouteGuard(child: ParametresScreen(), route: '/parametres'),
          '/logs': (context) =>
              const RouteGuard(child: LogsScreen(), route: '/logs'),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _configCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkConfig();
  }

  Future<void> _checkConfig() async {
    final completed = await ConfigService.isConfigCompleted();
    setState(() {
      _configCompleted = completed;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si la configuration n'est pas complétée, afficher l'écran de configuration
    if (!_configCompleted) {
      return const ServerConfigScreen();
    }

    // Sinon, afficher l'écran de connexion
    return const LoginScreen();
  }
}
