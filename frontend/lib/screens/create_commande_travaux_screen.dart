import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/travaux/commande_travaux_model.dart';
import '../models/travaux/devis_travaux_model.dart';
import '../models/client_model.dart';
import '../models/chantier_model.dart';
import '../services/travaux_service.dart';
import '../services/client_service.dart';
import '../services/chantier_service.dart';

class CreateCommandeTravauxScreen extends StatefulWidget {
  final CommandeTravaux? commande;

  const CreateCommandeTravauxScreen({super.key, this.commande});

  @override
  State<CreateCommandeTravauxScreen> createState() => _CreateCommandeTravauxScreenState();
}

class _CreateCommandeTravauxScreenState extends State<CreateCommandeTravauxScreen> {
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
  List<DevisTravaux> _devis = [];
  DevisTravaux? _selectedDevis;
  final _typeTravauxController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dateCommande = DateTime.now();
  DateTime? _dateDebutPrevue;
  DateTime? _dateFinPrevue;
  double _montantHt = 0.0;
  double _tauxTva = 20.0;
  String _statut = 'brouillon';

  @override
  void initState() {
    super.initState();
    _loadClients();
    if (widget.commande != null) {
      _loadCommandeDetails();
    }
  }

  @override
  void dispose() {
    _typeTravauxController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _clientService.getClients();
      setState(() {
        _clients = clients;
        if (widget.commande != null && widget.commande!.clientId.isNotEmpty) {
          _selectedClient = clients.firstWhere(
            (c) => c.id == widget.commande!.clientId,
            orElse: () => clients.first,
          );
          if (_selectedClient != null) {
            _loadChantiers(_selectedClient!.id!);
            _loadDevis(_selectedClient!.id!);
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
        if (widget.commande != null && widget.commande!.chantierId != null) {
          if (chantiers.isNotEmpty) {
            _selectedChantier = chantiers.firstWhere(
              (c) => c.id == widget.commande!.chantierId,
              orElse: () => chantiers.first,
            );
          }
        }
      });
    } catch (e) {
      // Erreur silencieuse
    }
  }

  Future<void> _loadDevis(String clientId) async {
    try {
      final devis = await _travauxService.getDevisTravaux(clientId: clientId);
      setState(() {
        _devis = devis;
        if (widget.commande != null && widget.commande!.devisId != null) {
          if (devis.isNotEmpty) {
            _selectedDevis = devis.firstWhere(
              (d) => d.id == widget.commande!.devisId,
              orElse: () => devis.first,
            );
          }
        }
      });
    } catch (e) {
      // Erreur silencieuse
    }
  }

  Future<void> _loadCommandeDetails() async {
    if (widget.commande?.id == null) return;

    setState(() => _isLoading = true);
    try {
      final commande = await _travauxService.getCommandeTravauxById(widget.commande!.id!);

      setState(() {
        _typeTravauxController.text = commande.typeTravaux;
        _descriptionController.text = commande.description ?? '';
        _dateCommande = commande.dateCommande;
        _dateDebutPrevue = commande.dateDebutPrevue;
        _dateFinPrevue = commande.dateFinPrevue;
        _montantHt = commande.montantHt;
        _tauxTva = commande.tauxTva;
        _statut = commande.statut;
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

  Future<void> _saveCommande() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un client'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final commande = CommandeTravaux(
        id: widget.commande?.id,
        numeroCommande: widget.commande?.numeroCommande ?? '',
        devisId: _selectedDevis?.id,
        clientId: _selectedClient!.id!,
        chantierId: _selectedChantier?.id,
        dateCommande: _dateCommande,
        dateDebutPrevue: _dateDebutPrevue,
        dateFinPrevue: _dateFinPrevue,
        typeTravaux: _typeTravauxController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        montantHt: _montantHt,
        tauxTva: _tauxTva,
        statut: _statut,
      );

      if (widget.commande != null) {
        await _travauxService.updateCommandeTravaux(commande);
      } else {
        await _travauxService.createCommandeTravaux(commande);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.commande != null ? 'Commande modifiée' : 'Commande créée'),
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

  @override
  Widget build(BuildContext context) {
    final totalTtc = _montantHt * (1 + _tauxTva / 100);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.commande != null ? 'Modifier la commande' : 'Nouvelle commande'),
        actions: [
          IconButton(
            icon: _isSaving ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ) : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveCommande,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                                  _selectedDevis = null;
                                  if (value != null) {
                                    _loadChantiers(value.id!);
                                    _loadDevis(value.id!);
                                  }
                                });
                              },
                              validator: (value) => value == null ? 'Requis' : null,
                            ),
                            const SizedBox(height: 16),
                            if (_selectedClient != null) ...[
                              DropdownButtonFormField<DevisTravaux>(
                                value: _selectedDevis,
                                decoration: const InputDecoration(
                                  labelText: 'Devis associé',
                                  border: OutlineInputBorder(),
                                ),
                                items: _devis.map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text('${d.numeroDevis} - ${d.typeTravaux}'),
                                )).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDevis = value;
                                    if (value != null) {
                                      _typeTravauxController.text = value.typeTravaux;
                                      _montantHt = value.montantHt;
                                      _tauxTva = value.tauxTva;
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
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
                            ],
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
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _dateCommande,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) setState(() => _dateCommande = date);
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date commande *',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(DateFormat('dd/MM/yyyy').format(_dateCommande)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _dateDebutPrevue ?? DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null) setState(() => _dateDebutPrevue = date);
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Date début prévue',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(_dateDebutPrevue != null
                                          ? DateFormat('dd/MM/yyyy').format(_dateDebutPrevue!)
                                          : 'Non définie'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _dateFinPrevue ?? DateTime.now().add(const Duration(days: 30)),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null) setState(() => _dateFinPrevue = date);
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Date fin prévue',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(_dateFinPrevue != null
                                          ? DateFormat('dd/MM/yyyy').format(_dateFinPrevue!)
                                          : 'Non définie'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _montantHt.toString(),
                                    decoration: const InputDecoration(
                                      labelText: 'Montant HT (€)',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final montant = double.tryParse(value);
                                      if (montant != null) setState(() => _montantHt = montant);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _statut,
                              decoration: const InputDecoration(
                                labelText: 'Statut',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'brouillon', child: Text('Brouillon')),
                                DropdownMenuItem(value: 'confirmee', child: Text('Confirmée')),
                                DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                                DropdownMenuItem(value: 'terminee', child: Text('Terminée')),
                                DropdownMenuItem(value: 'annulee', child: Text('Annulée')),
                              ],
                              onChanged: (value) => setState(() => _statut = value ?? 'brouillon'),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              color: Colors.blue.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total HT:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(_montantHt)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('TVA (${_tauxTva}%):', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(totalTtc - _montantHt)),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total TTC:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        Text(
                                          NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(totalTtc),
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

