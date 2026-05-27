import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodel/ramadhan_view_model.dart';
import '../model/ramadhan_record.dart';
import '../viewmodel/shalat_view_model.dart';
import '../model/shalat_schedule_response.dart';

enum PrayerStatus { active, passed, future }

class RamadhanPage extends StatefulWidget {
  const RamadhanPage({super.key});

  @override
  State<RamadhanPage> createState() => _RamadhanPageState();
}

class _RamadhanPageState extends State<RamadhanPage> {
  int _selectedDay = 1;

  String _formatRupiah(double amount) {
    final int val = amount.toInt();
    final String str = val.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  String _formatDateLong(DateTime date) {
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final dayName = days[date.weekday % 7];
    return '$dayName, ${_formatDate(date)}';
  }

  DateTime? _parseTime(DateTime baseDate, String timeStr) {
    try {
      final parts = timeStr.trim().split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
      );
    } catch (_) {
      return null;
    }
  }

  PrayerStatus _getPrayerStatus(
    String prayerName,
    DateTime targetDate,
    DateTime now,
    ShalatDaySchedule todaySchedule,
  ) {
    final todayDate = DateTime(now.year, now.month, now.day);
    final targetDayOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    final subuhToday = _parseTime(now, todaySchedule.subuh);
    final terbitToday = _parseTime(now, todaySchedule.terbit);
    final dzuhurToday = _parseTime(now, todaySchedule.dzuhur);
    final asharToday = _parseTime(now, todaySchedule.ashar);
    final maghribToday = _parseTime(now, todaySchedule.maghrib);
    final isyaToday = _parseTime(now, todaySchedule.isya);

    if (subuhToday == null ||
        terbitToday == null ||
        dzuhurToday == null ||
        asharToday == null ||
        maghribToday == null ||
        isyaToday == null) {
      return PrayerStatus.active;
    }

    if (targetDayOnly.isBefore(todayDate)) {
      final isYesterday = targetDayOnly.isAtSameMomentAs(
        todayDate.subtract(const Duration(days: 1)),
      );
      if (isYesterday && prayerName == 'Isya') {
        if (now.isBefore(subuhToday)) {
          return PrayerStatus.active;
        }
      }
      return PrayerStatus.passed;
    } else if (targetDayOnly.isAfter(todayDate)) {
      return PrayerStatus.future;
    } else {
      switch (prayerName) {
        case 'Subuh':
          if (now.isBefore(subuhToday)) return PrayerStatus.future;
          if (now.isBefore(terbitToday)) return PrayerStatus.active;
          return PrayerStatus.passed;
        case 'Dzuhur':
          if (now.isBefore(dzuhurToday)) return PrayerStatus.future;
          if (now.isBefore(asharToday)) return PrayerStatus.active;
          return PrayerStatus.passed;
        case 'Ashar':
          if (now.isBefore(asharToday)) return PrayerStatus.future;
          if (now.isBefore(maghribToday)) return PrayerStatus.active;
          return PrayerStatus.passed;
        case 'Maghrib':
          if (now.isBefore(maghribToday)) return PrayerStatus.future;
          if (now.isBefore(isyaToday)) return PrayerStatus.active;
          return PrayerStatus.passed;
        case 'Isya':
          if (now.isBefore(isyaToday)) return PrayerStatus.future;
          return PrayerStatus.active;
        default:
          return PrayerStatus.active;
      }
    }
  }

  int _getActiveRamadhanDay(
    RamadhanViewModel viewModel,
    List<ShalatDaySchedule> schedules,
  ) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    ShalatDaySchedule? todaySchedule;
    for (final s in schedules) {
      try {
        final parts = s.tanggal.split(', ');
        if (parts.length >= 2) {
          final dateParts = parts[1].split('/');
          if (dateParts.length >= 3) {
            final day = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final year = int.parse(dateParts[2]);
            final sDate = DateTime(year, month, day);
            if (sDate.isAtSameMomentAs(todayDate)) {
              todaySchedule = s;
              break;
            }
          }
        }
      } catch (_) {}
    }

    DateTime targetDate = todayDate;
    if (todaySchedule != null) {
      final subuhToday = _parseTime(now, todaySchedule.subuh);
      if (subuhToday != null && now.isBefore(subuhToday)) {
        targetDate = todayDate.subtract(const Duration(days: 1));
      }
    }

