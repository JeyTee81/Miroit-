import '../models/user_model.dart';

class PermissionService {
  /// Mapping des noms de modules vers les routes
  static const Map<String, String> moduleToRoute = {
    'commerciale': '/commerciale',
    'menuiserie': '/menuiserie',
    'vitrages': '/vitrages',
    'optimisation': '/optimisation',
    'stock': '/stock',
    'travaux': '/travaux',
    'planning': '/planning',
    'tournees': '/tournees',
    'crm': '/crm',
    'inertie': '/inertie',
    'parametres': '/parametres',
    'logs': '/logs',
  };

  /// Liste complète de tous les modules (pour superutilisateur)
  static const List<String> allModules = [
    '/home',
    '/commerciale',
    '/menuiserie',
    '/vitrages',
    '/optimisation',
    '/stock',
    '/travaux',
    '/planning',
    '/tournees',
    '/crm',
    '/inertie',
    '/parametres',
    '/logs',
  ];

  /// Vérifie si un utilisateur a accès à un module
  static bool hasAccess(User? user, String route) {
    if (user == null) return false;
    
    // Accueil accessible à tous les utilisateurs authentifiés
    if (route == '/home') {
      return true;
    }
    
    // Superutilisateur a accès à tout
    if (user.isSuperuser == true) {
      return true;
    }
    
    // Vérifier selon les modules accessibles de l'utilisateur (via son groupe)
    if (user.modulesAccessibles != null && user.modulesAccessibles!.isNotEmpty) {
      // Convertir les noms de modules en routes
      final accessibleRoutes = user.modulesAccessibles!
          .map((module) => moduleToRoute[module] ?? '/$module')
          .toList();
      accessibleRoutes.add('/home'); // Toujours accessible
      return accessibleRoutes.contains(route);
    }
    
    // Fallback : utiliser les permissions par défaut selon le rôle (pour compatibilité)
    return _hasAccessByRole(user, route);
  }

  /// Vérifie l'accès selon le rôle (fallback pour compatibilité)
  static bool _hasAccessByRole(User user, String route) {
    final role = user.role?.toLowerCase() ?? '';
    
    // Liste des modules accessibles selon les rôles (par défaut)
    final Map<String, List<String>> roleModules = {
      'admin': allModules,
      'commercial': ['/home', '/commerciale', '/crm', '/tournees', '/planning', '/stock'],
      'atelier': ['/home', '/menuiserie', '/vitrages', '/inertie', '/optimisation', '/planning'],
      'ouvrier': ['/home', '/planning', '/travaux', '/tournees'],
    };
    
    final allowedRoutes = roleModules[role] ?? [];
    return allowedRoutes.contains(route);
  }

  /// Retourne la liste des modules accessibles pour un utilisateur
  static List<String> getAccessibleModules(User? user) {
    if (user == null) return [];
    
    // Superutilisateur a accès à tout
    if (user.isSuperuser == true) {
      return allModules;
    }
    
    // Utiliser les modules accessibles de l'utilisateur (via son groupe)
    if (user.modulesAccessibles != null && user.modulesAccessibles!.isNotEmpty) {
      final routes = user.modulesAccessibles!
          .map((module) => moduleToRoute[module] ?? '/$module')
          .toList();
      routes.add('/home');
      return routes;
    }
    
    // Fallback : utiliser les permissions par défaut selon le rôle
    final role = user.role?.toLowerCase() ?? '';
    final Map<String, List<String>> roleModules = {
      'admin': allModules,
      'commercial': ['/home', '/commerciale', '/crm', '/tournees', '/planning', '/stock'],
      'atelier': ['/home', '/menuiserie', '/vitrages', '/inertie', '/optimisation', '/planning'],
      'ouvrier': ['/home', '/planning', '/travaux', '/tournees'],
    };
    
    return roleModules[role] ?? ['/home'];
  }

  /// Vérifie si un module est accessible pour l'affichage dans la sidebar
  static bool canViewModule(User? user, String route) {
    return hasAccess(user, route);
  }
}

