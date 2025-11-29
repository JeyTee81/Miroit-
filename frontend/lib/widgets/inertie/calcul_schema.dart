import 'package:flutter/material.dart';

/// Widget pour afficher un schéma de calcul (raidisseur, traverse, etc.)
class CalculSchema extends StatelessWidget {
  final String typeCalcul; // 'raidisseur', 'traverse', 'ei'
  final Map<String, dynamic>? parametres;
  final Map<String, dynamic>? resultats;
  final double width;
  final double height;

  const CalculSchema({
    super.key,
    required this.typeCalcul,
    this.parametres,
    this.resultats,
    this.width = 400,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: CustomPaint(
        painter: CalculSchemaPainter(
          typeCalcul: typeCalcul,
          parametres: parametres,
          resultats: resultats,
        ),
        child: Container(),
      ),
    );
  }
}

class CalculSchemaPainter extends CustomPainter {
  final String typeCalcul;
  final Map<String, dynamic>? parametres;
  final Map<String, dynamic>? resultats;

  CalculSchemaPainter({
    required this.typeCalcul,
    this.parametres,
    this.resultats,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (typeCalcul) {
      case 'raidisseur':
        _drawRaidisseur(canvas, size);
        break;
      case 'traverse':
        _drawTraverse(canvas, size);
        break;
      case 'ei':
        _drawEI(canvas, size);
        break;
    }
  }

  void _drawRaidisseur(Canvas canvas, Size size) {
    final margin = 30.0;
    final availableWidth = size.width - 2 * margin;

    final portee = parametres?['portee'] ?? 2000.0; // mm
    final trame = parametres?['trame'] ?? 1000.0; // mm
    final typeCharge = parametres?['type_charge'] ?? 'rectangulaire_2_appuis';
    final fleche = resultats?['fleche'] ?? 0.0;

    // Échelle
    final scale = availableWidth / portee;

    final startX = margin;
    final startY = size.height / 2;
    final endX = startX + portee * scale;

    // Dessiner la poutre
    final beamPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, startY),
      beamPaint,
    );

    // Dessiner les appuis selon le type
    final supportPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.fill;

    if (typeCharge == 'rectangulaire_2_appuis' || 
        typeCharge == 'rectangulaire_3_appuis') {
      // Appui simple (triangle)
      _drawSupport(canvas, Offset(startX, startY), supportPaint);
      _drawSupport(canvas, Offset(endX, startY), supportPaint);
      
      if (typeCharge == 'rectangulaire_3_appuis') {
        _drawSupport(canvas, Offset((startX + endX) / 2, startY), supportPaint);
      }
    } else if (typeCharge == 'encastrement_appui') {
      // Encastrement (rectangle)
      _drawFixedSupport(canvas, Offset(startX, startY), supportPaint);
      _drawSupport(canvas, Offset(endX, startY), supportPaint);
    }

    // Dessiner la charge répartie
    final loadPaint = Paint()
      ..color = Colors.red.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final arrowLength = 20.0;
    final numArrows = 10;
    final arrowSpacing = availableWidth / (numArrows + 1);

    for (int i = 1; i <= numArrows; i++) {
      final x = startX + arrowSpacing * i;
      canvas.drawLine(
        Offset(x, startY - arrowLength),
        Offset(x, startY),
        loadPaint,
      );
      // Pointe de flèche
      canvas.drawLine(
        Offset(x, startY - arrowLength),
        Offset(x - 3, startY - arrowLength + 5),
        loadPaint,
      );
      canvas.drawLine(
        Offset(x, startY - arrowLength),
        Offset(x + 3, startY - arrowLength + 5),
        loadPaint,
      );
    }

