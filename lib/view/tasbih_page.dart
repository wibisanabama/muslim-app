import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DhikrItem {
  final String arabic;
  final String latin;
  final String meaning;
  const DhikrItem({required this.arabic, required this.latin, required this.meaning});
}

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> with SingleTickerProviderStateMixin {
  static const List<DhikrItem> _dhikrs = [
    DhikrItem(arabic: "سُبْحَانَ ٱللَّٰهِ", latin: "Subhanallah", meaning: "Maha Suci Allah"),
    DhikrItem(arabic: "ٱلْحَمْدُ لِلَّٰهِ", latin: "Alhamdulillah", meaning: "Segala puji bagi Allah"),
    DhikrItem(arabic: "ٱللَّٰهُ أَكْبَرُ", latin: "Allahu Akbar", meaning: "Allah Maha Besar"),
    DhikrItem(arabic: "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ", latin: "La ilaha illallah", meaning: "Tiada tuhan selain Allah"),
    DhikrItem(arabic: "أَسْتَغْفِرُ ٱللَّٰهَ", latin: "Astaghfirullah", meaning: "Aku memohon ampun kepada Allah"),
  ];

  int _count = 0;
  int _dhikrIndex = 0;
  int _targetLimit = 33; // Default limit
  bool _isVibrationEnabled = true;
  bool _isAutoSwitchEnabled = true;
  bool _isPressed = false;
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
    _loadState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _count = prefs.getInt('tasbih_count') ?? 0;
        _dhikrIndex = prefs.getInt('tasbih_dhikr_index') ?? 0;
        _targetLimit = prefs.getInt('tasbih_target_limit') ?? 33;
        _isVibrationEnabled = prefs.getBool('tasbih_vibration') ?? true;
        _isAutoSwitchEnabled = prefs.getBool('tasbih_auto_switch') ?? true;
      });
    } catch (_) {}
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbih_count', _count);
      await prefs.setInt('tasbih_dhikr_index', _dhikrIndex);
      await prefs.setInt('tasbih_target_limit', _targetLimit);
      await prefs.setBool('tasbih_vibration', _isVibrationEnabled);
      await prefs.setBool('tasbih_auto_switch', _isAutoSwitchEnabled);
    } catch (_) {}
  }

  void _increment() {
    if (_isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _count++;
      
      // Cek jika batas tercapai
      if (_targetLimit > 0 && _count >= _targetLimit) {
        if (_isVibrationEnabled) {
          // Umpan balik haptic yang lebih terasa untuk menandai tercapainya batas target
          HapticFeedback.mediumImpact();
        }

        // Tampilkan pesan target tercapai di bagian bawah layar
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Alhamdulillah, target $_targetLimit x ${_dhikrs[_dhikrIndex].latin} selesai!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        if (_isAutoSwitchEnabled) {
          _count = 0;
          _dhikrIndex = (_dhikrIndex + 1) % _dhikrs.length;
        } else {
          _count = 0;
        }
      }
    });
    _saveState();
  }

  void _reset() {
    if (_isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      _count = 0;
    });
    _saveState();
  }

  void _changeDhikr(int index) {
    if (_isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _dhikrIndex = index;
      _count = 0;
    });
    _saveState();
  }

  void _changeLimit(int limit) {
    if (_isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _targetLimit = limit;
      _count = 0;
    });
    _saveState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeDhikr = _dhikrs[_dhikrIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih Digital'),
        centerTitle: false,
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // Tombol Reset
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Hitungan',
            onPressed: _reset,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Panel Pilihan Dhikr
            Card.filled(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  _showDhikrSelectionBottomSheet(theme);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    children: [
                      Text(
                        activeDhikr.arabic,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.6,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activeDhikr.latin,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"${activeDhikr.meaning}"',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // area Lingkaran Tasbih Utama
            Center(
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isPressed = true;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _isPressed = false;
                  });
                  _increment();
                },
                onTapCancel: () {
                  setState(() {
                    _isPressed = false;
                  });
                },
                child: AnimatedScale(
                  scale: _isPressed ? 0.94 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.25),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _count.toString(),
                            style: GoogleFonts.outfit(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (_targetLimit > 0)
                            Text(
                              '/ $_targetLimit',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Pengaturan Batas Target & Fitur
            Card.filled(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Batas Target',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildLimitChip(label: '33', value: 33),
                        const SizedBox(width: 8),
                        _buildLimitChip(label: '99', value: 99),
                        const SizedBox(width: 8),
                        _buildLimitChip(label: 'Tanpa Batas', value: 0),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Switch Getar
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Getar Tumpal Balik (Haptic)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text('Bergetar setiap ketukan dan batas selesai.'),
                      value: _isVibrationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isVibrationEnabled = value;
                        });
                        _saveState();
                      },
                    ),
                    // Switch Otomatis Ganti
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Pindah Bacaan Otomatis',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text('Pindah ke bacaan berikutnya setelah target selesai.'),
                      value: _isAutoSwitchEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isAutoSwitchEnabled = value;
                        });
                        _saveState();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitChip({required String label, required int value}) {
    final theme = Theme.of(context);
    final isSelected = _targetLimit == value;

    return Expanded(
      child: Material(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _changeLimit(value),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDhikrSelectionBottomSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pilih Bacaan Dhikr',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _dhikrs.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _dhikrs[index];
                    final isSelected = _dhikrIndex == index;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.latin,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.meaning),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.arabic,
                            style: GoogleFonts.scheherazadeNew(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
                          ],
                        ],
                      ),
                      onTap: () {
                        _changeDhikr(index);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
