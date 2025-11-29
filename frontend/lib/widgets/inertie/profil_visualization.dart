import 'package:flutter/material.dart';
import '../../models/inertie/profil_model.dart';

/// Widget pour visualiser un profil en 2D
class ProfilVisualization extends StatelessWidget {
  final Profil? profil;
  final double? hauteurCm;
  final double? largeurCm;
  final double? epaisseurCm;
  final double width;
  final double height;
  final bool showDimensions;
  final bool showInerties;

  const ProfilVisualization({
    super.key,
    this.profil,
    this.hauteurCm,
    this.largeurCm,
    this.epaisseurCm,
    this.width = 300,
    this.height = 200,
    this.showDimensions = true,
    this.showInerties = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: CustomPaint(
        painter: ProfilPainter(
          profil: profil,
          hauteurCm: hauteurCm,
          largeurCm: largeurCm,
          epaisseurCm: epaisseurCm,
          showDimensions: showDimensions,
          showInerties: showInerties,
        ),
        child: Container(),
      ),
    );
  }
}

class ProfilPainter extends CustomPainter {
  final Profil? profil;
  final double? hauteurCm;
  final double? largeurCm;
  final double? epaisseurCm;
  final bool showDimensions;
  final bool showInerties;

  ProfilPainter({
    this.profil,
    this.hauteurCm,
    this.largeurCm,
    this.epaisseurCm,
    this.showDimensions = true,
    this.showInerties = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = Colors.blue.shade100
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.black87,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    // Dimensions réelles ou par défaut
    double h = hauteurCm ?? 10;
    double w = largeurCm ?? 5;
    double e = epaisseurCm ?? 0.5;

    // Calculer les dimensions pour l'affichage (avec marge)
    final margin = 20.0;
    final availableWidth = size.width - 2 * margin;
    final availableHeight = size.height - 2 * margin;

    // Calculer l'échelle pour que le profil tienne dans l'espace disponible
    final scaleX = availableWidth / (w + 2);
    final scaleY = availableHeight / (h + 2);
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Dessiner le profil (vue de face)
    final rectWidth = w * scale;
    final rectHeight = h * scale;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: rectWidth,
        height: rectHeight,
      ),
      const Radius.circular(2),
    );

    // Dessiner le contour extérieur
    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, paint);

    // Dessiner le contour intérieur (tube creux)
    if (e > 0 && e < w / 2 && e < h / 2) {
      final innerRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: (w - 2 * e) * scale,
          height: (h - 2 * e) * scale,
        ),
        const Radius.circular(1),
      );
      canvas.drawRRect(innerRect, paint);
    }

    // Dessiner les dimensions
    if (showDimensions) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );

      // Hauteur
      final hText = 'H: ${h.toStringAsFixed(1)} cm';
      textPainter.text = TextSpan(text: hText, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(centerX + rectWidth / 2 + 5, centerY - textPainter.height / 2),
      );

      // Largeur
      final wText = 'L: ${w.toStringAsFixed(1)} cm';
      textPainter.text = TextSpan(text: wText, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2, centerY + rectHeight / 2 + 5),
      );

      // Épaisseur si applicable
      if (e > 0) {
        final eText = 'e: ${e.toStringAsFixed(1)} cm';
        textPainter.text = TextSpan(text: eText, style: textStyle);
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(centerX - textPainter.width / 2, centerY - rectHeight / 2 - textPainter.height - 5),
        );
      }
    }

    // Afficher les inerties si disponible
    if (showInerties && profil != null) {
      final inertieText = 'Ixx: ${profil!.inertieIxx.toStringAsFixed(2)} cm⁴\n'
          'Iyy: ${profil!.inertieIyy.toStringAsFixed(2)} cm⁴';
      final textPainter = TextPainter(
        text: TextSpan(
          text: inertieText,
          style: textStyle.copyWith(fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(margin, margin),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}





