import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/auth_view_model.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVm = context.watch<AuthViewModel>();
    final width = MediaQuery.of(context).size.width;

    return Drawer(
      width: width,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            // Custom Header with Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: authVm.isLoggedIn
                  ? _buildProfileContent(context, theme, authVm)
                  : _buildLoginContent(context, theme, authVm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginContent(BuildContext context, ThemeData theme, AuthViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.cloud_sync_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Sinkronisasi Akun',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Simpan dan sinkronkan kemajuan ibadah serta setelan personal Anda secara aman di awan.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _buildBenefitItem(
            theme,
            icon: Icons.menu_book_outlined,
            title: 'Riwayat Baca Quran',
            description: 'Menyimpan tanda ayat terakhir agar Anda dapat melanjutkan bacaan kapan saja.',
          ),
          const SizedBox(height: 24),
          _buildBenefitItem(
            theme,
            icon: Icons.bookmark_border_outlined,
            title: 'Daftar Favorit & Bookmark',
            description: 'Akses cepat ke doa pilihan dan hadis penting yang sering Anda amalkan.',
          ),
          const SizedBox(height: 24),
          _buildBenefitItem(
            theme,
            icon: Icons.tune_outlined,
            title: 'Setelan Personal',
            description: 'Penyesuaian jadwal shalat, dan tema aplikasi selalu terjaga.',
          ),
          const SizedBox(height: 48),
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                side: BorderSide(color: theme.colorScheme.outlineVariant),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                final success = await viewModel.signInWithGoogle();
                if (context.mounted) {
                  if (!success && viewModel.error != null) {
                    viewModel.clearError();
                  } else if (success) {
                    // Stay in drawer, UI will rebuild to profile
                  }
                }
              },
              child: Row(
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
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ThemeData theme, AuthViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    viewModel.email,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: viewModel.photoUrl != null
                        ? CircleAvatar(
                            radius: 56,
                            backgroundImage: NetworkImage(viewModel.photoUrl!),
                            backgroundColor: theme.colorScheme.primaryContainer,
                          )
                        : CircleAvatar(
                            radius: 56,
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            child: Text(
                              viewModel.monogramLetter,
                              style: GoogleFonts.outfit(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Assalamualaikum, ${viewModel.displayName}!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Sesi Terhubung dengan Google',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  await viewModel.signOut();
                },
                child: Text(
                  'Keluar Akun',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileMonogram extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const ProfileMonogram({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVm = context.watch<AuthViewModel>();

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            scaffoldKey.currentState?.openEndDrawer();
          },
          child: authVm.photoUrl != null
              ? CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(authVm.photoUrl!),
                  backgroundColor: theme.colorScheme.primaryContainer,
                )
              : CircleAvatar(
                  backgroundColor: authVm.isLoggedIn
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  foregroundColor: authVm.isLoggedIn
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  radius: 18,
                  child: Text(
                    authVm.monogramLetter,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
      ),
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

    // Red (Top path)
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

    // Blue (Right path with arm)
    paint.color = const Color(0xFF4285F4);
    final Path blue = Path()
      ..moveTo(48 * s, 24 * s)
      ..cubicTo(48 * s, 22.29 * s, 47.85 * s, 20.63 * s, 47.56 * s, 19.01 * s)
      ..lineTo(24 * s, 19.01 * s)
      ..lineTo(24 * s, 28.52 * s)
      ..lineTo(37.51 * s, 28.52 * s)
      ..cubicTo(36.93 * s, 31.67 * s, 35.14 * s, 34.34 * s, 32.47 * s, 36.13 * s)
      ..lineTo(32.47 * s, 42.46 * s)
      ..lineTo(40.63 * s, 42.46 * s)
      ..cubicTo(45.39 * s, 37.58 * s, 48 * s, 31.33 * s, 48 * s, 24 * s)
      ..close();
    canvas.drawPath(blue, paint);

    // Yellow (Left path)
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

    // Green (Bottom path)
    paint.color = const Color(0xFF34A853);
    final Path green = Path()
      ..moveTo(24 * s, 48 * s)
      ..cubicTo(30.48 * s, 48 * s, 35.93 * s, 45.87 * s, 39.89 * s, 42.19 * s)
      ..lineTo(31.73 * s, 35.86 * s)
      ..cubicTo(29.47 * s, 37.37 * s, 26.58 * s, 38.28 * s, 24 * s, 38.28 * s)
      ..cubicTo(17.74 * s, 38.28 * s, 12.43 * s, 34.06 * s, 10.54 * s, 28.37 * s)
      ..lineTo(2.56 * s, 34.56 * s)
      ..cubicTo(6.51 * s, 42.62 * s, 14.62 * s, 48 * s, 24 * s, 48 * s)
      ..close();
    canvas.drawPath(green, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
