import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/imprimante_model.dart';
import 'imprimante_service.dart';

class PrintService {
  final ImprimanteService _imprimanteService = ImprimanteService();

  /// Imprime un document PDF
  /// 
  /// [document] : Le document PDF à imprimer
  /// [imprimanteId] : ID de l'imprimante à utiliser (optionnel, utilise l'imprimante par défaut si null)
  /// [copies] : Nombre de copies (défaut: 1)
  /// [format] : Format de papier (défaut: PdfPageFormat.a4)
  Future<bool> imprimerDocument(
    pw.Document document, {
    String? imprimanteId,
    int copies = 1,
    PdfPageFormat? format,
  }) async {
    try {
      // Récupérer l'imprimante
      Imprimante? imprimante;
      if (imprimanteId != null) {
        imprimante = await _imprimanteService.getImprimanteById(imprimanteId);
      } else {
        imprimante = await _imprimanteService.getImprimanteParDefaut();
      }

      // Déterminer le format avec l'orientation
      PdfPageFormat pageFormat = format ?? _getPageFormat(imprimante);

      // Utiliser le package printing pour imprimer
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => document.save(),
        format: pageFormat,
      );

      return true;
    } catch (e) {
      print('Erreur lors de l\'impression: $e');
      return false;
    }
  }

  /// Imprime directement vers une imprimante réseau (sans dialogue)
  /// 
  /// Cette méthode est utilisée pour les imprimantes réseau configurées
  Future<bool> imprimerDirect(
    pw.Document document,
    Imprimante imprimante, {
    int copies = 1,
  }) async {
    try {
      if (imprimante.typeImprimante == 'reseau') {
        // Pour les imprimantes réseau, on peut utiliser une connexion directe
        // Note: Cette fonctionnalité nécessite une implémentation spécifique selon le protocole
        // Pour l'instant, on utilise le dialogue d'impression standard
        return await imprimerDocument(
          document,
          imprimanteId: imprimante.id,
          copies: copies,
        );
      } else {
        // Pour les imprimantes locales, utiliser le dialogue système
        return await imprimerDocument(
          document,
          imprimanteId: imprimante.id,
          copies: copies,
        );
      }
    } catch (e) {
      print('Erreur lors de l\'impression directe: $e');
      return false;
    }
  }

  /// Affiche le dialogue d'impression avec sélection d'imprimante
  Future<bool> imprimerAvecSelection(
    pw.Document document, {
    int copies = 1,
  }) async {
    try {
      // Utiliser le dialogue d'impression du système
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => document.save(),
      );
      return true;
    } catch (e) {
      print('Erreur lors de l\'impression: $e');
      return false;
    }
  }

  /// Partage le document (peut être utilisé pour imprimer via d'autres applications)
  Future<bool> partagerDocument(pw.Document document) async {
    try {
      await Printing.sharePdf(
        bytes: await document.save(),
        filename: 'document.pdf',
      );
      return true;
    } catch (e) {
      print('Erreur lors du partage: $e');
      return false;
    }
  }

  /// Convertit le document en bytes pour sauvegarde ou envoi
  Future<List<int>> documentEnBytes(pw.Document document) async {
    return await document.save();
  }

  PdfPageFormat _getPageFormat(Imprimante? imprimante) {
    PdfPageFormat baseFormat;
    
    if (imprimante == null) {
      baseFormat = PdfPageFormat.a4;
    } else {
      switch (imprimante.formatPapier) {
        case 'A4':
          baseFormat = PdfPageFormat.a4;
          break;
        case 'A3':
          baseFormat = PdfPageFormat.a3;
          break;
        case 'Letter':
          baseFormat = PdfPageFormat.letter;
          break;
        case 'Legal':
          baseFormat = PdfPageFormat.legal;
          break;
        default:
          baseFormat = PdfPageFormat.a4;
      }
    }

    // Ajuster l'orientation si nécessaire
    if (imprimante != null && imprimante.orientation == 'paysage') {
      // Pour le paysage, inverser largeur et hauteur
      return PdfPageFormat(
        baseFormat.height,
        baseFormat.width,
        marginAll: baseFormat.marginTop,
      );
    }

    return baseFormat;
  }
}

