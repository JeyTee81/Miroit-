import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/inertie/calcul_raidisseur_model.dart';
import '../models/inertie/calcul_traverse_model.dart';
import '../models/inertie/calcul_ei_model.dart';
import '../models/inertie/projet_model.dart';

class InertiePdfGenerator {
  static pw.Document generateCalculRaidisseur(CalculRaidisseur calcul, {ProjetInertie? projet}) {
    final doc = pw.Document();
    final numberFormat = NumberFormat.decimalPattern('fr_FR');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader('CALCUL RAIDISSEUR'),
          pw.SizedBox(height: 20),
          
          if (projet != null) ...[
            pw.Text('Projet: ${projet.numeroProjet} - ${projet.nom}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
          ],
          
          // Données d'entrée
          pw.Text('Données d\'entrée:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildDataTable([
            ['Portée', '${numberFormat.format(calcul.portee)} mm'],
            ['Trame', '${numberFormat.format(calcul.trame)} mm'],
            ['Type de charge', calcul.typeChargeLabel],
            ['Module d\'élasticité', '${numberFormat.format(calcul.moduleElasticite)} daN/mm²'],
            ['Fleche max', '${numberFormat.format(calcul.flecheMax)} mm'],
          ]),
          
          pw.SizedBox(height: 20),
          
          // Résultats
          pw.Text('Résultats:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildDataTable([
            ['Pression vent', '${numberFormat.format(calcul.pressionVent)} daN/m²'],
            ['Inertie requise', '${numberFormat.format(calcul.inertieRequise)} mm⁴'],
            ['Profil sélectionné', calcul.profilSelectionne ?? 'N/A'],
          ]),
        ],
      ),
    );

    return doc;
  }

  static pw.Document generateCalculTraverse(CalculTraverse calcul, {ProjetInertie? projet}) {
    final doc = pw.Document();
    final numberFormat = NumberFormat.decimalPattern('fr_FR');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader('CALCUL TRAVERSE'),
          pw.SizedBox(height: 20),
          
          if (projet != null) ...[
            pw.Text('Projet: ${projet.numeroProjet} - ${projet.nom}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
          ],
          
          // Données d'entrée
          pw.Text('Données d\'entrée:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildDataTable([
            ['Portée', '${numberFormat.format(calcul.portee)} mm'],
            ['Trame', '${numberFormat.format(calcul.trame)} mm'],
            ['Type de charge', calcul.typeChargeLabel],
            ['Module d\'élasticité', '${numberFormat.format(calcul.moduleElasticite)} daN/mm²'],
            ['Fleche max', '${numberFormat.format(calcul.flecheMax)} mm'],
          ]),
          
          pw.SizedBox(height: 20),
          
          // Résultats
          pw.Text('Résultats:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildDataTable([
            ['Pression vent', '${numberFormat.format(calcul.pressionVent)} daN/m²'],
            ['Inertie requise', '${numberFormat.format(calcul.inertieRequise)} mm⁴'],
            ['Profil sélectionné', calcul.profilSelectionne ?? 'N/A'],
          ]),
        ],
      ),
    );

    return doc;
  }

  static pw.Document generateCalculEI(CalculEI calcul, {ProjetInertie? projet}) {
    final doc = pw.Document();
    final numberFormat = NumberFormat.decimalPattern('fr_FR');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader('CALCUL EI'),
          pw.SizedBox(height: 20),
          
          if (projet != null) ...[
            pw.Text('Projet: ${projet.numeroProjet} - ${projet.nom}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
          ],
          
          // Données d'entrée
          pw.Text('Données d\'entrée:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildDataTable([
            ['Portée', '${numberFormat.format(calcul.portee)} mm'],
            ['Trame', '${numberFormat.format(calcul.trame)} mm'],
            ['Module d\'élasticité', '${numberFormat.format(calcul.moduleElasticite)} daN/mm²'],
            ['Fleche admissible', '${numberFormat.format(calcul.flecheAdmissible)} mm'],
          ]),
          
          pw.SizedBox(height: 20),
          
          // Résultats
          pw.Text('Résultats:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildDataTable([
            ['EI requis', calcul.eiRequise != null ? '${numberFormat.format(calcul.eiRequise!)} daN.mm²' : 'N/A'],
            ['Profil sélectionné', calcul.profilSelectionneCode ?? 'N/A'],
          ]),
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

  static pw.Widget _buildDataTable(List<List<String>> data) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey800),
      ),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400),
        children: data.map((row) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[0], style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(row[1], style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        )).toList(),
      ),
    );
  }
}

