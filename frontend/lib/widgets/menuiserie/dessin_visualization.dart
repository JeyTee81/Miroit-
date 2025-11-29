import 'package:flutter/material.dart';
import '../../models/menuiserie/option_menuiserie_model.dart';

class DessinVisualization extends StatelessWidget {
  final double largeur;
  final double hauteur;
  final String echelle;
  final List<String> optionsObligatoires;
  final List<String> optionsFacultatives;
  final List<OptionMenuiserie> optionsDetails;

  const DessinVisualization({
    super.key,
    required this.largeur,
    required this.hauteur,
    required this.echelle,
    required this.optionsObligatoires,
    required this.optionsFacultatives,
    required this.optionsDetails,
  });

  double _parseEchelle(String echelleStr) {
    try {
      final parts = echelleStr.split(':');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0]);
        final den = double.tryParse(parts[1]);
        if (num != null && den != null && den != 0) {
          return num / den;
        }
      }
    } catch (e) {
      // Ignorer les erreurs de parsing
    }
    return 1.0; // Par défaut 1:1
  }

  @override
  Widget build(BuildContext context) {
    final echelleValue = _parseEchelle(echelle);
    
    // Dimensions en pixels pour l'affichage (max 400px)
    const maxSize = 400.0;
    final ratio = largeur / hauteur;
    double width, height;
    
    if (ratio > 1) {
      // Plus large que haut
      width = maxSize;
      height = maxSize / ratio;
    } else {
      // Plus haut que large
      height = maxSize;
      width = maxSize * ratio;
    }

    // Appliquer l'échelle
    width *= echelleValue;
    height *= echelleValue;

    // Récupérer les options sélectionnées avec leurs détails
    final selectedOptions = optionsDetails.where((opt) =>
      optionsObligatoires.contains(opt.id) || optionsFacultatives.contains(opt.id)
    ).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dessin à l\'échelle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Échelle: $echelle',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: CustomPaint(
              size: Size(width, height),
              painter: DessinPainter(
                largeur: largeur,
                hauteur: hauteur,
                options: selectedOptions,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dimensions: ${largeur.toStringAsFixed(0)} x ${hauteur.toStringAsFixed(0)} cm',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (selectedOptions.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Options appliquées:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...selectedOptions.map((opt) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Row(
                children: [
                  Icon(
                    opt.typeOption == 'obligatoire' 
                        ? Icons.check_circle 
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color: opt.typeOption == 'obligatoire' 
                        ? Colors.red 
                        : Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    opt.libelle,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class DessinPainter extends CustomPainter {
  final double largeur;
  final double hauteur;
  final List<OptionMenuiserie> options;

  DessinPainter({
    required this.largeur,
    required this.hauteur,
    required this.options,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Dessiner le rectangle principal
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, paint);

    // Dessiner les dimensions
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${largeur.toStringAsFixed(0)} cm',
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, -16));

    final textPainter2 = TextPainter(
      text: TextSpan(
        text: '${hauteur.toStringAsFixed(0)} cm',
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout();
    canvas.save();
    canvas.translate(-20, size.height / 2 - textPainter2.height / 2);
    canvas.rotate(-1.5708); // -90 degrés
    textPainter2.paint(canvas, Offset.zero);
    canvas.restore();

    // Dessiner les éléments des options
    for (final option in options) {
      if (option.impactDessin != null && option.impactDessin!.isNotEmpty) {
        _drawOptionElement(canvas, size, option);
      }
    }
  }

  void _drawOptionElement(Canvas canvas, Size size, OptionMenuiserie option) {
    final impact = option.impactDessin!;
    final elementType = impact['ajout_element']?.toString() ?? '';
    final position = impact['position']?.toString() ?? 'bas';

    final paint = Paint()
      ..color = option.typeOption == 'obligatoire' ? Colors.red : Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    switch (elementType) {
      case 'ferrage':
        _drawFerrage(canvas, size, position, paint);
        break;
      case 'petits_bois':
        _drawPetitsBois(canvas, size, paint);
        break;
      // Ajouter d'autres types d'éléments si nécessaire
    }
  }

  void _drawFerrage(Canvas canvas, Size size, String position, Paint paint) {
    // Dessiner un ferrage (petit rectangle) selon la position
    double x, y;
    const ferrageSize = 20.0;

    switch (position) {
      case 'bas':
        x = size.width / 2 - ferrageSize / 2;
        y = size.height - ferrageSize - 5;
        break;
      case 'haut':
        x = size.width / 2 - ferrageSize / 2;
        y = 5;
        break;
      case 'gauche':
        x = 5;
        y = size.height / 2 - ferrageSize / 2;
        break;
      case 'droit':
        x = size.width - ferrageSize - 5;
        y = size.height / 2 - ferrageSize / 2;
        break;
      default:
        x = size.width / 2 - ferrageSize / 2;
        y = size.height - ferrageSize - 5;
    }

    canvas.drawRect(
      Rect.fromLTWH(x, y, ferrageSize, ferrageSize),
      paint,
    );
  }

  void _drawPetitsBois(Canvas canvas, Size size, Paint paint) {
    // Dessiner des petits bois (lignes verticales et horizontales)
    final nbVertical = 3;
    final nbHorizontal = 2;

    // Lignes verticales
    for (int i = 1; i < nbVertical; i++) {
      final x = size.width * i / nbVertical;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Lignes horizontales
    for (int i = 1; i < nbHorizontal; i++) {
      final y = size.height * i / nbHorizontal;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}




