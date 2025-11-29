import 'package:flutter/material.dart';

/// Outil de dessin 2D pour créer des formes personnalisées
class DrawingTool extends StatefulWidget {
  final double width;
  final double height;
  final Function(List<Offset>)? onShapeDrawn;

  const DrawingTool({
    super.key,
    this.width = 400,
    this.height = 300,
    this.onShapeDrawn,
  });

  @override
  State<DrawingTool> createState() => _DrawingToolState();
}

class _DrawingToolState extends State<DrawingTool> {
  List<Offset> _points = [];
  List<List<Offset>> _shapes = [];
  String _currentTool = 'line'; // 'line', 'rectangle', 'circle', 'polygon'

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre d'outils
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolButton(Icons.show_chart, 'Ligne', 'line'),
              _buildToolButton(Icons.crop_free, 'Rectangle', 'rectangle'),
              _buildToolButton(Icons.radio_button_unchecked, 'Cercle', 'circle'),
              _buildToolButton(Icons.change_history, 'Polygone', 'polygon'),
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: _shapes.isNotEmpty ? () {
                  setState(() {
                    _shapes.removeLast();
                  });
                } : null,
                tooltip: 'Annuler',
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _shapes.clear();
                    _points.clear();
                  });
                },
                tooltip: 'Effacer tout',
              ),
            ],
          ),
        ),
        // Zone de dessin
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.white,
          ),
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTapDown: _onTapDown,
            child: CustomPaint(
              painter: DrawingPainter(
                shapes: _shapes,
                currentPoints: _points,
                currentTool: _currentTool,
              ),
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton(IconData icon, String label, String tool) {
    final isSelected = _currentTool == tool;
    return InkWell(
      onTap: () {
        setState(() {
          _currentTool = tool;
          _points.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700),
            Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _points = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentTool == 'line' || _currentTool == 'rectangle' || _currentTool == 'circle') {
      setState(() {
        if (_points.length == 1) {
          _points.add(details.localPosition);
        } else {
          _points[1] = details.localPosition;
        }
      });
    } else if (_currentTool == 'polygon') {
      // Pour le polygone, on ajoute des points au fur et à mesure
      setState(() {
        _points.add(details.localPosition);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_points.length >= 2) {
      setState(() {
        _shapes.add(List.from(_points));
        _points.clear();
      });
      if (widget.onShapeDrawn != null) {
        widget.onShapeDrawn!(_shapes.last);
      }
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (_currentTool == 'polygon') {
      setState(() {
        _points.add(details.localPosition);
      });
    }
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> shapes;
  final List<Offset> currentPoints;
  final String currentTool;

  DrawingPainter({
    required this.shapes,
    required this.currentPoints,
    required this.currentTool,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = Colors.blue.shade100.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Dessiner les formes sauvegardées
    for (final shape in shapes) {
      _drawShape(canvas, shape, paint, fillPaint, currentTool);
    }

    // Dessiner la forme en cours
    if (currentPoints.isNotEmpty) {
      _drawShape(canvas, currentPoints, paint, fillPaint, currentTool);
    }
  }

  void _drawShape(Canvas canvas, List<Offset> points, Paint paint, Paint fillPaint, String tool) {
    if (points.isEmpty) return;

    switch (tool) {
      case 'line':
        if (points.length >= 2) {
          canvas.drawLine(points[0], points[1], paint);
        }
        break;

      case 'rectangle':
        if (points.length >= 2) {
          final rect = Rect.fromPoints(points[0], points[1]);
          canvas.drawRect(rect, fillPaint);
          canvas.drawRect(rect, paint);
        }
        break;

      case 'circle':
        if (points.length >= 2) {
          final center = points[0];
          final radius = (points[1] - points[0]).distance;
          canvas.drawCircle(center, radius, fillPaint);
          canvas.drawCircle(center, radius, paint);
        }
        break;

      case 'polygon':
        if (points.length >= 2) {
          final path = Path();
          path.moveTo(points[0].dx, points[0].dy);
          for (int i = 1; i < points.length; i++) {
            path.lineTo(points[i].dx, points[i].dy);
          }
          if (points.length >= 3) {
            path.close();
            canvas.drawPath(path, fillPaint);
          }
          canvas.drawPath(path, paint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

