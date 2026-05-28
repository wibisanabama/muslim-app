import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/auth_view_model.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVm = context.watch<AuthViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: theme.brightness == Brightness.light
                    ? [
                        theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.4,
                        ),
                        theme.colorScheme.surface,
                      ]
                    : [const Color(0xff0e1805), theme.colorScheme.surface],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 24),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/icons/launcher_icon.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Muslim',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Asisten Ibadah & Tanya Jawab AI Islami',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.light
                            ? theme.colorScheme.surfaceContainer.withValues(
                                alpha: 0.8,
                              )
                            : theme.colorScheme.surfaceContainerLow.withValues(
                                alpha: 0.6,
                              ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mengapa bergabung?',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildBenefitRow(
                            theme,
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Tanya Muslim AI',
                            desc:
                                'Konsultasi seputar fikih, doa, & ajaran Islam dengan asisten AI pintar.',
                          ),
                          const Divider(height: 24, thickness: 0.8),
                          _buildBenefitRow(
                            theme,
                            icon: Icons.sync_rounded,
                            title: 'Sinkronisasi Cloud',
                            desc:
                                'Progres tadarus Al-Quran & catatan tersimpan aman.',
                          ),
                          const Divider(height: 24, thickness: 0.8),
                          _buildBenefitRow(
                            theme,
                            icon: Icons.favorite_border_rounded,
                            title: 'Favorit & Kustomisasi',
                            desc:
                                'Bookmark doa-doa penting dan simpan konfigurasi personal Anda.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                shadowColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.25),
                              ).copyWith(
                                elevation:
                                    WidgetStateProperty.resolveWith<double>((
                                      Set<WidgetState> states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.pressed,
                                      )) {
                                        return 2;
                                      }
                                      return 0;
                                    }),
                              ),
                          onPressed: authVm.isLoading
                              ? null
                              : () async {
                                  await authVm.signInWithGoogle();
                                },
                          child: authVm.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomPaint(
                                      size: const Size(20, 20),
                                      painter: _GoogleLogoPainter(),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Masuk dengan Google',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.8,
                  ),
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double s = w / 48.0;
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    paint.color = const Color(0xFFEA4335);
    final Path red = Path()
      ..moveTo(24 * s, 9.5 * s)
      ..cubicTo(27.54 * s, 9.5 * s, 30.71 * s, 10.72 * s, 33.21 * s, 13.1 * s)
      ..lineTo(40.06 * s, 6.25 * s)
      ..cubicTo(35.9 * s, 2.38 * s, 30.47 * s, 0 * s, 24 * s, 0 * s)
      ..cubicTo(14.62 * s, 0 * s, 6.51 * s, 5.38 * s, 2.56 * s, 13.22 * s)
      ..lineTo(10.54 * s, 19.41 * s)
      ..cubicTo(12.43 * s, 13.72 * s, 17.74 * s, 9.5 * s, 24 * s, 9.5 * s)
      ..close();
    canvas.drawPath(red, paint);

    paint.color = const Color(0xFF4285F4);
    final Path blue = Path()
      ..moveTo(48 * s, 24 * s)
      ..cubicTo(48 * s, 22.29 * s, 47.85 * s, 20.63 * s, 47.56 * s, 19.01 * s)
      ..lineTo(24 * s, 19.01 * s)
      ..lineTo(24 * s, 28.52 * s)
      ..lineTo(37.51 * s, 28.52 * s)
      ..cubicTo(
        36.93 * s,
        31.67 * s,
        35.14 * s,
        34.34 * s,
        32.47 * s,
        36.13 * s,
      )
      ..lineTo(32.47 * s, 42.46 * s)
      ..lineTo(40.63 * s, 42.46 * s)
      ..cubicTo(45.39 * s, 37.58 * s, 48 * s, 31.33 * s, 48 * s, 24 * s)
      ..close();
    canvas.drawPath(blue, paint);

    paint.color = const Color(0xFFFBBC05);
    final Path yellow = Path()
      ..moveTo(10.54 * s, 28.59 * s)
      ..cubicTo(10.06 * s, 27.14 * s, 9.78 * s, 25.6 * s, 9.78 * s, 24 * s)
      ..cubicTo(9.78 * s, 22.4 * s, 10.06 * s, 20.86 * s, 10.54 * s, 19.41 * s)
      ..lineTo(2.56 * s, 13.22 * s)
      ..cubicTo(0.92 * s, 16.49 * s, 0 * s, 20.14 * s, 0 * s, 24 * s)
      ..cubicTo(0 * s, 27.86 * s, 0.92 * s, 31.51 * s, 2.56 * s, 34.78 * s)
      ..lineTo(10.54 * s, 28.59 * s)
      ..close();
    canvas.drawPath(yellow, paint);

    paint.color = const Color(0xFF34A853);
    final Path green = Path()
      ..moveTo(24 * s, 48 * s)
      ..cubicTo(30.48 * s, 48 * s, 35.93 * s, 45.87 * s, 39.89 * s, 42.19 * s)
      ..lineTo(31.73 * s, 35.86 * s)
      ..cubicTo(29.47 * s, 37.37 * s, 26.58 * s, 38.28 * s, 24 * s, 38.28 * s)
      ..cubicTo(
        17.74 * s,
        38.28 * s,
        12.43 * s,
        34.06 * s,
        10.54 * s,
        28.37 * s,
      )
      ..lineTo(2.56 * s, 34.56 * s)
      ..cubicTo(6.51 * s, 42.62 * s, 14.62 * s, 48 * s, 24 * s, 48 * s)
      ..close();
    canvas.drawPath(green, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
