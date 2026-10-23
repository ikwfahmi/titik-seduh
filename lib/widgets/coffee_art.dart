import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Ilustrasi vektor dekoratif. Bukan foto atau menu yang disediakan API.
class CoffeeArt extends StatelessWidget {
  const CoffeeArt({super.key, this.size = 140, this.takeaway = false});
  final double size;
  final bool takeaway;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _CupPainter(takeaway)),
    ),
  );
}

class CoffeeCartArt extends StatelessWidget {
  const CoffeeCartArt({super.key, this.width = 260});
  final double width;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width,
      height: width * .72,
      child: CustomPaint(painter: _CartPainter()),
    ),
  );
}

class CoffeePattern extends StatelessWidget {
  const CoffeePattern({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _PatternPainter(), child: child);
}

class _CupPainter extends CustomPainter {
  _CupPainter(this.takeaway);
  final bool takeaway;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 160, size.height / 160);
    final fill = Paint()..color = AppTheme.peach;
    final stroke = Paint()
      ..color = AppTheme.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(
      const Rect.fromLTWH(30, 134, 103, 9),
      fill..color = const Color(0xFFE8D8C6),
    );
    if (takeaway) {
      final cup = Path()
        ..moveTo(44, 49)
        ..lineTo(117, 49)
        ..lineTo(106, 132)
        ..lineTo(56, 132)
        ..close();
      canvas.drawPath(cup, fill..color = AppTheme.tan);
      canvas.drawPath(cup, stroke);
      final sleeve = Path()
        ..moveTo(48, 76)
        ..lineTo(113, 76)
        ..lineTo(109, 111)
        ..lineTo(53, 111)
        ..close();
      canvas.drawPath(sleeve, fill..color = AppTheme.orange);
      canvas.drawPath(sleeve, stroke);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(39, 39, 83, 13),
          const Radius.circular(3),
        ),
        fill..color = AppTheme.peach,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(39, 39, 83, 13),
          const Radius.circular(3),
        ),
        stroke,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(48, 29, 65, 11),
          const Radius.circular(3),
        ),
        fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(48, 29, 65, 11),
          const Radius.circular(3),
        ),
        stroke,
      );
      canvas.drawOval(
        const Rect.fromLTWH(70, 82, 19, 23),
        fill..color = AppTheme.cream,
      );
      canvas.drawLine(
        const Offset(74, 101),
        const Offset(85, 85),
        stroke..strokeWidth = 2,
      );
    } else {
      canvas.drawOval(
        const Rect.fromLTWH(105, 71, 30, 37),
        fill..color = AppTheme.peach,
      );
      canvas.drawOval(const Rect.fromLTWH(105, 71, 30, 37), stroke);
      final cup = Path()
        ..moveTo(36, 67)
        ..lineTo(117, 67)
        ..lineTo(110, 105)
        ..quadraticBezierTo(106, 123, 77, 123)
        ..quadraticBezierTo(48, 123, 43, 105)
        ..close();
      canvas.drawPath(cup, fill..color = AppTheme.orange);
      canvas.drawPath(cup, stroke);
      canvas.drawOval(
        const Rect.fromLTWH(36, 60, 81, 15),
        fill..color = AppTheme.peach,
      );
      canvas.drawOval(const Rect.fromLTWH(36, 60, 81, 15), stroke);
      canvas.drawLine(const Offset(29, 132), const Offset(127, 132), stroke);
      for (final x in [68.0, 88.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(x, 48)
            ..lineTo(x, 24),
          stroke..strokeWidth = 2.6,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CupPainter oldDelegate) =>
      oldDelegate.takeaway != takeaway;
}

class _CartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 260, size.height / 187.2);
    final p = Paint();
    final line = Paint()
      ..color = AppTheme.ink
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    void rect(Rect r, Color c, {double radius = 0}) {
      final rr = RRect.fromRectAndRadius(r, Radius.circular(radius));
      canvas.drawRRect(rr, p..color = c);
      canvas.drawRRect(rr, line);
    }

    canvas.drawOval(
      const Rect.fromLTWH(40, 169, 183, 9),
      p..color = const Color(0xFFE9D7BD),
    );
    canvas.drawLine(const Offset(70, 72), const Offset(70, 119), line);
    canvas.drawLine(const Offset(190, 72), const Offset(190, 118), line);
    rect(const Rect.fromLTWH(82, 17, 96, 26), AppTheme.tan, radius: 7);
    final text = TextPainter(
      text: const TextSpan(
        text: 'TITIK SEDUH',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset(130 - text.width / 2, 24));
    for (var i = 0; i < 8; i++) {
      final path = Path()
        ..moveTo(78 + i * 13.0, 42)
        ..lineTo(91 + i * 13.0, 42)
        ..lineTo(204 + i * 0.0 - (7 - i) * 18.5, 69)
        ..quadraticBezierTo(
          195 - (7 - i) * 18.5,
          80,
          185.5 - (7 - i) * 18.5,
          69,
        )
        ..close();
      canvas.drawPath(
        path,
        p..color = i.isEven ? AppTheme.orange : AppTheme.peach,
      );
      canvas.drawPath(path, line..strokeWidth = 1.7);
    }
    line.strokeWidth = 2.5;
    rect(const Rect.fromLTWH(63, 112, 137, 13), AppTheme.tan, radius: 2);
    final body = Path()
      ..moveTo(70, 125)
      ..lineTo(192, 125)
      ..lineTo(174, 162)
      ..lineTo(89, 162)
      ..close();
    canvas.drawPath(body, p..color = AppTheme.orange);
    canvas.drawPath(body, line);
    canvas.drawPath(
      Path()
        ..moveTo(75, 127)
        ..lineTo(130, 160)
        ..lineTo(186, 127),
      line,
    );
    canvas.drawPath(
      Path()
        ..moveTo(89, 161)
        ..lineTo(130, 129)
        ..lineTo(174, 161),
      line,
    );
    for (final x in [87.0, 177.0]) {
      canvas.drawCircle(Offset(x, 160), 16, p..color = AppTheme.peach);
      canvas.drawCircle(Offset(x, 160), 16, line);
      canvas.drawCircle(Offset(x, 160), 3, p..color = AppTheme.ink);
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4;
        canvas.drawLine(
          Offset(x, 160),
          Offset(x + 14 * math.cos(a), 160 + 14 * math.sin(a)),
          line..strokeWidth = 1.2,
        );
      }
    }
    line.strokeWidth = 2.5;
    canvas.drawPath(
      Path()
        ..moveTo(197, 118)
        ..lineTo(220, 105)
        ..lineTo(238, 105),
      line,
    );
    rect(const Rect.fromLTWH(83, 83, 28, 29), AppTheme.cream, radius: 3);
    rect(const Rect.fromLTWH(89, 90, 15, 15), AppTheme.tan, radius: 2);
    canvas.drawCircle(const Offset(97, 97), 3, p..color = AppTheme.ink);
    canvas.drawLine(const Offset(79, 112), const Offset(116, 112), line);
    for (final x in [127.0, 148.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 96)
          ..lineTo(x + 13, 96)
          ..lineTo(x + 10, 111)
          ..lineTo(x + 3, 111)
          ..close(),
        p..color = AppTheme.peach,
      );
      canvas.drawPath(
        Path()
          ..moveTo(x, 96)
          ..lineTo(x + 13, 96)
          ..lineTo(x + 10, 111)
          ..lineTo(x + 3, 111)
          ..close(),
        line..strokeWidth = 1.5,
      );
      canvas.drawLine(Offset(x - 1, 94), Offset(x + 14, 94), line);
    }
    rect(const Rect.fromLTWH(171, 99, 11, 13), AppTheme.tan, radius: 1);
    canvas.drawLine(
      const Offset(176, 99),
      const Offset(176, 86),
      line..strokeWidth = 1.8,
    );
    canvas.drawOval(
      const Rect.fromLTWH(167, 85, 9, 5),
      p..color = AppTheme.ink,
    );
    canvas.drawOval(const Rect.fromLTWH(177, 88, 9, 5), p);
    for (final dot in [
      const Offset(55, 166),
      const Offset(211, 161),
      const Offset(199, 177),
      const Offset(115, 181),
    ]) {
      canvas.drawCircle(dot, 1.7, p..color = AppTheme.ink);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x108D6A4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var y = 15.0; y < size.height; y += 55) {
      for (var x = 15.0; x < size.width; x += 60) {
        canvas.save();
        canvas.translate(x + (y % 2) * 10, y);
        canvas.rotate((x + y) * .02);
        canvas.drawOval(const Rect.fromLTWH(0, 0, 10, 17), p);
        canvas.drawPath(
          Path()
            ..moveTo(5, 1)
            ..cubicTo(0, 6, 10, 11, 5, 16),
          p,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
