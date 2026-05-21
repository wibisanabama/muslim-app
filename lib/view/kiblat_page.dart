import 'package:flutter/material.dart';
import 'dart:math' as math;

class KiblatPage extends StatelessWidget {
  const KiblatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Sudut Kiblat untuk wilayah Indonesia secara umum adalah ~295° dari Utara (searah jarum jam).
    const double qiblaAngleDegrees = 295.0;
    const double qiblaAngleRadians = qiblaAngleDegrees * (math.pi / 180.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arah Kiblat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Compass Container Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      'KOMPAS KIBLAT',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // The Compass Dial Graphic
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                            width: 8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Cardinal Directions (U, T, S, B)
                            // North (Utara)
                            Positioned(
                              top: 12,
                              child: Text(
                                'U',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                            // East (Timur)
                            Positioned(
                              right: 12,
                              child: Text(
                                'T',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            // South (Selatan)
                            Positioned(
                              bottom: 12,
                              child: Text(
                                'S',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            // West (Barat)
                            Positioned(
                              left: 12,
                              child: Text(
                                'B',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            
                            // Concentric circles inside compass
                            Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                            ),
                            
                            // Jarum Kompas Utara (North Pointer) - Pointing to 0 degrees
                            Transform.rotate(
                              angle: 0.0,
                              child: CustomPaint(
                                size: const Size(20, 160),
                                painter: CompassNeedlePainter(
                                  colorTop: theme.colorScheme.error,
                                  colorBottom: theme.colorScheme.outline.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            
                            // Jarum Arah Kiblat (Qibla Pointer) - Pointing to 295 degrees
                            Transform.rotate(
                              angle: qiblaAngleRadians,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // The Golden Line pointer pointing to Qiblah
                                  CustomPaint(
                                    size: const Size(22, 140),
                                    painter: QiblaNeedlePainter(
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                  // Mosque/Kaaba representation icon on the pointer tip
                                  Positioned(
                                    top: 10,
                                    child: Transform.rotate(
                                      angle: -qiblaAngleRadians, // Keep the icon upright
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.amber.shade700,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        child: const Icon(
                                          Icons.mosque,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Center Pivot Dot
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: theme.colorScheme.surface,
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Info Cards
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Detail Koordinat Arah',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(context, 'Sudut Kiblat', '295.2° (Barat Laut)'),
                    const Divider(),
                    _buildInfoRow(context, 'Negara Referensi', 'Indonesia'),
                    const Divider(),
                    _buildInfoRow(context, 'Tujuan Arah', 'Ka\'bah, Makkah'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Usage Guide Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Petunjuk Penggunaan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Posisikan perangkat seluler Anda secara datar dan mendatar (horizontal) di tangan atau permukaan meja.\n\n'
                      '2. Putar perlahan posisi perangkat Anda hingga huruf "U" (Utara) pada kompas mengarah tepat sejajar dengan arah Utara geografis Anda yang sebenarnya.\n\n'
                      '3. Setelah terarah tegak lurus, jarum emas berlogo Masjid akan menunjukkan posisi Arah Kiblat yang akurat untuk melakukan shalat.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Painter for standard Red/Gray North pointer needle
class CompassNeedlePainter extends CustomPainter {
  final Color colorTop;
  final Color colorBottom;

  CompassNeedlePainter({required this.colorTop, required this.colorBottom});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Top Pointer (Red) - points to North
    paint.color = colorTop;
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height / 2 - 5);
    path.lineTo(0, size.height / 2);
    path.close();
    canvas.drawPath(path, paint);

    // Bottom Pointer (Gray)
    paint.color = colorBottom;
    path.reset();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height / 2 - 5);
    path.lineTo(0, size.height / 2);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter for Qibla Golden Needle pointer
class QiblaNeedlePainter extends CustomPainter {
  final Color color;

  QiblaNeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Drawn pointing UP towards the tip, very thin, sleek, and elegant
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width * 0.7, size.height);
    path.lineTo(size.width / 2, size.height - 8);
    path.lineTo(size.width * 0.3, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
