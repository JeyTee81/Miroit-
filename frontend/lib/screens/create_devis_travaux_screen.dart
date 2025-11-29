import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/travaux/devis_travaux_model.dart';
import '../models/travaux/ligne_devis_travaux_model.dart';
import '../models/client_model.dart';
import '../models/chantier_model.dart';
import '../services/travaux_service.dart';
import '../services/client_service.dart';
import '../services/chantier_service.dart';
import 'detail_calcul_screen.dart';

class CreateDevisTravauxScreen extends StatefulWidget {
  final DevisTravaux? devis;

  const CreateDevisTravauxScreen({super.key, this.devis});

  @override
  State<CreateDevisTravauxScreen> createState() => _CreateDevisTravauxScreenState();
}

class _CreateDevisTravauxScreenState extends State<CreateDevisTravauxScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _travauxService = TravauxService();
  final _clientService = ClientService();
  final _chantierService = ChantierService();
  bool _isLoading = false;
  bool _isSaving = false;

  List<Client> _clients = [];
  Client? _selectedClient;
  List<Chantier> _chantiers = [];
  Chantier? _selectedChantier;
  final _typeTravauxController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dateDevis = DateTime.now();
  DateTime? _dateValidite;
  double _tauxTva = 20.0;
  String _statut = 'brouillon';
  List<LigneDevisTravaux> _lignes = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClients();
    if (widget.devis != null) {
      _loadDevisDetails();
    }
  }

  @override
  void dispose() {
    _typeTravauxController.dispose();
    _descriptionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _clientService.getClients();
      setState(() {
        _clients = clients;
        if (widget.devis != null && widget.devis!.clientId.isNotEmpty) {
          _selectedClient = clients.firstWhere(
            (c) => c.id == widget.devis!.clientId,
            orElse: () => clients.first,
          );
          if (_selectedClient != null) {
            _loadChantiers(_selectedClient!.id!);
          }
        }
      });
    } catch (e) {
      // Erreur silencieuse
    }
  }

  Future<void> _loadChantiers(String clientId) async {
    try {
      final chantiers = await _chantierService.getChantiers(clientId: clientId);
      setState(() {
        _chantiers = chantiers;
        if (widget.devis != null && widget.devis!.chantierId != null) {
          if (chantiers.isNotEmpty) {
            _selectedChantier = chantiers.firstWhere(
              (c) => c.id == widget.devis!.chantierId,
              orElse: () => chantiers.first,
            );
          }
        }
      });
    } catch (e) {
      // Erreur silencieuse
    }
  }

  Future<void> _loadDevisDetails() async {
    if (widget.devis?.id == null) return;

    setState(() => _isLoading = true);
    try {
      final devis = await _travauxService.getDevisTravauxById(widget.devis!.id!);
      final lignes = await _travauxService.getLignesDevisTravaux(devis.id!);

      setState(() {
        _typeTravauxController.text = devis.typeTravaux;
        _descriptionController.text = devis.description ?? '';
        _dateDevis = devis.dateDevis;
        _dateValidite = devis.dateValidite;
        _tauxTva = devis.tauxTva;
        _statut = devis.statut;
        _lignes = lignes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveDevis() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un client'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final devis = DevisTravaux(
        id: widget.devis?.id,
        numeroDevis: widget.devis?.numeroDevis ?? '',
        clientId: _selectedClient!.id!,
        chantierId: _selectedChantier?.id,
        dateDevis: _dateDevis,
        dateValidite: _dateValidite,
        typeTravaux: _typeTravauxController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        montantHt: _calculateTotalHt(),
        tauxTva: _tauxTva,
        statut: _statut,
      );

      DevisTravaux savedDevis;
      if (widget.devis != null) {
        savedDevis = await _travauxService.updateDevisTravaux(devis);
      } else {
        savedDevis = await _travauxService.createDevisTravaux(devis);
      }

      // Sauvegarder les lignes
      for (final ligne in _lignes) {
        if (ligne.id == null) {
          await _travauxService.createLigneDevisTravaux(
            LigneDevisTravaux(
              devisId: savedDevis.id!,
              designation: ligne.designation,
              description: ligne.description,
              quantite: ligne.quantite,
              unite: ligne.unite,
              prixUnitaireHt: ligne.prixUnitaireHt,
              tauxTva: ligne.tauxTva,
              detailCalcul: ligne.detailCalcul,
              ordre: ligne.ordre,
            ),
          );
        } else {
          await _travauxService.updateLigneDevisTravaux(ligne);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.devis != null ? 'Devis modifié' : 'Devis créé'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  double _calculateTotalHt() {
    return _lignes.fold(0.0, (sum, ligne) => sum + ligne.montantHt);
  }

  double _calculateTotalTtc() {
    final totalHt = _calculateTotalHt();
    return totalHt * (1 + _tauxTva / 100);
  }

  void _addLigne() {
    setState(() {
      _lignes.add(LigneDevisTravaux(
        devisId: widget.devis?.id ?? '',
        designation: 'Nouvelle ligne',
        quantite: 1,
        prixUnitaireHt: 0,
        ordre: _lignes.length,
      ));
    });
  }

  void _editLigne(int index) {
    final ligne = _lignes[index];
    showDialog(
      context: context,
      builder: (context) => _LigneEditDialog(
        ligne: ligne,
        onSave: (updatedLigne) {
          setState(() {
            _lignes[index] = updatedLigne;
          });
        },
      ),
    );
  }

  void _deleteLigne(int index) {
    final ligne = _lignes[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la ligne'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette ligne ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (ligne.id != null) {
                _travauxService.deleteLigneDevisTravaux(ligne.id!);
              }
              setState(() {
                _lignes.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.devis != null ? 'Modifier le devis' : 'Nouveau devis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Vue client', icon: Icon(Icons.description)),
            Tab(text: 'Détail calcul', icon: Icon(Icons.calculate)),
          ],
        ),
        actions: [
          IconButton(
            icon: _isSaving ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ) : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveDevis,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildClientView(),
                _buildDetailView(),
              ],
            ),
    );
  }

  Widget _buildClientView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informations générales
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Informations générales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Client>(
                      value: _selectedClient,
                      decoration: const InputDecoration(
                        labelText: 'Client *',
                        border: OutlineInputBorder(),
                      ),
                      items: _clients.map((c) => DropdownMenuItem(value: c, child: Text(c.displayName))).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClient = value;
                          _selectedChantier = null;
                          if (value != null) {
                            _loadChantiers(value.id!);
                          }
                        });
                      },
                      validator: (value) => value == null ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    if (_selectedClient != null)
                      DropdownButtonFormField<Chantier>(
                        value: _selectedChantier,
                        decoration: const InputDecoration(
                          labelText: 'Chantier',
                          border: OutlineInputBorder(),
                        ),
                        items: _chantiers.map((c) => DropdownMenuItem(value: c, child: Text(c.nom))).toList(),
                        onChanged: (value) => setState(() => _selectedChantier = value),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _typeTravauxController,
                      decoration: const InputDecoration(
                        labelText: 'Type de travaux *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateDevis,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) setState(() => _dateDevis = date);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date devis *',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(DateFormat('dd/MM/yyyy').format(_dateDevis)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateValidite ?? DateTime.now().add(const Duration(days: 30)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) setState(() => _dateValidite = date);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date validité',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(_dateValidite != null
                                  ? DateFormat('dd/MM/yyyy').format(_dateValidite!)
                                  : 'Non définie'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _tauxTva.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Taux TVA (%)',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final taux = double.tryParse(value);
                        if (taux != null) setState(() => _tauxTva = taux);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Lignes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Lignes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addLigne,
                          tooltip: 'Ajouter une ligne',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_lignes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('Aucune ligne')),
                      )
                    else
                      ...List.generate(_lignes.length, (index) {
                        final ligne = _lignes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(ligne.designation),
                            subtitle: Text(
                              '${ligne.quantite} ${ligne.uniteLabel} × ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(ligne.prixUnitaireHt)} = ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(ligne.montantHt)} HT',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editLigne(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteLigne(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total HT:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(_calculateTotalHt())),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TVA (${_tauxTva}%):', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(_calculateTotalTtc() - _calculateTotalHt())),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total TTC:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(
                                NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(_calculateTotalTtc()),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Détail du calcul des prix',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_lignes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Aucune ligne. Ajoutez des lignes dans la vue client.'),
              ),
            )
          else
            ...List.generate(_lignes.length, (index) {
              final ligne = _lignes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(ligne.designation),
                  subtitle: Text('Prix unitaire HT: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(ligne.prixUnitaireHt)}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ligne.detailCalcul != null && ligne.detailCalcul!.isNotEmpty
                          ? _buildDetailCalcul(ligne.detailCalcul!)
                          : const Text('Aucun détail de calcul disponible'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Modifier le calcul'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailCalculScreen(
                                    ligne: ligne,
                                    onSave: (updatedLigne) {
                                      setState(() {
                                        _lignes[index] = updatedLigne;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDetailCalcul(Map<String, dynamic> detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (detail['main_oeuvre'] != null) ...[
          const Text('Main d\'œuvre:', style: TextStyle(fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Text('Heures: ${detail['main_oeuvre']['heures'] ?? 0}'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text('Taux horaire: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(detail['main_oeuvre']['taux'] ?? 0)}'),
          ),
        ],
        if (detail['materiaux'] != null && (detail['materiaux'] as List).isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Matériaux:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...(detail['materiaux'] as List).map((m) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('${m['designation'] ?? ''}: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(m['prix'] ?? 0)}'),
              )),
        ],
        if (detail['autres'] != null && (detail['autres'] as List).isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Autres:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...(detail['autres'] as List).map((a) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('${a['designation'] ?? ''}: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(a['prix'] ?? 0)}'),
              )),
        ],
      ],
    );
  }
}

class _LigneEditDialog extends StatefulWidget {
  final LigneDevisTravaux ligne;
  final Function(LigneDevisTravaux) onSave;

  const _LigneEditDialog({required this.ligne, required this.onSave});

  @override
  State<_LigneEditDialog> createState() => _LigneEditDialogState();
}

class _LigneEditDialogState extends State<_LigneEditDialog> {
  late TextEditingController _designationController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantiteController;
  late TextEditingController _prixController;
  late String _unite;

  @override
  void initState() {
    super.initState();
    _designationController = TextEditingController(text: widget.ligne.designation);
    _descriptionController = TextEditingController(text: widget.ligne.description ?? '');
    _quantiteController = TextEditingController(text: widget.ligne.quantite.toString());
    _prixController = TextEditingController(text: widget.ligne.prixUnitaireHt.toString());
    _unite = widget.ligne.unite;
  }

  @override
  void dispose() {
    _designationController.dispose();
    _descriptionController.dispose();
    _quantiteController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  void _save() {
    final quantite = double.tryParse(_quantiteController.text) ?? 1;
    final prix = double.tryParse(_prixController.text) ?? 0;
    final montantHt = quantite * prix;
    final montantTtc = montantHt * (1 + widget.ligne.tauxTva / 100);

    widget.onSave(LigneDevisTravaux(
      id: widget.ligne.id,
      devisId: widget.ligne.devisId,
      designation: _designationController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      quantite: quantite,
      unite: _unite,
      prixUnitaireHt: prix,
      montantHt: montantHt,
      tauxTva: widget.ligne.tauxTva,
      montantTtc: montantTtc,
      detailCalcul: widget.ligne.detailCalcul,
      ordre: widget.ligne.ordre,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la ligne'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _designationController,
              decoration: const InputDecoration(labelText: 'Désignation *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantiteController,
                    decoration: const InputDecoration(labelText: 'Quantité'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _unite,
                    decoration: const InputDecoration(labelText: 'Unité'),
                    items: LigneDevisTravaux.uniteOptions.map((u) {
                      final ligne = LigneDevisTravaux(unite: u, devisId: '', designation: '', prixUnitaireHt: 0);
                      return DropdownMenuItem(value: u, child: Text(ligne.uniteLabel));
                    }).toList(),
                    onChanged: (value) => setState(() => _unite = value ?? 'unite'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _prixController,
              decoration: const InputDecoration(labelText: 'Prix unitaire HT *'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

