import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import '../utils/error_formatter.dart';

class KiblatPage extends StatefulWidget {
  const KiblatPage({super.key});

  @override
  State<KiblatPage> createState() => _KiblatPageState();
}

class _KiblatPageState extends State<KiblatPage> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;

  double _qiblaAngleDegrees = 295.0;
  String _locationName = 'Indonesia';
  bool _isLoadingLocation = false;
  String? _errorMessage;
  bool _hasLoadedOnce = false;

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

    unawaited(_loadCachedLocation());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_fetchLocationAndCalculateQibla());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.containsKey('cached_qibla_lat')) {
        await prefs.remove('cached_qibla_lat');
      }
      if (prefs.containsKey('cached_qibla_lon')) {
        await prefs.remove('cached_qibla_lon');
      }

      final cachedAngle = prefs.getDouble('cached_qibla_angle');
      final cachedName = prefs.getString('cached_qibla_name');

      if (cachedAngle != null && cachedName != null) {
        setState(() {
          _qiblaAngleDegrees = cachedAngle;
          _locationName = cachedName;
          _hasLoadedOnce = true;
        });
      }
    } catch (e) {
      AppLogger.warningLazy(() => 'Error loading cached qibla data: $e');
    }
  }

  Future<void> _fetchLocationAndCalculateQibla({bool force = false}) async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi (GPS) belum aktif.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin akses lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final double lat = position.latitude;
      final double lon = position.longitude;

      final double calculatedAngle = calculateQiblaDirection(lat, lon);

      String resolvedCity = '';
      try {
        final placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          if (place.subAdministrativeArea != null &&
              place.subAdministrativeArea!.isNotEmpty) {
            resolvedCity = place.subAdministrativeArea!
                .replaceAll(
                  RegExp(
                    r'(Regency|Kabupaten|City|Kota|Regency\s+|\s+Regency|\s+City|City\s+)',
                    caseSensitive: false,
                  ),
                  '',
                )
                .trim();
          } else if (place.locality != null && place.locality!.isNotEmpty) {
            resolvedCity = place.locality!;
          } else if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            resolvedCity = place.administrativeArea!;
          }

          final String country = place.country ?? 'Indonesia';
          resolvedCity = resolvedCity.isNotEmpty
              ? '$resolvedCity, $country'
              : country;
        }
      } catch (e) {
        AppLogger.warningLazy(() => 'Geocoding error: $e');
        resolvedCity = 'Lokasi Terdeteksi';
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cached_qibla_angle', calculatedAngle);
      await prefs.setString('cached_qibla_name', resolvedCity);

      setState(() {
        _qiblaAngleDegrees = calculatedAngle;
        _locationName = resolvedCity;
        _hasLoadedOnce = true;
      });
    } catch (e) {
      AppLogger.warningLazy(() => 'Qibla location acquisition error: $e');
      setState(() {
        _errorMessage = formatError(e);

        if (!_hasLoadedOnce) {
          _qiblaAngleDegrees = 295.0;
          _locationName = 'Indonesia (Default)';
        }
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  double calculateQiblaDirection(double lat1, double lon1) {
    const double lat2 = 21.422487;
    const double lon2 = 39.826206;

    final double phi1 = lat1 * math.pi / 180.0;
    final double lambda1 = lon1 * math.pi / 180.0;
    final double phi2 = lat2 * math.pi / 180.0;
    final double lambda2 = lon2 * math.pi / 180.0;

    final double deltaLambda = lambda2 - lambda1;

    final double y = math.sin(deltaLambda);
    final double x =
        math.cos(phi1) * math.tan(phi2) -
        math.sin(phi1) * math.cos(deltaLambda);

    double qiblaAngle = math.atan2(y, x) * 180.0 / math.pi;

    return (qiblaAngle + 360.0) % 360.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double qiblaAngleRadians = _qiblaAngleDegrees * (math.pi / 180.0);

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
      body: RefreshIndicator(
        onRefresh: () => _fetchLocationAndCalculateQibla(force: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                Card.filled(
                  color: theme.colorScheme.errorContainer,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              StreamBuilder<CompassEvent>(
                stream: FlutterCompass.events,
                builder: (context, snapshot) {
                  double? direction;
                  bool hasSensor = true;

                  if (snapshot.hasError) {
                    direction = null;
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    direction = null;
                  } else {
                    direction = snapshot.data?.heading;
                    if (snapshot.data == null) {
                      hasSensor = false;
                    }
                  }

                  final double headingDegrees = direction ?? 0.0;
                  final double headingRadians =
                      headingDegrees * (math.pi / 180.0);

                  return Card.filled(
                    margin: EdgeInsets.zero,
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.25,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 32.0,
                        horizontal: 16.0,
                      ),
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

                          Center(
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.shadow.withValues(
                                      alpha: 0.05,
                                    ),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: -headingRadians,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 170,
                                          height: 170,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: theme.colorScheme.outline
                                                  .withValues(alpha: 0.15),
                                              width: 1,
                                            ),
                                          ),
                                        ),

                                        Transform.rotate(
                                          angle: qiblaAngleRadians,
                                          child: CustomPaint(
                                            size: const Size(22, 140),
                                            painter: QiblaNeedlePainter(
                                              color: Colors.amber.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: theme.colorScheme.surface,
                                    child: CircleAvatar(
                                      radius: 4,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!hasSensor) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Sensor arah (magnetometer) tidak terdeteksi pada perangkat ini.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.25,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          'Lokasi Anda',
                          _isLoadingLocation
                              ? 'Mencari lokasi...'
                              : _locationName,
                          isFirst: true,
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.surface,
                          thickness: 1.5,
                        ),
                        _buildInfoRow(
                          context,
                          'Tujuan Arah',
                          'Ka\'bah, Makkah',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String title,
    String value, {
    bool isFirst = false,
    bool isLast = false,
  }) {
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

class QiblaNeedlePainter extends CustomPainter {
  final Color color;

  QiblaNeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

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
