import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shows the custom Blossom HSV Color Picker dialog matching the smartwatch bubble-menu design.
Future<Color?> showBlossomColorPicker(
  BuildContext context,
  Color initialColor,
) {
  return showDialog<Color>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (ctx) => BlossomColorPickerDialog(initialColor: initialColor),
  );
}

class BlossomColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const BlossomColorPickerDialog({super.key, required this.initialColor});

  @override
  State<BlossomColorPickerDialog> createState() =>
      _BlossomColorPickerDialogState();
}

class _BlossomColorPickerDialogState extends State<BlossomColorPickerDialog> {
  late double _hue; // 0..360
  late double _saturation; // 0..1
  late double _value; // 0.1..1

  Offset? _touchPos;
  double _rotationOffset = 0.0;
  double _lastAngle = 0.0;
  bool _isInteractingArc = false;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation == 0 ? 1.0 : hsv.saturation;
    _value = hsv.value < 0.1 ? 0.8 : hsv.value;
  }

  Color get currentColor {
    return HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
  }

  String get currentHex {
    final c = currentColor;
    return '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  Color get _contrastTextColor {
    return currentColor.computeLuminance() > 0.4 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1B1B22),
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: 340,
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Color',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Blossom wheel + Curved Arcs Canvas with Smartwatch Motion
            Center(
              child: SizedBox(
                width: 290,
                height: 250,
                child: GestureDetector(
                  onPanStart: (d) => _handleGestureStart(
                    d.localPosition,
                    const Size(290, 250),
                  ),
                  onPanUpdate: (d) => _handleGestureUpdate(
                    d.localPosition,
                    const Size(290, 250),
                  ),
                  onPanEnd: (_) => _handleGestureEnd(),
                  onPanCancel: () => _handleGestureEnd(),
                  child: CustomPaint(
                    size: const Size(290, 250),
                    painter: BlossomCanvasPainter(
                      hue: _hue,
                      saturation: _saturation,
                      value: _value,
                      touchPos: _touchPos,
                      rotationOffset: _rotationOffset,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Hex Code display box filled with picked color
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: currentColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  currentHex,
                  style: TextStyle(
                    color: _contrastTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons (Cancel / Apply)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF97316),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context, currentColor),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF97316),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleGestureStart(Offset pos, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final dx = pos.dx - cx;
    final dy = pos.dy - cy;
    final dist = math.sqrt(dx * dx + dy * dy);

    _lastAngle = math.atan2(dy, dx);
    const double arcRadius = 105.0;

    if (dist >= arcRadius - 22 && dist <= arcRadius + 22) {
      _isInteractingArc = true;
      _handleArcGesture(pos, size, dx, dy);
    } else {
      _isInteractingArc = false;
      _handleBlossomGesture(pos, size, dx, dy, dist);
    }
  }

  void _handleGestureUpdate(Offset pos, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final dx = pos.dx - cx;
    final dy = pos.dy - cy;
    final dist = math.sqrt(dx * dx + dy * dy);

    if (_isInteractingArc) {
      _handleArcGesture(pos, size, dx, dy);
    } else {
      _handleBlossomGesture(pos, size, dx, dy, dist);
    }
  }

  void _handleGestureEnd() {
    setState(() {
      _touchPos = null;
      _isInteractingArc = false;
    });
  }

  void _handleArcGesture(Offset pos, Size size, double dx, double dy) {
    double angleRad = math.atan2(dy, dx);
    double angleDeg = angleRad * 180 / math.pi;

    // Left Arc: Brightness/Value (dx < -20)
    if (dx < -20) {
      if (angleDeg < 0) angleDeg += 360;
      double norm = (230 - angleDeg) / 100.0;
      double newVal = (norm * 0.9 + 0.1).clamp(0.1, 1.0);
      setState(() {
        _value = newVal;
      });
      return;
    }

    // Right Arc: Saturation (dx > 20)
    if (dx > 20) {
      if (angleDeg > 180) angleDeg -= 360;
      double norm = (angleDeg - (-50)) / 100.0;
      double newSat = norm.clamp(0.0, 1.0);
      setState(() {
        _saturation = newSat;
      });
      return;
    }
  }

  void _handleBlossomGesture(
    Offset pos,
    Size size,
    double dx,
    double dy,
    double dist,
  ) {
    const double blossomRadius = 75.0;
    double currentAngle = math.atan2(dy, dx);
    double deltaAngle = currentAngle - _lastAngle;

    // Smartwatch wheel rotation physics
    if (deltaAngle > math.pi) deltaAngle -= 2 * math.pi;
    if (deltaAngle < -math.pi) deltaAngle += 2 * math.pi;

    _rotationOffset += deltaAngle * 0.8;
    _lastAngle = currentAngle;

    double angleDeg = currentAngle * 180 / math.pi;
    if (angleDeg < 0) angleDeg += 360;

    double adjustedHue = (angleDeg - (_rotationOffset * 180 / math.pi)) % 360;
    if (adjustedHue < 0) adjustedHue += 360;

    double sat = (dist / blossomRadius).clamp(0.0, 1.0);

    setState(() {
      _touchPos = pos;
      _hue = adjustedHue;
      _saturation = sat;
    });
  }
}

/// Custom painter for rendering the Blossom wheel with Smartwatch bubble motion & arc sliders
class BlossomCanvasPainter extends CustomPainter {
  final double hue;
  final double saturation;
  final double value;
  final Offset? touchPos;
  final double rotationOffset;

  BlossomCanvasPainter({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.touchPos,
    required this.rotationOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    const double arcRadius = 105.0;
    const double blossomRadius = 70.0;

    final currColor = HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();

    // -------------------------------------------------------------
    // 1. Draw Left Curved Arc Track (Value / Brightness)
    // -------------------------------------------------------------
    final leftRect = Rect.fromCircle(center: center, radius: arcRadius);
    const leftStartAngle = 130 * math.pi / 180;
    const leftSweepAngle = 100 * math.pi / 180;

    final leftTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: leftStartAngle,
        endAngle: leftStartAngle + leftSweepAngle,
        colors: [
          Colors.black87,
          HSVColor.fromAHSV(1.0, hue, saturation, 0.5).toColor(),
          HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor(),
        ],
      ).createShader(leftRect);

    canvas.drawArc(
      leftRect,
      leftStartAngle,
      leftSweepAngle,
      false,
      leftTrackPaint,
    );

    // Left Arc White Circular Thumb
    double valueNorm = ((value - 0.1) / 0.9).clamp(0.0, 1.0);
    double leftThumbAngle = (230 - valueNorm * 100) * math.pi / 180;
    Offset leftThumbCenter = Offset(
      cx + arcRadius * math.cos(leftThumbAngle),
      cy + arcRadius * math.sin(leftThumbAngle),
    );

    // Shadow under left thumb
    canvas.drawCircle(
      leftThumbCenter,
      12.0,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // White thumb
    canvas.drawCircle(leftThumbCenter, 11.0, Paint()..color = Colors.white);
    canvas.drawCircle(
      leftThumbCenter,
      11.0,
      Paint()
        ..color = const Color(0xFF1B1B22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // -------------------------------------------------------------
    // 2. Draw Right Curved Arc Track (Saturation)
    // -------------------------------------------------------------
    final rightRect = Rect.fromCircle(center: center, radius: arcRadius);
    const rightStartAngle = -50 * math.pi / 180;
    const rightSweepAngle = 100 * math.pi / 180;

    final rightTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: rightStartAngle,
        endAngle: rightStartAngle + rightSweepAngle,
        colors: [
          HSVColor.fromAHSV(1.0, hue, 0.05, value).toColor(),
          HSVColor.fromAHSV(1.0, hue, 0.50, value).toColor(),
          HSVColor.fromAHSV(1.0, hue, 1.00, value).toColor(),
        ],
      ).createShader(rightRect);

    canvas.drawArc(
      rightRect,
      rightStartAngle,
      rightSweepAngle,
      false,
      rightTrackPaint,
    );

    // Right Arc White Circular Thumb
    double rightThumbAngle = (-50 + saturation * 100) * math.pi / 180;
    Offset rightThumbCenter = Offset(
      cx + arcRadius * math.cos(rightThumbAngle),
      cy + arcRadius * math.sin(rightThumbAngle),
    );

    // Shadow under right thumb
    canvas.drawCircle(
      rightThumbCenter,
      12.0,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // White thumb
    canvas.drawCircle(rightThumbCenter, 11.0, Paint()..color = Colors.white);
    canvas.drawCircle(
      rightThumbCenter,
      11.0,
      Paint()
        ..color = const Color(0xFF1B1B22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // -------------------------------------------------------------
    // 3. Draw Smartwatch Petal Bubble Grid
    // -------------------------------------------------------------
    final rings = [
      (count: 18, radiusRatio: 0.90, sat: 1.00, dotRadius: 10.5),
      (count: 14, radiusRatio: 0.68, sat: 0.75, dotRadius: 9.5),
      (count: 10, radiusRatio: 0.46, sat: 0.50, dotRadius: 8.5),
      (count: 6, radiusRatio: 0.24, sat: 0.25, dotRadius: 7.5),
    ];

    for (final ring in rings) {
      final r = blossomRadius * ring.radiusRatio;
      for (int i = 0; i < ring.count; i++) {
        final angleRad = (2 * math.pi / ring.count) * i + rotationOffset;
        final h = ((angleRad * 180 / math.pi) % 360 + 360) % 360;

        double px = cx + r * math.cos(angleRad);
        double py = cy + r * math.sin(angleRad);
        double currentRadius = ring.dotRadius;

        // Smartwatch menu bubble magnification & magnetic motion
        if (touchPos != null) {
          final distToFinger = (Offset(px, py) - touchPos!).distance;
          if (distToFinger < 65) {
            final factor = (1.0 - distToFinger / 65).clamp(0.0, 1.0);
            // Zoom bubble up to 1.5x
            currentRadius *= (1.0 + 0.5 * factor);

            // Magnetic displacement
            final dir = (Offset(px, py) - touchPos!);
            if (dir.distance > 0) {
              final disp = (dir / dir.distance) * (10 * factor);
              px += disp.dx;
              py += disp.dy;
            }
          }
        }

        final dotColor = HSVColor.fromAHSV(1.0, h, ring.sat, value).toColor();
        canvas.drawCircle(
          Offset(px, py),
          currentRadius,
          Paint()..color = dotColor,
        );
      }
    }

    // -------------------------------------------------------------
    // 4. Center Selected Color Indicator Node
    // -------------------------------------------------------------
    // Inner shadow under center dot
    canvas.drawCircle(
      center,
      18.0,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Solid center circle in picked color
    canvas.drawCircle(center, 16.0, Paint()..color = currColor);

    // Crisp white border
    canvas.drawCircle(
      center,
      16.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
  }

  @override
  bool shouldRepaint(covariant BlossomCanvasPainter oldDelegate) {
    return oldDelegate.hue != hue ||
        oldDelegate.saturation != saturation ||
        oldDelegate.value != value ||
        oldDelegate.touchPos != touchPos ||
        oldDelegate.rotationOffset != rotationOffset;
  }
}
