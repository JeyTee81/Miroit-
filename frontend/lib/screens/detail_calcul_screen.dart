import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/travaux/ligne_devis_travaux_model.dart';
import '../models/travaux/ligne_facture_travaux_model.dart';

class DetailCalculScreen extends StatefulWidget {
  final dynamic ligne; // LigneDevisTravaux ou LigneFactureTravaux
  final Function(dynamic) onSave;

  const DetailCalculScreen({super.key, required this.ligne, required this.onSave});

  @override
  State<DetailCalculScreen> createState() => _DetailCalculScreenState();
}

class _DetailCalculScreenState extends State<DetailCalculScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heuresController = TextEditingController();
  final _tauxHoraireController = TextEditingController();
  final List<Map<String, dynamic>> _materiaux = [];
  final List<Map<String, dynamic>> _autres = [];

  @override
  void initState() {
    super.initState();
    _loadDetailCalcul();
  }

  @override
  void dispose() {
    _heuresController.dispose();
    _tauxHoraireController.dispose();
    super.dispose();
  }

  void _loadDetailCalcul() {
    final detail = widget.ligne.detailCalcul;
    if (detail != null) {
      if (detail['main_oeuvre'] != null) {
        _heuresController.text = (detail['main_oeuvre']['heures'] ?? 0).toString();
        _tauxHoraireController.text = (detail['main_oeuvre']['taux'] ?? 0).toString();
      }
      if (detail['materiaux'] != null && detail['materiaux'] is List) {
        _materiaux.addAll(List<Map<String, dynamic>>.from(detail['materiaux']));
      }
      if (detail['autres'] != null && detail['autres'] is List) {
        _autres.addAll(List<Map<String, dynamic>>.from(detail['autres']));
      }
    }
  }

  void _save() {
    final heures = double.tryParse(_heuresController.text) ?? 0;
    final taux = double.tryParse(_tauxHoraireController.text) ?? 0;
    final mainOeuvre = heures * taux;

    final totalMateriaux = _materiaux.fold<double>(0, (sum, m) => sum + (m['prix'] as num? ?? 0).toDouble());
    final totalAutres = _autres.fold<double>(0, (sum, a) => sum + (a['prix'] as num? ?? 0).toDouble());

    final prixUnitaireHt = mainOeuvre + totalMateriaux + totalAutres;

    final detailCalcul = {
      'main_oeuvre': {
        'heures': heures,
        'taux': taux,
        'total': mainOeuvre,
      },
      'materiaux': _materiaux,
      'autres': _autres,
      'total': prixUnitaireHt,
    };

    // Créer une nouvelle ligne avec le détail calculé
    dynamic updatedLigne;
    if (widget.ligne is LigneDevisTravaux) {
      final ligne = widget.ligne as LigneDevisTravaux;
      updatedLigne = LigneDevisTravaux(
        id: ligne.id,
        devisId: ligne.devisId,
        designation: ligne.designation,
        description: ligne.description,
        quantite: ligne.quantite,
        unite: ligne.unite,
        prixUnitaireHt: prixUnitaireHt,
        montantHt: ligne.quantite * prixUnitaireHt,
        tauxTva: ligne.tauxTva,
        montantTtc: ligne.quantite * prixUnitaireHt * (1 + ligne.tauxTva / 100),
        detailCalcul: detailCalcul,
        ordre: ligne.ordre,
      );
    } else {
      final ligne = widget.ligne as LigneFactureTravaux;
      updatedLigne = LigneFactureTravaux(
        id: ligne.id,
        factureId: ligne.factureId,
        designation: ligne.designation,
        description: ligne.description,
        quantite: ligne.quantite,
        unite: ligne.unite,
        prixUnitaireHt: prixUnitaireHt,
        montantHt: ligne.quantite * prixUnitaireHt,
        tauxTva: ligne.tauxTva,
        montantTtc: ligne.quantite * prixUnitaireHt * (1 + ligne.tauxTva / 100),
        detailCalcul: detailCalcul,
        ordre: ligne.ordre,
      );
    }

    widget.onSave(updatedLigne);
    Navigator.pop(context);
  }

  void _addMateriau() {
    showDialog(
      context: context,
      builder: (context) => _ItemEditDialog(
        title: 'Ajouter un matériau',
        onSave: (item) {
          setState(() {
            _materiaux.add(item);
          });
        },
      ),
    );
  }

  void _editMateriau(int index) {
    showDialog(
      context: context,
      builder: (context) => _ItemEditDialog(
        title: 'Modifier le matériau',
        item: _materiaux[index],
        onSave: (item) {
          setState(() {
            _materiaux[index] = item;
          });
        },
      ),
    );
  }

  void _deleteMateriau(int index) {
    setState(() {
      _materiaux.removeAt(index);
    });
  }

  void _addAutre() {
    showDialog(
      context: context,
      builder: (context) => _ItemEditDialog(
        title: 'Ajouter un autre élément',
        onSave: (item) {
          setState(() {
            _autres.add(item);
          });
        },
      ),
    );
  }

  void _editAutre(int index) {
    showDialog(
      context: context,
      builder: (context) => _ItemEditDialog(
        title: 'Modifier l\'élément',
        item: _autres[index],
        onSave: (item) {
          setState(() {
            _autres[index] = item;
          });
        },
      ),
    );
  }

  void _deleteAutre(int index) {
    setState(() {
      _autres.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final heures = double.tryParse(_heuresController.text) ?? 0;
    final taux = double.tryParse(_tauxHoraireController.text) ?? 0;
    final mainOeuvre = heures * taux;
    final totalMateriaux = _materiaux.fold<double>(0, (sum, m) => sum + (m['prix'] as num? ?? 0).toDouble());
    final totalAutres = _autres.fold<double>(0, (sum, a) => sum + (a['prix'] as num? ?? 0).toDouble());
    final total = mainOeuvre + totalMateriaux + totalAutres;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du calcul'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main d'œuvre
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Main d\'œuvre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _heuresController,
                              decoration: const InputDecoration(
                                labelText: 'Heures',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _tauxHoraireController,
                              decoration: const InputDecoration(
                                labelText: 'Taux horaire (€)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(mainOeuvre)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Matériaux
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Matériaux', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addMateriau,
                          ),
                        ],
                      ),
                      if (_materiaux.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('Aucun matériau')),
                        )
                      else
                        ...List.generate(_materiaux.length, (index) {
                          final m = _materiaux[index];
                          return ListTile(
                            title: Text(m['designation'] ?? ''),
                            subtitle: Text(NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(m['prix'] ?? 0)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _editMateriau(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => _deleteMateriau(index),
                                ),
                              ],
                            ),
                          );
                        }),
                      if (_materiaux.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Total: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(totalMateriaux)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Autres
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Autres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addAutre,
                          ),
                        ],
                      ),
                      if (_autres.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('Aucun élément')),
                        )
                      else
                        ...List.generate(_autres.length, (index) {
                          final a = _autres[index];
                          return ListTile(
                            title: Text(a['designation'] ?? ''),
                            subtitle: Text(NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(a['prix'] ?? 0)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _editAutre(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => _deleteAutre(index),
                                ),
                              ],
                            ),
                          );
                        }),
                      if (_autres.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Total: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(totalAutres)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Total
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Prix unitaire HT:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(
                        NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(total),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

class _ItemEditDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? item;
  final Function(Map<String, dynamic>) onSave;

  const _ItemEditDialog({required this.title, this.item, required this.onSave});

  @override
  State<_ItemEditDialog> createState() => _ItemEditDialogState();
}

class _ItemEditDialogState extends State<_ItemEditDialog> {
  final _designationController = TextEditingController();
  final _prixController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _designationController.text = widget.item!['designation'] ?? '';
      _prixController.text = (widget.item!['prix'] ?? 0).toString();
    }
  }

  @override
  void dispose() {
    _designationController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave({
      'designation': _designationController.text,
      'prix': double.tryParse(_prixController.text) ?? 0,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _designationController,
            decoration: const InputDecoration(labelText: 'Désignation *'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _prixController,
            decoration: const InputDecoration(labelText: 'Prix (€) *'),
            keyboardType: TextInputType.number,
          ),
        ],
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




