import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';
import '../screens/login_screen.dart';

class RouteGuard extends StatelessWidget {
  final Widget child;
  final String route;

  const RouteGuard({
    super.key,
    required this.child,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Vérifier si l'utilisateur est authentifié
    if (!authProvider.isAuthenticated || user == null) {
      // Rediriger vers la page de connexion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Vérifier les permissions
    if (!PermissionService.hasAccess(user, route)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accès refusé')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Vous n\'avez pas accès à ce module',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}

