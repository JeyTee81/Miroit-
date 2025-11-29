import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/facture_model.dart';
import '../models/client_model.dart';
import '../models/devis_model.dart';

class FacturePdfGenerator {
  static pw.Document generateFacture(Facture facture, {Client? client, Devis? devis}) {
    final doc = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // En-tête
          _buildHeader('FACTURE'),
          pw.SizedBox(height: 20),
          
          // Informations facture
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('N° Facture: ${facture.numeroFacture}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text('Date: ${dateFormat.format(facture.dateFacture)}'),
                  pw.Text('Échéance: ${dateFormat.format(facture.dateEcheance)}'),
                  if (facture.devisId != null) pw.Text('Devis: ${facture.devisId}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (client != null) ...[
                    pw.Text(client.displayName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    if (client.adresse != null) pw.Text(client.adresse!, style: const pw.TextStyle(fontSize: 10)),
                    if (client.codePostal != null && client.ville != null)
                      pw.Text('${client.codePostal} ${client.ville}', style: const pw.TextStyle(fontSize: 10)),
                  ] else if (facture.clientNom != null) ...[
                    pw.Text(facture.clientNom!, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          
          // Lignes de la facture (depuis le devis associé)
          if (devis != null && devis.lignes != null && devis.lignes!.isNotEmpty) ...[
            _buildTableHeader(),
            ...devis.lignes!.map((ligne) => _buildTableRowFromLigneDevis(ligne, currencyFormat)),
            pw.SizedBox(height: 20),
          ] else ...[
            // Si pas de devis, afficher juste le total
            pw.Text('Facture basée sur le devis ${facture.devisId ?? "N/A"}', style: const pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.SizedBox(height: 20),
          ],
          
          // Totaux
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 250,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total HT:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text(currencyFormat.format(facture.montantHt), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('TVA:', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text(currencyFormat.format(facture.montantTtc - facture.montantHt)),
                    ],
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total TTC:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text(currencyFormat.format(facture.montantTtc), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  if (facture.montantPaye > 0) ...[
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Montant payé:', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(currencyFormat.format(facture.montantPaye)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Reste à payer:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                        pw.Text(currencyFormat.format(facture.montantRestant ?? (facture.montantTtc - facture.montantPaye)), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey300,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        border: pw.Border.all(color: PdfColors.grey800),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 3, child: pw.Text('Désignation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(flex: 1, child: pw.Text('Qté', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
          pw.Expanded(flex: 1, child: pw.Text('P.U. HT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          pw.Expanded(flex: 1, child: pw.Text('Total HT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
        ],
      ),
    );
  }

  static pw.Widget _buildTableRowFromLigneDevis(LigneDevis ligne, NumberFormat currencyFormat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 3, child: pw.Text(ligne.designation, style: const pw.TextStyle(fontSize: 10))),
          pw.Expanded(flex: 1, child: pw.Text(ligne.quantite.toStringAsFixed(2), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10))),
          pw.Expanded(flex: 1, child: pw.Text(currencyFormat.format(ligne.prixUnitaireHt), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10))),
          pw.Expanded(flex: 1, child: pw.Text(currencyFormat.format(ligne.montantHt), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }
}

