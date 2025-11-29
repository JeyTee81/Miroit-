import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/facture_model.dart';
import '../models/client_model.dart';
import '../models/devis_model.dart';
import '../services/facture_service.dart';
import '../services/client_service.dart';
import '../services/devis_service.dart';
import '../services/print_service.dart';
import '../pdf_generators/facture_pdf_generator.dart';

class CreateFactureScreen extends StatefulWidget {
  final Facture? facture; // Si fourni, on est en mode édition

  const CreateFactureScreen({super.key, this.facture});

  @override
  State<CreateFactureScreen> createState() => _CreateFactureScreenState();
}

class _CreateFactureScreenState extends State<CreateFactureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _factureService = FactureService();
  final _clientService = ClientService();
  final _devisService = DevisService();
  final _printService = PrintService();
  bool _isLoading = false;
  bool _isSaving = false;

  List<Client> _clients = [];
  Client? _selectedClient;
  List<Devis> _devis = [];
  Devis? _selectedDevis;
  DateTime _dateFacture = DateTime.now();
  DateTime _dateEcheance = DateTime.now().add(const Duration(days: 30));
  String _statut = 'brouillon';
  final _numeroFactureController = TextEditingController();
  final _montantHtController = TextEditingController();
  final _montantTtcController = TextEditingController();
  String? _chantierId;

  @override
  void initState() {
    super.initState();
    _loadClients();
    _loadDevis();
    if (widget.facture != null) {
      _numeroFactureController.text = widget.facture!.numeroFacture;
      _dateFacture = widget.facture!.dateFacture;
      _dateEcheance = widget.facture!.dateEcheance;
      _montantHtController.text = widget.facture!.montantHt.toStringAsFixed(2);
      _montantTtcController.text = widget.facture!.montantTtc.toStringAsFixed(2);
      _statut = widget.facture!.statut;
      _chantierId = widget.facture!.chantierId;
    }
  }

  @override
  void dispose() {
    _numeroFactureController.dispose();
    _montantHtController.dispose();
    _montantTtcController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _clientService.getClients();
      setState(() {
        _clients = clients;
        if (widget.facture?.clientId != null && clients.isNotEmpty) {
          try {
            _selectedClient = clients.firstWhere(
              (c) => c.id == widget.facture!.clientId,
            );
          } catch (e) {
            _selectedClient = clients.first;
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _loadDevis() async {
    try {
      final devis = await _devisService.getDevis();
      setState(() {
        final devisAcceptes = devis.where((d) => d.statut == 'accepte').toList();
        _devis = devisAcceptes;
        if (widget.facture?.devisId != null && devisAcceptes.isNotEmpty) {
          try {
            _selectedDevis = devisAcceptes.firstWhere(
              (d) => d.id == widget.facture!.devisId,
            );
          } catch (e) {
            if (devisAcceptes.isNotEmpty) {
              _selectedDevis = devisAcceptes.first;
            }
          }
        }
      });
    } catch (e) {
      // Erreur silencieuse
    }
  }

  void _onDevisSelected(Devis? devis) {
    if (devis != null) {
      setState(() {
        _selectedDevis = devis;
        _selectedClient = devis.client;
        _montantHtController.text = devis.montantHt.toStringAsFixed(2);
        _montantTtcController.text = devis.montantTtc.toStringAsFixed(2);
        _chantierId = devis.chantierId;
      });
    }
  }

  void _calculateTtc() {
    final ht = double.tryParse(_montantHtController.text) ?? 0.0;
    final ttc = ht * 1.20; // TVA 20% par défaut
    _montantTtcController.text = ttc.toStringAsFixed(2);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un client'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final facture = Facture(
        id: widget.facture?.id,
        numeroFacture: _numeroFactureController.text.trim(),
        devisId: _selectedDevis?.id,
        clientId: _selectedClient!.id!,
        dateFacture: _dateFacture,
        dateEcheance: _dateEcheance,
        montantHt: double.parse(_montantHtController.text),
        montantTtc: double.parse(_montantTtcController.text),
        statut: _statut,
        chantierId: _chantierId,
      );

      if (widget.facture?.id != null) {
        await _factureService.updateFacture(widget.facture!.id!, facture);
      } else {
        await _factureService.createFacture(facture);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.facture != null 
                ? 'Facture modifiée avec succès' 
                : 'Facture créée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
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

  Future<void> _imprimerFacture() async {
    if (widget.facture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez d\'abord sauvegarder la facture'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Charger la facture complète avec le client et le devis
      final factureComplet = await _factureService.getFactureById(widget.facture!.id!);
      Client? client;
      Devis? devis;
      
      if (factureComplet.clientId != null) {
        try {
          client = await _clientService.getClient(factureComplet.clientId!);
        } catch (e) {
          // Client non trouvé, continuer sans
        }
      }
      
      if (factureComplet.devisId != null) {
        try {
          devis = await _devisService.getDevisById(factureComplet.devisId!);
        } catch (e) {
          // Devis non trouvé, continuer sans
        }
      }

      // Générer le PDF
      final pdfDoc = FacturePdfGenerator.generateFacture(factureComplet, client: client, devis: devis);

      // Imprimer
      final success = await _printService.imprimerAvecSelection(pdfDoc);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Impression lancée' : 'Erreur lors de l\'impression'),
            backgroundColor: success ? Colors.green : Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.facture != null ? 'Modifier la facture' : 'Nouvelle facture'),
        actions: [
          if (widget.facture != null)
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _imprimerFacture,
              tooltip: 'Imprimer la facture',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Numéro de facture
                    TextFormField(
                      controller: _numeroFactureController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de facture',
                        border: OutlineInputBorder(),
                        helperText: 'Laissé vide pour génération automatique',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Client
                    DropdownButtonFormField<Client>(
                      value: _selectedClient,
                      decoration: const InputDecoration(
                        labelText: 'Client *',
                        border: OutlineInputBorder(),
                      ),
                      items: _clients.map((client) => DropdownMenuItem(
                        value: client,
                        child: Text(client.displayName),
                      )).toList(),
                      onChanged: (client) {
                        setState(() => _selectedClient = client);
                      },
                      validator: (value) => value == null ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Devis (optionnel)
                    DropdownButtonFormField<Devis>(
                      value: _selectedDevis,
                      decoration: const InputDecoration(
                        labelText: 'Devis (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<Devis>(
                          value: null,
                          child: Text('Aucun devis'),
                        ),
                        ..._devis.map((devis) => DropdownMenuItem(
                          value: devis,
                          child: Text('${devis.numeroDevis ?? devis.id} - ${devis.client?.displayName ?? ''}'),
                        )),
                      ],
                      onChanged: _onDevisSelected,
                    ),
                    const SizedBox(height: 16),
                    
                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateFacture,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => _dateFacture = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date de facture *',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(DateFormat('dd/MM/yyyy').format(_dateFacture)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateEcheance,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => _dateEcheance = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date d\'échéance *',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(DateFormat('dd/MM/yyyy').format(_dateEcheance)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Montants
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _montantHtController,
                            decoration: const InputDecoration(
                              labelText: 'Montant HT (€) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Requis';
                              if (double.tryParse(value) == null) return 'Nombre invalide';
                              return null;
                            },
                            onChanged: (_) => _calculateTtc(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _montantTtcController,
                            decoration: const InputDecoration(
                              labelText: 'Montant TTC (€) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Requis';
                              if (double.tryParse(value) == null) return 'Nombre invalide';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Statut
                    DropdownButtonFormField<String>(
                      value: _statut,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
                      ),
                      items: Facture.statutOptions.map((statut) {
                        final facture = Facture(statut: statut, numeroFacture: '', clientId: '', dateFacture: DateTime.now(), dateEcheance: DateTime.now(), montantHt: 0, montantTtc: 0);
                        return DropdownMenuItem(
                          value: statut,
                          child: Text(facture.statutLabel),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _statut = value!),
                    ),
                    const SizedBox(height: 24),
                    
                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(widget.facture != null ? 'Modifier' : 'Créer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

