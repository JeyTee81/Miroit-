import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../widgets/tab_button.dart';
import 'inertie/parametrage_tab.dart';
import 'inertie/calcul_tube_tab.dart';
import 'inertie/raidisseur_tab.dart';
import 'inertie/traverse_tab.dart';
import 'inertie/calcul_ei_tab.dart';

class InertieScreen extends StatefulWidget {
  const InertieScreen({super.key});

  @override
  State<InertieScreen> createState() => _InertieScreenState();
}

class _InertieScreenState extends State<InertieScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/inertie',
      title: 'Inertie',
      tabs: [
        TabButton(
          label: 'Paramétrage',
          isActive: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0),
        ),
        TabButton(
          label: 'Calcul Tube',
          isActive: _selectedTab == 1,
          onTap: () => setState(() => _selectedTab = 1),
        ),
        TabButton(
          label: 'Raidisseurs',
          isActive: _selectedTab == 2,
          onTap: () => setState(() => _selectedTab = 2),
        ),
        TabButton(
          label: 'Traverses',
          isActive: _selectedTab == 3,
          onTap: () => setState(() => _selectedTab = 3),
        ),
        TabButton(
          label: 'Calcul EI',
          isActive: _selectedTab == 4,
          onTap: () => setState(() => _selectedTab = 4),
        ),
      ],
      child: IndexedStack(
        index: _selectedTab,
        children: const [
          ParametrageTab(),
          CalculTubeTab(),
          RaidisseurTab(),
          TraverseTab(),
          CalculEITab(),
        ],
      ),
    );
  }
}


