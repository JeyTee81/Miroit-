import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/permission_service.dart';

class SidebarItem {
  final String title;
  final IconData icon;
  final String route;
  final bool isActive;

  SidebarItem({
    required this.title,
    required this.icon,
    required this.route,
    this.isActive = false,
  });
}

class Sidebar extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const Sidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final items = _getSidebarItems(user);

    return Container(
      width: 280,
      color: AppTheme.primaryDark,
      child: Column(
        children: [
          // Logo et titre en haut
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark,
                    border: Border.all(color: AppTheme.textWhite, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Miroît+ Expert',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF3A3A3A), height: 1),
          // Liste des modules
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isActive = item.route == currentRoute ||
                    (currentRoute == '/' && item.route == '/home');

                return _SidebarItemWidget(
                  item: item,
                  isActive: isActive,
                  onTap: () => onNavigate(item.route),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<SidebarItem> _getSidebarItems(User? user) {
    final allItems = [
      SidebarItem(
        title: 'Accueil',
        icon: Icons.home,
        route: '/home',
      ),
      SidebarItem(
        title: 'Gestion commerciale',
        icon: Icons.business,
        route: '/commerciale',
      ),
      SidebarItem(
        title: 'Menuiserie',
        icon: Icons.door_front_door,
        route: '/menuiserie',
      ),
      SidebarItem(
        title: 'Vitrages',
        icon: Icons.window,
        route: '/vitrages',
      ),
      SidebarItem(
        title: 'Débit',
        icon: Icons.cut,
        route: '/optimisation',
      ),
      SidebarItem(
        title: 'Stock',
        icon: Icons.inventory,
        route: '/stock',
      ),
      SidebarItem(
        title: 'Travaux',
        icon: Icons.construction,
        route: '/travaux',
      ),
      SidebarItem(
        title: 'Planning',
        icon: Icons.calendar_today,
        route: '/planning',
      ),
      SidebarItem(
        title: 'Tournées',
        icon: Icons.local_shipping,
        route: '/tournees',
      ),
      SidebarItem(
        title: 'CRM',
        icon: Icons.people,
        route: '/crm',
      ),
      SidebarItem(
        title: 'Inertie',
        icon: Icons.engineering,
        route: '/inertie',
      ),
      SidebarItem(
        title: 'Paramètres',
        icon: Icons.settings,
        route: '/parametres',
      ),
      SidebarItem(
        title: 'Logs',
        icon: Icons.article,
        route: '/logs',
      ),
    ];

    // Filtrer selon les permissions
    return allItems.where((item) {
      return PermissionService.canViewModule(user, item.route);
    }).toList();
  }
}

class _SidebarItemWidget extends StatelessWidget {
  final SidebarItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.activeItemBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: AppTheme.textWhite,
          size: 22,
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

