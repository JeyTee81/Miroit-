import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../widgets/tab_button.dart';
import 'parametres/imprimantes_tab.dart';
import 'parametres/import_access_tab_v2.dart';
import 'parametres/groups_tab.dart';
import 'parametres/users_tab.dart';
import 'parametres/server_config_tab.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  int _selectedTab = 0; // 0: Groupes, 1: Utilisateurs, 2: Serveur, 3: Imprimantes, 4: Import Access

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/parametres',
      title: 'Paramètres',
      child: Column(
        children: [
          // Onglets
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                TabButton(
                  label: 'Groupes',
                  isActive: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                TabButton(
                  label: 'Utilisateurs',
                  isActive: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
                TabButton(
                  label: 'Serveur',
                  isActive: _selectedTab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                ),
                TabButton(
                  label: 'Imprimantes',
                  isActive: _selectedTab == 3,
                  onTap: () => setState(() => _selectedTab = 3),
                ),
                TabButton(
                  label: 'Import Access',
                  isActive: _selectedTab == 4,
                  onTap: () => setState(() => _selectedTab = 4),
                ),
              ],
            ),
          ),
          const Divider(),
          // Contenu
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: const [
                GroupsTab(),
                UsersTab(),
                ServerConfigTab(),
                ImprimantesTab(),
                ImportAccessTabV2(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


