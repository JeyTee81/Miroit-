import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/main_layout.dart';
import '../widgets/tab_button.dart';
import '../models/crm/visite_model.dart';
import '../models/crm/suivi_ca_model.dart';
import '../services/crm_service.dart';
import 'create_visite_screen.dart';

class CrmScreen extends StatefulWidget {
  const CrmScreen({super.key});

  @override
  State<CrmScreen> createState() => _CrmScreenState();
}

class _CrmScreenState extends State<CrmScreen> {
  final CrmService _crmService = CrmService();
  
  int _selectedTab = 0; // 0: Visites, 1: CA par familles
  List<Visite> _visites = [];
  List<SuiviCA> _suiviCA = [];
  Map<String, dynamic>? _resumeCA;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVisites();
    _loadResumeCA();
  }

  Future<void> _loadVisites() async {
    setState(() => _isLoading = true);
    try {
      final visites = await _crmService.getVisites();
      setState(() => _visites = visites);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadResumeCA() async {
    try {
      final resume = await _crmService.getResumeCA();
      setState(() => _resumeCA = resume);
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  Future<void> _calculerCA(DateTime debut, DateTime fin) async {
    setState(() => _isLoading = true);
    try {
      final suiviCA = await _crmService.calculerCA(
        periodeDebut: debut.toIso8601String().split('T')[0],
        periodeFin: fin.toIso8601String().split('T')[0],
      );
      setState(() => _suiviCA = suiviCA);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CA calculé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/crm',
      title: 'CRM',
      tabs: [
        TabButton(
          label: 'Visites',
          isActive: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0),
        ),
        TabButton(
          label: 'CA par familles',
          isActive: _selectedTab == 1,
          onTap: () => setState(() => _selectedTab = 1),
        ),
      ],
      child: IndexedStack(
        index: _selectedTab,
        children: [
          _buildVisitesTab(),
          _buildCATab(),
        ],
      ),
    );
  }

  Widget _buildVisitesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadVisites,
                tooltip: 'Actualiser',
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateVisiteScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadVisites();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle visite'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _visites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune visite',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateVisiteScreen(),
                                ),
                              );
                              if (result == true) {
                                _loadVisites();
                              }
                            },
                            child: const Text('Créer une visite'),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _visites.length,
                        itemBuilder: (context, index) {
                          final visite = _visites[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: visite.typeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: visite.typeColor,
                                ),
                              ),
                              title: Text(
                                visite.clientNom ?? 'Client inconnu',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Type: ${visite.typeLabel}'),
                                  Text(DateFormat('dd/MM/yyyy').format(visite.dateVisite)),
                                  if (visite.commercialNom != null)
                                    Text('Commercial: ${visite.commercialNom}'),
                                  if (visite.resultat != null)
                                    Text('Résultat: ${visite.resultat}'),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Modifier'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editVisite(visite);
                                  } else if (value == 'delete') {
                                    _deleteVisite(visite);
                                  }
                                },
                              ),
                              onTap: () => _editVisite(visite),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildCATab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _loadResumeCA();
                  _loadSuiviCA();
                },
                tooltip: 'Actualiser',
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final dates = await _selectPeriod();
                  if (dates != null) {
                    await _calculerCA(dates[0], dates[1]);
                    await _loadSuiviCA();
                  }
                },
                icon: const Icon(Icons.calculate),
                label: const Text('Calculer CA'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Résumé CA
                      if (_resumeCA != null) ...[
                        const Text(
                          'Résumé CA',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildResumeCA(_resumeCA!),
                        const SizedBox(height: 24),
                      ],
                      
                      // Graphique CA par familles
                      if (_suiviCA.isNotEmpty) ...[
                        const Text(
                          'CA par familles d\'articles',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildCAChart(),
                        const SizedBox(height: 24),
                      ],
                      
                      // Tableau détaillé
                      if (_suiviCA.isNotEmpty) ...[
                        const Text(
                          'Détail par famille',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildCATable(),
                      ] else ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'Aucune donnée de CA disponible.\nCliquez sur "Calculer CA" pour générer les statistiques.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildResumeCA(Map<String, dynamic> resume) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResumeSection('Mois courant', resume['mois_courant']),
            const SizedBox(height: 16),
            _buildResumeSection('Mois précédent', resume['mois_precedent']),
            const SizedBox(height: 16),
            _buildResumeSection('Année courante', resume['annee_courante']),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeSection(String titre, dynamic data) {
    if (data == null || (data is Map && data.isEmpty)) {
      return Text('$titre: Aucune donnée');
    }
    
    double totalCA = 0;
    if (data is Map) {
      data.forEach((famille, stats) {
        if (stats is Map && stats['ca_ttc'] != null) {
          totalCA += (stats['ca_ttc'] is num
              ? (stats['ca_ttc'] as num).toDouble()
              : double.tryParse(stats['ca_ttc'].toString()) ?? 0.0);
        }
      });
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$titre: ${NumberFormat.currency(symbol: '€', decimalDigits: 2).format(totalCA)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (data is Map) ...[
          const SizedBox(height: 8),
          ...data.entries.map((entry) {
            final famille = entry.key;
            final stats = entry.value;
            if (stats is Map) {
              final ca = stats['ca_ttc'] != null
                  ? (stats['ca_ttc'] is num
                      ? (stats['ca_ttc'] as num).toDouble()
                      : double.tryParse(stats['ca_ttc'].toString()) ?? 0.0)
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('  • $famille: ${NumberFormat.currency(symbol: '€', decimalDigits: 2).format(ca)}'),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ],
    );
  }

  Widget _buildCAChart() {
    if (_suiviCA.isEmpty) return const SizedBox.shrink();
    
    final maxCA = _suiviCA.map((s) => s.caTtc).reduce((a, b) => a > b ? a : b);
    
    return SizedBox(
      height: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxCA > 0 ? maxCA * 1.2 : 1000,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < _suiviCA.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _suiviCA[value.toInt()].familleArticle,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value / 1000).toStringAsFixed(0)}k€',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barGroups: _suiviCA.asMap().entries.map((entry) {
                final index = entry.key;
                final suivi = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: suivi.caTtc,
                      color: Colors.blue,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCATable() {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Famille')),
          DataColumn(label: Text('CA HT'), numeric: true),
          DataColumn(label: Text('CA TTC'), numeric: true),
          DataColumn(label: Text('Devis'), numeric: true),
          DataColumn(label: Text('Factures'), numeric: true),
          DataColumn(label: Text('Clients'), numeric: true),
        ],
        rows: _suiviCA.map((suivi) {
          return DataRow(
            cells: [
              DataCell(Text(suivi.familleArticle)),
              DataCell(Text(NumberFormat.currency(symbol: '€', decimalDigits: 2).format(suivi.caHt))),
              DataCell(Text(NumberFormat.currency(symbol: '€', decimalDigits: 2).format(suivi.caTtc))),
              DataCell(Text('${suivi.nombreDevis}')),
              DataCell(Text('${suivi.nombreFactures}')),
              DataCell(Text('${suivi.nombreClients}')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _loadSuiviCA() async {
    try {
      final suiviCA = await _crmService.getSuiviCA();
      setState(() => _suiviCA = suiviCA);
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  Future<List<DateTime>?> _selectPeriod() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final debut = await showDatePicker(
      context: context,
      initialDate: firstDayOfMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (debut == null) return null;
    
    final fin = await showDatePicker(
      context: context,
      initialDate: lastDayOfMonth,
      firstDate: debut,
      lastDate: DateTime(2100),
    );
    
    if (fin == null) return null;
    
    return [debut, fin];
  }

  Future<void> _editVisite(Visite visite) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateVisiteScreen(visite: visite),
      ),
    );
    if (result == true) {
      _loadVisites();
    }
  }

  Future<void> _deleteVisite(Visite visite) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer cette visite ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && visite.id != null) {
      try {
        await _crmService.deleteVisite(visite.id!);
        _loadVisites();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visite supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
