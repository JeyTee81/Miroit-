import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/main_layout.dart';
import '../widgets/module_card.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final allModules = [
      ModuleCard(
        title: 'Commerciale',
        icon: Icons.business,
        color: Colors.blue,
        route: '/commerciale',
      ),
      ModuleCard(
        title: 'Menuiserie',
        icon: Icons.door_front_door,
        color: Colors.brown,
        route: '/menuiserie',
      ),
      ModuleCard(
        title: 'Vitrages',
        icon: Icons.window,
        color: Colors.cyan,
        route: '/vitrages',
      ),
      ModuleCard(
        title: 'Débit',
        icon: Icons.cut,
        color: Colors.indigo,
        route: '/optimisation',
      ),
      ModuleCard(
        title: 'Stock',
        icon: Icons.inventory,
        color: Colors.orange,
        route: '/stock',
      ),
      ModuleCard(
        title: 'Travaux',
        icon: Icons.construction,
        color: Colors.green,
        route: '/travaux',
      ),
      ModuleCard(
        title: 'Planning',
        icon: Icons.calendar_today,
        color: Colors.purple,
        route: '/planning',
      ),
      ModuleCard(
        title: 'Tournées',
        icon: Icons.local_shipping,
        color: Colors.teal,
        route: '/tournees',
      ),
      ModuleCard(
        title: 'CRM',
        icon: Icons.people,
        color: Colors.pink,
        route: '/crm',
      ),
      ModuleCard(
        title: 'Inertie',
        icon: Icons.engineering,
        color: Colors.deepOrange,
        route: '/inertie',
      ),
      ModuleCard(
        title: 'Logs',
        icon: Icons.article,
        color: Colors.grey,
        route: '/logs',
      ),
    ];

    // Filtrer les modules selon les permissions
    final accessibleModules = allModules.where((module) {
      return PermissionService.hasAccess(user, module.route);
    }).toList();

    return MainLayout(
      currentRoute: '/home',
      title: 'Accueil',
      child: accessibleModules.isEmpty
          ? const Center(
              child: Text('Aucun module accessible'),
            )
          : GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.2,
              children: accessibleModules,
            ),
    );
  }
}


