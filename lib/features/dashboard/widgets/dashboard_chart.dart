import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';

class DashboardChart extends StatelessWidget {
  const DashboardChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Simuliamo alcuni dati per il grafico
    final List<ChartData> data = [
      ChartData('Gen', 120),
      ChartData('Feb', 150),
      ChartData('Mar', 180),
      ChartData('Apr', 160),
      ChartData('Mag', 200),
      ChartData('Giu', 240),
    ];

    return Container(
      height: 200.h,
      child: CustomPaint(
        size: Size(double.infinity, 200.h),
        painter: ChartPainter(data),
      ),
    );
  }
}

class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}

class ChartPainter extends CustomPainter {
  final List<ChartData> data;

  ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryBlue.withOpacity(0.3),
          AppTheme.primaryBlue.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Trova i valori massimi e minimi
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    // Calcola le posizioni dei punti
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = (data[i].value - minValue) / range;
      final y = size.height - (normalizedValue * size.height * 0.8) - (size.height * 0.1);
      points.add(Offset(x, y));
    }

    // Disegna l'area riempita
    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, size.height);
      path.lineTo(points.first.dx, points.first.dy);
      
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      
      path.lineTo(points.last.dx, size.height);
      path.close();
    }

    canvas.drawPath(path, fillPaint);

    // Disegna la linea
    final linePath = Path();
    if (points.isNotEmpty) {
      linePath.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(linePath, paint);

    // Disegna i punti
    final pointPaint = Paint()
      ..color = AppTheme.primaryBlue
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(point, 4, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill);
      canvas.drawCircle(point, 2, pointPaint);
    }

    // Disegna le etichette
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      
      textPainter.text = TextSpan(
        text: data[i].label,
        style: TextStyle(
          color: AppTheme.textMedium,
          fontSize: 12.sp,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height + 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}