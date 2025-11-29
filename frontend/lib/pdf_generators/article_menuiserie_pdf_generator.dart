import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/menuiserie/article_model.dart';
import '../models/menuiserie/projet_model.dart';

class ArticleMenuiseriePdfGenerator {
  static pw.Document generateArticle(Article article, {Projet? projet}) {
    final doc = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // En-tête
          _buildHeader('ARTICLE MENUISERIE'),
          pw.SizedBox(height: 20),
          
          // Informations projet
          if (projet != null) ...[
            pw.Text('Projet: ${projet.numeroProjet} - ${projet.nom}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
          ],
          
          // Informations article
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey800),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Désignation:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text(article.designationGeneree ?? article.designation, style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Type:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text(article.typeArticle, style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Dimensions:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text('${article.largeur} × ${article.hauteur} mm', style: const pw.TextStyle(fontSize: 10)),
                          if (article.profondeur != null)
                            pw.Text('Profondeur: ${article.profondeur} mm', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Quantité:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text('${article.quantite}', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Prix unitaire HT:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text(currencyFormat.format(article.prixCalcule ?? article.prixUnitaireHt), style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Prix total HT:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text(currencyFormat.format((article.prixCalcule ?? article.prixUnitaireHt) * article.quantite), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Options obligatoires
          if (article.optionsObligatoires != null && article.optionsObligatoires!.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Text('Options obligatoires:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            ...article.optionsObligatoires!.map((opt) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
              child: pw.Text('• ${opt}', style: const pw.TextStyle(fontSize: 10)),
            )),
          ],
          
          // Options facultatives
          if (article.optionsFacultatives != null && article.optionsFacultatives!.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text('Options facultatives:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            ...article.optionsFacultatives!.map((opt) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
              child: pw.Text('• ${opt}', style: const pw.TextStyle(fontSize: 10)),
            )),
          ],
          
          // Échelle dessin
          if (article.echelleDessin != null) ...[
            pw.SizedBox(height: 20),
            pw.Text('Échelle du dessin: ${article.echelleDessin}', style: const pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
          ],
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
}