    final activeDay = targetDate.difference(viewModel.startDate).inDays + 1;
    return activeDay.clamp(1, 30);
  }

  IconData _getShalatIcon(String name) {
    switch (name.toLowerCase()) {
      case 'subuh':
        return CupertinoIcons.sunrise;
      case 'dzuhur':
        return Icons.wb_sunny_rounded;
      case 'ashar':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return CupertinoIcons.sunset;
      case 'isya':
        return Icons.nights_stay_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catatan'),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(icon: Icon(Icons.check_box), text: 'Shalat'),
              Tab(icon: Icon(Icons.menu_book), text: 'Ceramah'),
              Tab(icon: Icon(Icons.volunteer_activism), text: 'Infaq'),
            ],
          ),
        ),
        body: Consumer<RamadhanViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _buildShalatTab(context, viewModel),
                _buildCeramahTab(context, viewModel),
                _buildInfaqTab(context, viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildShalatTab(BuildContext context, RamadhanViewModel viewModel) {
    final theme = Theme.of(context);

    final shalatVm = Provider.of<ShalatViewModel>(context);
    final schedules = shalatVm.schedules;
    ShalatDaySchedule? todaySchedule;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    _selectedDay = _getActiveRamadhanDay(viewModel, schedules);
    final log = viewModel.shalatLogs[_selectedDay - 1];
    final fardhuPrayers = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
    final targetDate = viewModel.startDate.add(
      Duration(days: _selectedDay - 1),
    );

    for (final s in schedules) {
      try {
        final parts = s.tanggal.split(', ');
        if (parts.length >= 2) {
          final dateParts = parts[1].split('/');
          if (dateParts.length >= 3) {
            final day = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final year = int.parse(dateParts[2]);
            final sDate = DateTime(year, month, day);
            if (sDate.isAtSameMomentAs(todayDate)) {
              todaySchedule = s;
              break;
            }
          }
        }
      } catch (_) {}
    }

    final hasSchedule = todaySchedule != null;
    final todayStr = _formatDateLong(DateTime.now());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 88.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hari Ini',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            todayStr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: fardhuPrayers.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.colorScheme.surface,
                thickness: 1.5,
              ),
              itemBuilder: (context, i) {
                final prayerName = fardhuPrayers[i];
                final isChecked = log.prayers[prayerName] ?? false;
                final isFirst = i == 0;
                final isLast = i == fardhuPrayers.length - 1;

                final PrayerStatus status = hasSchedule
                    ? _getPrayerStatus(
                        prayerName,
                        targetDate,
                        now,
                        todaySchedule!,
                      )
                    : PrayerStatus.active;

                final isEnabled = status == PrayerStatus.active;
                final double opacity = isEnabled ? 1.0 : 0.6;

                String statusLabel = '';
                Color statusColor = theme.colorScheme.onSurfaceVariant;
                if (hasSchedule) {
                  if (isChecked) {
                    statusLabel = 'Tercatat';
                    statusColor = Colors.green;
                  } else {
                    switch (status) {
                      case PrayerStatus.active:
                        statusLabel = 'Sedang berlangsung';
                        statusColor = theme.colorScheme.primary;
                        break;
                      case PrayerStatus.passed:
                        statusLabel = 'Waktu shalat telah lewat';
                        statusColor = theme.colorScheme.error.withValues(
                          alpha: 0.8,
                        );
                        break;
                      case PrayerStatus.future:
                        statusLabel = 'Belum masuk waktu';
                        statusColor = theme.colorScheme.outline;
                        break;
                    }
                  }
                } else {
                  statusLabel = isChecked ? 'Tercatat' : 'Buka';
                  statusColor = isChecked
                      ? Colors.green
                      : theme.colorScheme.outline;
                }

                final borderRadius = BorderRadius.only(
                  topLeft: Radius.circular(isFirst ? 16 : 0),
                  topRight: Radius.circular(isFirst ? 16 : 0),
                  bottomLeft: Radius.circular(isLast ? 16 : 0),
                  bottomRight: Radius.circular(isLast ? 16 : 0),
                );

                return Opacity(
                  opacity: opacity,
                  child: Material(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.25,
                    ),
                    borderRadius: borderRadius,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: isEnabled
                          ? () {
                              viewModel.togglePrayer(_selectedDay, prayerName);
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _getShalatIcon(prayerName),
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prayerName,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    statusLabel,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: statusColor,
                                      fontWeight:
                                          isChecked ||
                                              status == PrayerStatus.active
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Checkbox(
                              value: isChecked,
                              activeColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: isEnabled
                                  ? (bool? value) {
                                      viewModel.togglePrayer(
                                        _selectedDay,
                                        prayerName,
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showHistoryBottomSheet(context, viewModel),
        label: const Text('Riwayat'),
        icon: const Icon(Icons.history),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }

  void _showHistoryBottomSheet(
    BuildContext context,
    RamadhanViewModel viewModel,
  ) {
    unawaited(
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final theme = Theme.of(context);
          final start = viewModel.startDate;
          final fardhuPrayers = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];

          final activeDays = <int>[];
          for (int i = 0; i < 30; i++) {
            final log = viewModel.shalatLogs[i];
            final hasAnyChecked = log.prayers.values.any(
              (checked) => checked == true,
            );
            if (hasAnyChecked) {
              activeDays.add(i + 1);
            }
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Text(
                      'Riwayat',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: activeDays.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history_toggle_off_rounded,
                                  size: 48,
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada riwayat shalat yang tercatat.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(24),
                            itemCount: activeDays.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final day = activeDays[index];
                              final log = viewModel.shalatLogs[day - 1];
                              final dayDate = start.add(
                                Duration(days: day - 1),
                              );

                              return Theme(
                                data: theme.copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  clipBehavior: Clip.antiAlias,
                                  color: theme.colorScheme.surfaceContainerLow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ExpansionTile(
                                    collapsedBackgroundColor:
                                        Colors.transparent,
                                    backgroundColor: Colors.transparent,
                                    iconColor: theme.colorScheme.primary,
                                    title: Text(
                                      _formatDateLong(dayDate),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    children: [
                                      const Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Column(
                                          children: fardhuPrayers.map((pr) {
                                            final isPrChecked =
                                                log.prayers[pr] ?? false;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24.0,
                                                    vertical: 8.0,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    _getShalatIcon(pr),
                                                    size: 18,
                                                    color: isPrChecked
                                                        ? theme
                                                              .colorScheme
                                                              .primary
                                                        : theme
                                                              .colorScheme
                                                              .outline,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      pr,
                                                      style: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: isPrChecked
                                                                ? theme
                                                                      .colorScheme
                                                                      .onSurface
                                                                : theme
                                                                      .colorScheme
                                                                      .outline,
                                                            fontWeight:
                                                                isPrChecked
                                                                ? FontWeight
                                                                      .bold
                                                                : FontWeight
                                                                      .normal,
                                                          ),
                                                    ),
                                                  ),
                                                  Icon(
                                                    isPrChecked
                                                        ? Icons
                                                              .check_circle_rounded
                                                        : Icons.cancel_outlined,
                                                    size: 18,
                                                    color: isPrChecked
                                                        ? Colors.green
                                                        : theme
                                                              .colorScheme
                                                              .outlineVariant,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCeramahTab(BuildContext context, RamadhanViewModel viewModel) {
    final theme = Theme.of(context);

    if (viewModel.ceramahLogs.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_late,
                size: 64,
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada catatan ceramah.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Catat ceramah Anda di sini.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddCeramahBottomSheet(context, viewModel),
          label: const Text('Tambah Catatan'),
          icon: const Icon(Icons.add),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      );
    }

    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: viewModel.ceramahLogs.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: theme.colorScheme.surface,
          thickness: 1.5,
        ),
        itemBuilder: (context, index) {
          final log = viewModel.ceramahLogs[index];
          final isFirst = index == 0;
          final isLast = index == viewModel.ceramahLogs.length - 1;
          final borderRadius = BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 16 : 0),
            topRight: Radius.circular(isFirst ? 16 : 0),
            bottomLeft: Radius.circular(isLast ? 16 : 0),
            bottomRight: Radius.circular(isLast ? 16 : 0),
          );

          final deleteBackground = Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
              borderRadius: borderRadius,
            ),
            child: Icon(
              Icons.delete_sweep_rounded,
              color: theme.colorScheme.error,
              size: 28,
            ),
          );

          final deleteSecondaryBackground = Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
              borderRadius: borderRadius,
            ),
            child: Icon(
              Icons.delete_sweep_rounded,
              color: theme.colorScheme.error,
              size: 28,
            ),
          );

          return Dismissible(
            key: ValueKey(log.id),
            background: deleteBackground,
            secondaryBackground: deleteSecondaryBackground,
            onDismissed: (direction) {
              final messenger = ScaffoldMessenger.of(context);
              viewModel.deleteCeramahLog(log.id);
              messenger.clearSnackBars();
              messenger.showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF2C2C2C),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  content: const Text(
                    'Catatan ceramah berhasil dihapus',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  duration: const Duration(seconds: 3),
                  persist: false,
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: theme.colorScheme.primary,
                    onPressed: () {
                      viewModel.restoreCeramahLog(log);
                      messenger.hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            },
            child: Material(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              borderRadius: borderRadius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () =>
                    _showCeramahDetailBottomSheet(context, log, viewModel),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            log.speaker,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(log.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 24,
                        color: theme.colorScheme.surface,
                        thickness: 1.5,
                      ),
                      Text(
                        log.summary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCeramahBottomSheet(context, viewModel),
        label: const Text('Tambah Catatan'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }

  void _showAddCeramahBottomSheet(
    BuildContext context,
    RamadhanViewModel viewModel,
  ) {
    final titleController = TextEditingController();
    final speakerController = TextEditingController();
    final summaryController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    unawaited(
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Catat Ceramah',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: titleController,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          labelText: 'Judul / Tema Materi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Judul tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: speakerController,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          labelText: 'Penceramah / Ustadz',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Nama penceramah tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: summaryController,
                        maxLines: 4,
                        maxLength: 5000,
                        decoration: const InputDecoration(
                          labelText: 'Ringkasan Catatan Materi',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Ringkasan tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Batal',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  viewModel.addCeramahLog(
                                    speaker: speakerController.text,
                                    title: titleController.text,
                                    summary: summaryController.text,
                                  );
                                  Navigator.pop(context);
                                } on RamadhanValidationError catch (e) {
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: theme.colorScheme.error,
                                      content: Text(
                                        e.message,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                } catch (_) {
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: theme.colorScheme.error,
                                      content: const Text(
                                        'Gagal menambahkan catatan ceramah.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Simpan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCeramahDetailBottomSheet(
    BuildContext context,
    CeramahLog log,
    RamadhanViewModel viewModel,
  ) {
    unawaited(
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final theme = Theme.of(context);
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            log.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Ubah Catatan',
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditCeramahBottomSheet(
                              context,
                              log,
                              viewModel,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                log.speaker,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(log.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text(
                      'Ringkasan Ceramah:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      log.summary,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditCeramahBottomSheet(
    BuildContext context,
    CeramahLog log,
    RamadhanViewModel viewModel,
  ) {
    final titleController = TextEditingController(text: log.title);
    final speakerController = TextEditingController(text: log.speaker);
    final summaryController = TextEditingController(text: log.summary);
    final formKey = GlobalKey<FormState>();

    unawaited(
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Ubah Catatan Ceramah',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: titleController,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          labelText: 'Judul / Tema Materi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Judul tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: speakerController,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          labelText: 'Penceramah / Ustadz',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Nama penceramah tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: summaryController,
                        maxLines: 4,
                        maxLength: 5000,
                        decoration: const InputDecoration(
                          labelText: 'Ringkasan Catatan Materi',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Ringkasan tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Batal',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  viewModel.updateCeramahLog(
                                    id: log.id,
                                    speaker: speakerController.text,
                                    title: titleController.text,
                                    summary: summaryController.text,
                                  );
                                  Navigator.pop(context);
                                } on RamadhanValidationError catch (e) {
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: theme.colorScheme.error,
                                      content: Text(
                                        e.message,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                } catch (_) {
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: theme.colorScheme.error,
                                      content: const Text(
                                        'Gagal memperbarui catatan ceramah.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Simpan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfaqTab(BuildContext context, RamadhanViewModel viewModel) {
    final theme = Theme.of(context);

    return Scaffold(
      body: viewModel.infaqLogs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.volunteer_activism_outlined,
                    size: 64,
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada transaksi infaq.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mulai tabungan akhirat dengan berinfaq.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: viewModel.infaqLogs.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.colorScheme.surface,
                thickness: 1.5,
              ),
              itemBuilder: (context, index) {
                final log = viewModel.infaqLogs[index];
                final isFirst = index == 0;
                final isLast = index == viewModel.infaqLogs.length - 1;
                final borderRadius = BorderRadius.only(
                  topLeft: Radius.circular(isFirst ? 16 : 0),
                  topRight: Radius.circular(isFirst ? 16 : 0),
                  bottomLeft: Radius.circular(isLast ? 16 : 0),
                  bottomRight: Radius.circular(isLast ? 16 : 0),
                );

                final deleteBackground = Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: borderRadius,
                  ),
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    color: theme.colorScheme.error,
                    size: 24,
                  ),
                );

                final deleteSecondaryBackground = Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: borderRadius,
                  ),
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    color: theme.colorScheme.error,
                    size: 24,
                  ),
                );

                return Dismissible(
                  key: ValueKey(log.id),
                  background: deleteBackground,
                  secondaryBackground: deleteSecondaryBackground,
                  onDismissed: (direction) {
                    final messenger = ScaffoldMessenger.of(context);
                    viewModel.deleteInfaqLog(log.id);
                    messenger.clearSnackBars();
                    messenger.showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF2C2C2C),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        content: Text(
                          'Transaksi infaq ${_formatRupiah(log.amount)} berhasil dihapus',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        duration: const Duration(seconds: 3),
                        persist: false,
                        action: SnackBarAction(
                          label: 'Undo',
                          textColor: theme.colorScheme.primary,
                          onPressed: () {
                            viewModel.restoreInfaqLog(log);
                            messenger.hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  },
                  child: Material(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.25,
                    ),
                    borderRadius: borderRadius,
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      onTap: () =>
                          _showInfaqDetailBottomSheet(context, log, viewModel),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          Icons.volunteer_activism,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _formatRupiah(log.amount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.notes,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(log.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInfaqBottomSheet(context, viewModel),
        label: const Text('Tambah Catatan'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }

  void _showAddInfaqBottomSheet(
    BuildContext context,
    RamadhanViewModel viewModel,
  ) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    unawaited(
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Catat Sedekah / Infaq',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nominal Rupiah',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            child: Text(
                              'Rp',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nominal tidak boleh kosong';
                          }
                          final amount = double.tryParse(val);
                          if (amount == null || amount <= 0) {
                            return 'Nominal harus berupa angka lebih besar dari 0';
                          }
                          if (amount >= 1e12) {
                            return 'Nominal tidak boleh mencapai atau melebihi 1 triliun';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: notesController,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Keterangan (Penerima / Peruntukan)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Keterangan tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Batal',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final messenger = ScaffoldMessenger.of(context);
                                final amount = double.parse(
                                  amountController.text,
                                );
                                try {
                                  viewModel.addInfaqLog(
                                    amount: amount,
                                    notes: notesController.text,
                                  );
                                  Navigator.pop(context);
                                } on RamadhanValidationError catch (e) {
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: theme.colorScheme.error,
                                      content: Text(
                                        e.message,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                } catch (_) {
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: theme.colorScheme.error,
                                      content: const Text(
                                        'Gagal menyimpan catatan sedekah.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Simpan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showInfaqDetailBottomSheet(
    BuildContext context,
    InfaqLog log,
    RamadhanViewModel viewModel,
  ) {
    unawaited(
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final theme = Theme.of(context);
          return DraggableScrollableSheet(
            initialChildSize: 0.45,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _formatRupiah(log.amount),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Ubah Transaksi',
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditInfaqBottomSheet(context, log, viewModel);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.volunteer_activism,
                                size: 14,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Infaq & Sedekah',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(log.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text(
                      'Keterangan:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      log.notes,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditInfaqBottomSheet(
    BuildContext context,
    InfaqLog log,
    RamadhanViewModel viewModel,
  ) {
    final amountController = TextEditingController(
      text: log.amount.toInt().toString(),
    );
    final notesController = TextEditingController(text: log.notes);
    final formKey = GlobalKey<FormState>();

    unawaited(
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Ubah Catatan Sedekah / Infaq',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nominal Rupiah (Rp)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixText: 'Rp ',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nominal tidak boleh kosong';
                          }
                          final amount = double.tryParse(val);
                          if (amount == null || amount <= 0) {
                            return 'Nominal harus berupa angka lebih besar dari 0';
                          }
                          if (amount >= 1e12) {
                            return 'Nominal tidak boleh mencapai atau melebihi 1 triliun';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: notesController,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Keterangan (Penerima / Peruntukan)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Keterangan tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Batal',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final messenger = ScaffoldMessenger.of(context);
                                final amount = double.parse(
                                  amountController.text,
                                );
                                try {
                                  viewModel.updateInfaqLog(
                                    id: log.id,
                                    amount: amount,
                                    notes: notesController.text,
                                  );
                                  Navigator.pop(context);
                                } on RamadhanValidationError catch (e) {
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: theme.colorScheme.error,
                                      content: Text(
                                        e.message,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                } catch (_) {
                                  messenger.clearSnackBars();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: theme.colorScheme.error,
                                      content: const Text(
                                        'Gagal memperbarui catatan sedekah.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Simpan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
