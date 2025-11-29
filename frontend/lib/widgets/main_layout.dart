import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sidebar.dart';

/// Mise en page principale qui applique le design de `interface-gestion-miroiterie(2).html`
/// à tous les écrans métiers.
class MainLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final String title;
  final Widget? searchBar;
  final List<Widget>? tabs;
  final Function(String)? onTabChanged;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.title,
    this.searchBar,
    this.tabs,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 30,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                _TitleBar(
                  userName: authProvider.user?.nom ?? 'Utilisateur',
                ),
                _MenuBar(
                  currentRoute: currentRoute,
                  onNavigate: (route) {
                    if (route != currentRoute) {
                      Navigator.pushReplacementNamed(context, route);
                    }
                  },
                ),
                Expanded(
                  child: Row(
                    children: [
                      // Sidebar modules (gauche), déjà existante
                      Sidebar(
                        currentRoute: currentRoute,
                        onNavigate: (route) {
                          if (route != currentRoute) {
                            Navigator.pushReplacementNamed(context, route);
                          }
                        },
                      ),
                      // Zone principale (dashboard / contenu)
                      Expanded(
                        child: Container(
                          color: const Color(0xFFF8F9FA),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // En-tête du contenu (titre + éventuelle search bar)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2C3E50),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Petit breadcrumb générique
                                        Text(
                                          'Accueil > $title',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF7F8C8D),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    if (searchBar != null)
                                      SizedBox(
                                        width: 300,
                                        child: searchBar!,
                                      ),
                                  ],
                                ),
                              ),
                              // Tabs (si présents)
                              if (tabs != null && tabs!.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 30),
                                  child: Row(
                                    children: tabs!,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              // Contenu métier
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      30, 0, 30, 20),
                                  child: child,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBar(
                  userName: authProvider.user?.nom ?? 'Utilisateur',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Barre de titre style "fenêtre Windows"
class _TitleBar extends StatelessWidget {
  final String userName;

  const _TitleBar({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0F0F0), Color(0xFFE0E0E0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFCCCCCC)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'PG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ProGlass Manager - Logiciel de Gestion Miroiterie',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(width: 12),
              _windowButton('—'),
              const SizedBox(width: 8),
              _windowButton('□'),
              const SizedBox(width: 8),
              _windowButton('✕', isClose: true),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _windowButton(String label, {bool isClose = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: 28,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          border: Border.all(color: const Color(0xFF999999)),
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isClose ? Colors.red[700] : const Color(0xFF333333),
          ),
        ),
      ),
    );
  }
}

/// Barre de menu horizontale (modules principaux)
class _MenuBar extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String> onNavigate;

  const _MenuBar({
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItemData>[
      const _MenuItemData(
        icon: '💼',
        label: 'Gestion Commerciale',
        route: '/commerciale',
      ),
      const _MenuItemData(
        icon: '📦',
        label: 'Stocks & Approvisionnement',
        route: '/stock',
      ),
      const _MenuItemData(
        icon: '👥',
        label: 'CRM',
        route: '/crm',
      ),
      const _MenuItemData(
        icon: '📅',
        label: 'Planning & Tournées',
        route: '/planning',
      ),
      const _MenuItemData(
        icon: '🪟',
        label: 'Miroiterie',
        route: '/menuiserie',
      ),
    ];

    return Container(
      height: 52,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: items.map((item) {
          final isActive = currentRoute == item.route;
          return _MenuItem(
            data: item,
            isActive: isActive,
            onTap: () => onNavigate(item.route),
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItemData {
  final String icon;
  final String label;
  final String route;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _MenuItem extends StatelessWidget {
  final _MenuItemData data;
  final bool isActive;
  final VoidCallback onTap;

  const _MenuItem({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isActive
        ? const LinearGradient(
            colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Colors.transparent, Colors.transparent],
          );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          gradient: gradient,
          border: const Border(
            right: BorderSide(
              color: Color.fromARGB(30, 255, 255, 255),
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              data.icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              data.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barre de statut en bas de la fenêtre
class _StatusBar extends StatelessWidget {
  final String userName;

  const _StatusBar({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFECF0F1), Color(0xFFD5DBDB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(color: Color(0xFFBDC3C7)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              _StatusIndicator(),
              SizedBox(width: 8),
              Text(
                'Connecté - Serveur opérationnel',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
          Text(
            'Utilisateur: $userName',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF555555),
            ),
          ),
          const Text(
            'ProGlass Manager v3.2.1',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF555555),
            ),
          ),
          Text(
            _formatNow(),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatNow() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$day/$month/$year - $hour:$minute';
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF2ECC71),
        shape: BoxShape.circle,
      ),
    );
  }
}