    // Dessiner la flèche si disponible
    if (fleche > 0) {
      final flechePaint = Paint()
        ..color = Colors.green.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final flecheY = startY + fleche * scale * 0.1; // Échelle réduite pour la flèche
      final flecheX = (startX + endX) / 2;

      // Ligne de flèche
      canvas.drawLine(
        Offset(flecheX, startY),
        Offset(flecheX, flecheY),
        flechePaint,
      );

      // Arc de flèche
      final path = Path();
      path.moveTo(flecheX, startY);
      path.quadraticBezierTo(
        flecheX - 10,
        (startY + flecheY) / 2,
        flecheX,
        flecheY,
      );
      canvas.drawPath(path, flechePaint);

      // Texte flèche
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'f = ${fleche.toStringAsFixed(1)} mm',
          style: TextStyle(color: Colors.green.shade700, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(flecheX + 5, (startY + flecheY) / 2 - textPainter.height / 2));
    }

    // Labels
    final textStyle = TextStyle(color: Colors.black87, fontSize: 10);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(text: 'L = ${(portee / 1000).toStringAsFixed(2)} m', style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset((startX + endX) / 2 - textPainter.width / 2, startY + 15));

    textPainter.text = TextSpan(text: 'Trame = ${(trame / 1000).toStringAsFixed(2)} m', style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(startX, startY - 40));
  }

  void _drawTraverse(Canvas canvas, Size size) {
    final margin = 30.0;
    final availableWidth = size.width - 2 * margin;

    final portee = parametres?['portee'] ?? 2000.0;
    final scale = availableWidth / portee;

    final startX = margin;
    final startY = size.height / 2;
    final endX = startX + portee * scale;

    // Dessiner la traverse
    final beamPaint = Paint()
      ..color = Colors.orange.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, startY),
      beamPaint,
    );

    // Appuis
    final supportPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.fill;

    _drawSupport(canvas, Offset(startX, startY), supportPaint);
    _drawSupport(canvas, Offset(endX, startY), supportPaint);

    // Charges verticales (poids)
    final loadPaint = Paint()
      ..color = Colors.red.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final arrowLength = 30.0;
    final numArrows = 8;
    final arrowSpacing = availableWidth / (numArrows + 1);

    for (int i = 1; i <= numArrows; i++) {
      final x = startX + arrowSpacing * i;
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + arrowLength),
        loadPaint,
      );
      // Pointe de flèche
      canvas.drawLine(
        Offset(x, startY + arrowLength),
        Offset(x - 3, startY + arrowLength - 5),
        loadPaint,
      );
      canvas.drawLine(
        Offset(x, startY + arrowLength),
        Offset(x + 3, startY + arrowLength - 5),
        loadPaint,
      );
    }

    // Labels
    final textStyle = TextStyle(color: Colors.black87, fontSize: 10);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(text: 'Portée = ${(portee / 1000).toStringAsFixed(2)} m', style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset((startX + endX) / 2 - textPainter.width / 2, startY + 15));
  }

  void _drawEI(Canvas canvas, Size size) {
    // Schéma simplifié pour calcul EI
    final textStyle = TextStyle(color: Colors.black87, fontSize: 12);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    textPainter.text = TextSpan(
      text: 'Calcul EI - Menuiserie au vent',
      style: textStyle.copyWith(fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, centerY - 50));

    if (resultats != null) {
      final y = centerY;
      var offset = 0.0;
      final lineHeight = 20.0;

      resultats!.forEach((key, value) {
        if (value != null && value is num) {
          textPainter.text = TextSpan(
            text: '$key: ${value.toStringAsFixed(2)}',
            style: textStyle,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, y + offset));
          offset += lineHeight;
        }
      });
    }
  }

  void _drawSupport(Canvas canvas, Offset position, Paint paint) {
    // Triangle pour appui simple
    final path = Path();
    path.moveTo(position.dx, position.dy);
    path.lineTo(position.dx - 8, position.dy + 12);
    path.lineTo(position.dx + 8, position.dy + 12);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawFixedSupport(Canvas canvas, Offset position, Paint paint) {
    // Rectangle pour encastrement
    final rect = Rect.fromLTWH(
      position.dx - 10,
      position.dy,
      20,
      15,
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

