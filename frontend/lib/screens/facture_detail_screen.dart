import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/facture_model.dart';
import '../models/paiement_model.dart';
import '../services/facture_service.dart';

class FactureDetailScreen extends StatefulWidget {
  final Facture facture;

  const FactureDetailScreen({super.key, required this.facture});

  @override
  State<FactureDetailScreen> createState() => _FactureDetailScreenState();
}

class _FactureDetailScreenState extends State<FactureDetailScreen> {
  final FactureService _factureService = FactureService();
  Facture? _facture;
  List<Paiement> _paiements = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _facture = widget.facture;
    _loadPaiements();
  }

  Future<void> _loadPaiements() async {
    if (_facture?.id == null) return;
    
    setState(() => _isLoading = true);
    try {
      final paiements = await _factureService.getPaiements(_facture!.id!);
      final factureUpdated = await _factureService.getFactureById(_facture!.id!);
      setState(() {
        _paiements = paiements;
        _facture = factureUpdated;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  Future<void> _showAddPaiementDialog() async {
    final montantController = TextEditingController();
    final numeroPieceController = TextEditingController();
    DateTime datePaiement = DateTime.now();
    String modePaiement = 'virement';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Enregistrer un paiement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: montantController,
                  decoration: const InputDecoration(
                    labelText: 'Montant (€) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: datePaiement,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setDialogState(() => datePaiement = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date de paiement *',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(datePaiement)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: modePaiement,
                  decoration: const InputDecoration(
                    labelText: 'Mode de paiement *',
                    border: OutlineInputBorder(),
                  ),
                  items: Paiement.modePaiementOptions.map((mode) {
                    final paiement = Paiement(
                      factureId: '',
                      montant: 0,
                      datePaiement: DateTime.now(),
                      modePaiement: mode,
                    );
                    return DropdownMenuItem(
                      value: mode,
                      child: Row(
                        children: [
                          Icon(paiement.modePaiementIcon, size: 20),
                          const SizedBox(width: 8),
                          Text(paiement.modePaiementLabel),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => modePaiement = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: numeroPieceController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de pièce (optionnel)',
                    border: OutlineInputBorder(),
                    helperText: 'Ex: numéro de chèque, référence virement',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (montantController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez saisir un montant'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                final montant = double.tryParse(montantController.text);
                if (montant == null || montant <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Montant invalide'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );

    if (result == true && _facture?.id != null) {
      final montant = double.parse(montantController.text);
      final paiement = Paiement(
        factureId: _facture!.id!,
        montant: montant,
        datePaiement: datePaiement,
        modePaiement: modePaiement,
        numeroPiece: numeroPieceController.text.trim().isEmpty 
            ? null 
            : numeroPieceController.text.trim(),
      );

      setState(() => _isLoading = true);
      try {
        await _factureService.enregistrerPaiement(_facture!.id!, paiement);
        await _loadPaiements();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paiement enregistré avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    if (_facture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final montantRestant = _facture!.montantRestant ?? 
        (_facture!.montantTtc - _facture!.montantPaye);

    return Scaffold(
      appBar: AppBar(
        title: Text('Facture ${_facture!.numeroFacture}'),
        actions: [
          if (_facture!.statut != 'payee' && montantRestant > 0)
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: _showAddPaiementDialog,
              tooltip: 'Enregistrer un paiement',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Informations facture
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Facture ${_facture!.numeroFacture}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _facture!.statutColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _facture!.statutLabel,
                                  style: TextStyle(
                                    color: _facture!.statutColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Client', _facture!.clientNom ?? 'N/A'),
                          _buildInfoRow('Date de facture', DateFormat('dd/MM/yyyy').format(_facture!.dateFacture)),
                          _buildInfoRow('Date d\'échéance', DateFormat('dd/MM/yyyy').format(_facture!.dateEcheance)),
                          const Divider(),
                          _buildInfoRow('Montant HT', '${_facture!.montantHt.toStringAsFixed(2)} €'),
                          _buildInfoRow('Montant TTC', '${_facture!.montantTtc.toStringAsFixed(2)} €'),
                          _buildInfoRow('Montant payé', '${_facture!.montantPaye.toStringAsFixed(2)} €'),
                          _buildInfoRow(
                            'Montant restant',
                            '${montantRestant.toStringAsFixed(2)} €',
                            color: montantRestant > 0 ? Colors.orange.shade700 : Colors.green.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Section paiements
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Paiements',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_facture!.statut != 'payee' && montantRestant > 0)
                        ElevatedButton.icon(
                          onPressed: _showAddPaiementDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un paiement'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_paiements.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.payment_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun paiement enregistré',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ..._paiements.map((paiement) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(
                            paiement.modePaiementIcon,
                            color: Colors.green.shade700,
                          ),
                        ),
                        title: Text(
                          paiement.modePaiementLabel,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('dd/MM/yyyy').format(paiement.datePaiement)),
                            if (paiement.numeroPiece != null)
                              Text(
                                'N°: ${paiement.numeroPiece}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Text(
                          '${paiement.montant.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    )),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

