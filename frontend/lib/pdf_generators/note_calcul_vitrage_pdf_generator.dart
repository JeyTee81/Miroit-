import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/vitrages/calcul_vitrage_model.dart';
import '../models/vitrages/projet_vitrage_model.dart';
import 'package:intl/intl.dart';

class NoteCalculVitragePdfGenerator {
  static pw.Document generateNoteCalcul({
    required CalculVitrage calcul,
    ProjetVitrage? projet,
    String? entetePersonnalisee,
  }) {
    final doc = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final numberFormat = NumberFormat('#,##0.00', 'fr_FR');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // En-tête
          _buildHeader(entetePersonnalisee),
          pw.SizedBox(height: 20),
          
          // Titre
          pw.Center(
            child: pw.Text(
              'NOTE DE CALCUL - ÉPAISSEUR DE VITRAGE',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 30),
          
          // Informations du projet
          if (projet != null) ...[
            _buildSectionTitle('Informations du projet'),
            pw.SizedBox(height: 10),
            _buildInfoRow('Numéro de projet:', projet.numeroProjet),
            _buildInfoRow('Nom du projet:', projet.nom),
            if (projet.chantierNom != null)
              _buildInfoRow('Chantier:', projet.chantierNom!),
            pw.SizedBox(height: 20),
          ],
          
          // Paramètres du calcul
          _buildSectionTitle('Paramètres du calcul'),
          pw.SizedBox(height: 10),
          _buildInfoRow('Type de vitrage:', calcul.typeLabel),
          _buildInfoRow('Largeur:', '${numberFormat.format(calcul.largeur)} mm'),
          _buildInfoRow('Hauteur:', '${numberFormat.format(calcul.hauteur)} mm'),
          if (calcul.regionVentDetail != null)
            _buildInfoRow('Région de vent:', '${calcul.regionVentDetail!.codeRegion} - ${calcul.regionVentDetail!.nom}'),
          if (calcul.regionNeigeDetail != null)
            _buildInfoRow('Région de neige:', '${calcul.regionNeigeDetail!.codeRegion} - ${calcul.regionNeigeDetail!.nom}'),
          if (calcul.categorieTerrainDetail != null)
            _buildInfoRow('Catégorie de terrain:', '${calcul.categorieTerrainDetail!.code} - ${calcul.categorieTerrainDetail!.nom}'),
          _buildInfoRow('Altitude:', '${numberFormat.format(calcul.altitude)} m'),
          if (calcul.pressionVent != null)
            _buildInfoRow('Pression de vent:', '${numberFormat.format(calcul.pressionVent!)} Pa'),
          if (calcul.chargeNeige != null)
            _buildInfoRow('Charge de neige:', '${numberFormat.format(calcul.chargeNeige!)} Pa'),
          _buildInfoRow('Coefficient de sécurité:', calcul.coefficientSecurite.toStringAsFixed(2)),
          pw.SizedBox(height: 20),
          
          // Normes utilisées
          _buildSectionTitle('Normes et références'),
          pw.SizedBox(height: 10),
          _buildInfoRow('Norme utilisée:', calcul.normeUtilisee),
          if (calcul.cahierCstb != null)
            _buildInfoRow('Cahier CSTB:', calcul.cahierCstb!),
          pw.SizedBox(height: 20),
          
          // Résultats
          _buildSectionTitle('Résultats du calcul'),
          pw.SizedBox(height: 10),
          if (calcul.epaisseurCalculee != null)
            _buildInfoRow(
              'Épaisseur calculée:',
              '${numberFormat.format(calcul.epaisseurCalculee!)} mm',
              isBold: true,
            ),
          if (calcul.epaisseurRecommandee != null) ...[
            pw.SizedBox(height: 5),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.green100,
                border: pw.Border.all(color: PdfColors.green700, width: 2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    'ÉPAISSEUR RECOMMANDÉE: ',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green900,
                    ),
                  ),
                  pw.Text(
                    '${numberFormat.format(calcul.epaisseurRecommandee!)} mm',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green900,
                    ),
                  ),
                ],
              ),
            ),
          ],
          pw.SizedBox(height: 20),
          
          // Détails du calcul (si disponibles)
          if (calcul.resultatCalcul != null && calcul.resultatCalcul!.isNotEmpty) ...[
            _buildSectionTitle('Détails du calcul'),
            pw.SizedBox(height: 10),
            ...calcul.resultatCalcul!.entries.map((entry) {
              if (entry.value != null) {
                String value = entry.value.toString();
                if (entry.value is num) {
                  value = numberFormat.format(entry.value);
                }
                return _buildInfoRow(
                  '${entry.key.replaceAll('_', ' ').toUpperCase()}:',
                  value,
                );
              }
              return pw.SizedBox.shrink();
            }).toList(),
            pw.SizedBox(height: 20),
          ],
          
          // Notes et avertissements
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.yellow100,
              border: pw.Border.all(color: PdfColors.yellow700),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Notes importantes:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '• Cette note de calcul est basée sur les normes ${calcul.normeUtilisee}.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  '• Les valeurs calculées sont indicatives et doivent être validées par un ingénieur qualifié.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  '• Les conditions réelles d\'installation peuvent nécessiter des ajustements.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          
          // Pied de page
          pw.Spacer(),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Date de génération: ${dateFormat.format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
              pw.Text(
                'Page ${context.pageNumber}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _buildHeader(String? entetePersonnalisee) {
    if (entetePersonnalisee != null && entetePersonnalisee.isNotEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          border: pw.Border.all(color: PdfColors.grey400),
        ),
        child: pw.Text(
          entetePersonnalisee,
          style: const pw.TextStyle(fontSize: 10),
        ),
      );
    }
    
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Miroît+ Expert',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Note de calcul - Module Vitrages',
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




