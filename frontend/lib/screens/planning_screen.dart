import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/main_layout.dart';
import '../models/planning/rendez_vous_model.dart';
import '../services/rendez_vous_service.dart';
import 'create_rendez_vous_screen.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final RendezVousService _rendezVousService = RendezVousService();
  
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  String? _selectedType;
  List<RendezVous> _rendezVous = [];
  List<RendezVous> _filteredRendezVous = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRendezVous();
  }

  Future<void> _loadRendezVous() async {
    setState(() => _isLoading = true);
    try {
      // Charger les rendez-vous du mois en cours
      final debutMois = DateTime(_focusedDate.year, _focusedDate.month, 1);
      final finMois = DateTime(_focusedDate.year, _focusedDate.month + 1, 0, 23, 59, 59);
      
      final rendezVous = await _rendezVousService.getRendezVousParPeriode(debutMois, finMois);
      setState(() {
        _rendezVous = rendezVous;
        _applyFilters();
      });
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


  void _applyFilters() {
    setState(() {
      _filteredRendezVous = _rendezVous.where((rdv) {
        if (_selectedType != null && rdv.type != _selectedType) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  List<RendezVous> _getRendezVousForDate(DateTime date) {
    return _filteredRendezVous.where((rdv) {
      final rdvDate = DateTime(rdv.dateDebut.year, rdv.dateDebut.month, rdv.dateDebut.day);
      final checkDate = DateTime(date.year, date.month, date.day);
      return rdvDate.isAtSameMomentAs(checkDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/planning',
      title: 'Planning',
      child: Column(
        children: [
          // Filtres
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
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tous les types')),
                      ...RendezVous.typeOptions.map((type) {
                        final rdv = RendezVous(titre: '', dateDebut: DateTime.now(), dateFin: DateTime.now(), type: type, utilisateurId: '');
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: rdv.typeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(rdv.typeLabel),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadRendezVous,
                  tooltip: 'Actualiser',
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateRendezVousScreen(
                          dateInitiale: _selectedDate,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadRendezVous();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau rendez-vous'),
                ),
              ],
            ),
          ),
          
          // Contenu principal
          Expanded(
            child: Row(
              children: [
                // Calendrier
                Expanded(
                  flex: 2,
                  child: Container(
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
                    child: Column(
                      children: [
                        // En-tête du calendrier
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: () {
                                  setState(() {
                                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                                    _loadRendezVous();
                                  });
                                },
                              ),
                              Text(
                                _formatMonthYear(_focusedDate),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () {
                                  setState(() {
                                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                                    _loadRendezVous();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        // Calendrier
                        Expanded(
                          child: _buildCalendar(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Liste des rendez-vous du jour sélectionné
                Expanded(
                  flex: 1,
                  child: Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event, color: Colors.purple),
                              const SizedBox(width: 8),
                              Text(
                                _formatFullDate(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _buildRendezVousList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    // Jours de la semaine
    final weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    
    return Column(
      children: [
        // En-tête des jours
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: weekdays.map((day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
        // Grille du calendrier
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 42, // 6 semaines
            itemBuilder: (context, index) {
              final dayOffset = index - (firstDayWeekday - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return Container(); // Jour vide
              }
              
              final day = dayOffset + 1;
              final date = DateTime(_focusedDate.year, _focusedDate.month, day);
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;
              
              final rdvForDay = _getRendezVousForDate(date);
              
              return InkWell(
                onTap: () {
                  setState(() => _selectedDate = date);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.shade100
                        : isToday
                            ? Colors.blue.shade50
                            : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue
                          : isToday
                              ? Colors.blue.shade300
                              : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.blue.shade900
                              : isToday
                                  ? Colors.blue.shade700
                                  : Colors.black87,
                        ),
                      ),
                      if (rdvForDay.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 2,
                          children: rdvForDay.take(3).map((rdv) {
                            return Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: rdv.typeColor,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                        if (rdvForDay.length > 3)
                          Text(
                            '+${rdvForDay.length - 3}',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRendezVousList() {
    final rdvForSelectedDate = _getRendezVousForDate(_selectedDate);
    
    if (rdvForSelectedDate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucun rendez-vous',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: rdvForSelectedDate.length,
      itemBuilder: (context, index) {
        final rdv = rdvForSelectedDate[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 4,
              decoration: BoxDecoration(
                color: rdv.typeColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                  bottom: Radius.circular(4),
                ),
              ),
            ),
            title: Text(
              rdv.titre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('HH:mm').format(rdv.dateDebut)} - ${DateFormat('HH:mm').format(rdv.dateFin)}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                if (rdv.clientNom != null)
                  Text(
                    'Client: ${rdv.clientNom}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                if (rdv.chantierNom != null)
                  Text(
                    'Chantier: ${rdv.chantierNom}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                if (rdv.lieu != null)
                  Text(
                    'Lieu: ${rdv.lieu}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
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
                  _editRendezVous(rdv);
                } else if (value == 'delete') {
                  _deleteRendezVous(rdv);
                }
              },
            ),
            onTap: () => _editRendezVous(rdv),
          ),
        );
      },
    );
  }

  Future<void> _editRendezVous(RendezVous rdv) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRendezVousScreen(rendezVous: rdv),
      ),
    );
    if (result == true) {
      _loadRendezVous();
    }
  }

  Future<void> _deleteRendezVous(RendezVous rdv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${rdv.titre}" ?'),
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

    if (confirm == true && rdv.id != null) {
      try {
        await _rendezVousService.deleteRendezVous(rdv.id!);
        _loadRendezVous();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rendez-vous supprimé avec succès'),
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

  String _formatMonthYear(DateTime date) {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatFullDate(DateTime date) {
    final weekdays = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
