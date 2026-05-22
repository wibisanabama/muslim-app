import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

class KiblatPage extends StatefulWidget {
  const KiblatPage({super.key});

  @override
  State<KiblatPage> createState() => _KiblatPageState();
}

class _KiblatPageState extends State<KiblatPage> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        final scrolled = _scrollController.offset > 0;
        if (scrolled != _isScrolled) {
          setState(() {
            _isScrolled = scrolled;
          });
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Sudut Kiblat untuk wilayah Indonesia secara umum adalah ~295° dari Utara (searah jarum jam).
    const double qiblaAngleDegrees = 295.0;
    const double qiblaAngleRadians = qiblaAngleDegrees * (math.pi / 180.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arah Kiblat'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Compass Container Card inside StreamBuilder
            StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                double? direction;
                bool hasSensor = true;

                if (snapshot.hasError) {
                  direction = null;
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  direction = null;
                } else {
                  direction = snapshot.data?.heading;
                  if (snapshot.data == null) {
                    hasSensor = false;
                  }
                }

                // Perhitungan rotasi piringan kompas:
                final double headingDegrees = direction ?? 0.0;
                final double headingRadians = headingDegrees * (math.pi / 180.0);

                return Card.filled(
                  margin: EdgeInsets.zero,
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                                // Piringan Kompas Berputar (U, T, S, B, Jarum Utara, dan Jarum Kiblat)
                                Transform.rotate(
                                  angle: -headingRadians,
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
                                      CustomPaint(
                                        size: const Size(20, 160),
                                        painter: CompassNeedlePainter(
                                          colorTop: theme.colorScheme.error,
                                          colorBottom: theme.colorScheme.outline.withValues(alpha: 0.5),
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
                                                angle: -qiblaAngleRadians, // Keep the icon upright relative to qibla needle
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
                                    ],
                                  ),
                                ),
                                
                                // Center Pivot Dot (Statis)
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
                        const SizedBox(height: 24),
                        if (!hasSensor)
                          Text(
                            'Sensor arah (magnetometer) tidak terdeteksi pada perangkat ini.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          )
                        else
                          Text(
                            'Sudut Hadap Perangkat: ${headingDegrees.toStringAsFixed(1)}°',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Info Section - Segmented (Filled)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(context, 'Sudut Kiblat', '295.2° (Barat Laut)', isFirst: true),
                      Divider(height: 1, color: theme.colorScheme.surface, thickness: 1.5),
                      _buildInfoRow(context, 'Negara Referensi', 'Indonesia'),
                      Divider(height: 1, color: theme.colorScheme.surface, thickness: 1.5),
                      _buildInfoRow(context, 'Tujuan Arah', 'Ka\'bah, Makkah', isLast: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Usage Guide Card
            Card.filled(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Petunjuk Penggunaan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Posisikan perangkat seluler Anda secara datar dan mendatar (horizontal) di tangan atau permukaan meja.\n\n'
                      '2. Putar perlahan posisi perangkat Anda hingga huruf "U" (Utara) pada kompas mengarah tepat sejajar dengan arah Utara geografis Anda yang sebenarnya.\n\n'
                      '3. Setelah terarah tegak lurus, jarum emas berlogo Masjid akan menunjukkan posisi Arah Kiblat yang akurat untuk melakukan shalat.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

  Widget _buildInfoRow(BuildContext context, String title, String value, {bool isFirst = false, bool isLast = false}) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isFirst ? 16 : 0),
      topRight: Radius.circular(isFirst ? 16 : 0),
      bottomLeft: Radius.circular(isLast ? 16 : 0),
      bottomRight: Radius.circular(isLast ? 16 : 0),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
