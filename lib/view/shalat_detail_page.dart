import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../model/shalat_schedule_response.dart';
import '../viewmodel/shalat_view_model.dart';
class ShalatDetailPage extends StatefulWidget {
  final ShalatDaySchedule schedule;

  const ShalatDetailPage({super.key, required this.schedule});

  @override
  State<ShalatDetailPage> createState() => _ShalatDetailPageState();
}

class _ShalatDetailPageState extends State<ShalatDetailPage> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;
  Timer? _timer;

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

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
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

  String _formatFriendlyDate(String rawDate) {
    try {
      final parts = rawDate.split(', ');
      if (parts.length < 2) return rawDate;

      final dayName = parts[0];
      final dateParts = parts[1].split('/');
      if (dateParts.length < 3) return rawDate;

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final monthName = months[month - 1];

      return "$dayName, $day $monthName $year";
    } catch (_) {
      return rawDate;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Widget _buildHeaderCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isToday,
    required bool isPastDay,
    required bool isFutureDay,
    required Map<String, String>? upcomingShalat,
    required Duration? timeRemaining,
  }) {
    if (isPastDay) {
      final bgColor = theme.colorScheme.primaryContainer.withValues(
        alpha: 0.10,
      );
      final textColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);

      return SizedBox(
        height: 240,
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.03),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.event_available_rounded,
                    size: 28,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Jadwal Sudah Terlewat',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (isFutureDay) {
      final bgColor = theme.colorScheme.primaryContainer.withValues(
        alpha: 0.25,
      );
      final textColor = theme.colorScheme.onSurface;

      return SizedBox(
        height: 240,
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.event_note_rounded,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Jadwal Belum Aktif',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      final bgColor = theme.colorScheme.primary.withValues(alpha: 0.15);
      final textColor = theme.colorScheme.primary;

      final shalatName = upcomingShalat != null ? upcomingShalat['name']! : '-';
      final cleanName = shalatName.replaceAll(' (Besok)', '');

      return SizedBox(
        height: 240,
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _getShalatIcon(cleanName),
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  cleanName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (timeRemaining != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _formatDuration(timeRemaining),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final shalatItems = [
      {'name': 'Subuh', 'time': widget.schedule.subuh},
      {'name': 'Dzuhur', 'time': widget.schedule.dzuhur},
      {'name': 'Ashar', 'time': widget.schedule.ashar},
      {'name': 'Maghrib', 'time': widget.schedule.maghrib},
      {'name': 'Isya', 'time': widget.schedule.isya},
    ];

    Map<String, String>? upcomingShalat;
    Duration? timeRemaining;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final tomorrowDate = todayDate.add(const Duration(days: 1));

    DateTime? scheduleDate;
    try {
      final parts = widget.schedule.tanggal.split(', ');
      if (parts.length >= 2) {
        final dateParts = parts[1].split('/');
        if (dateParts.length >= 3) {
          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final year = int.parse(dateParts[2]);
          scheduleDate = DateTime(year, month, day);
        }
      }
    } catch (_) {}

    final isPastDay = scheduleDate != null && scheduleDate.isBefore(todayDate);
    final isFutureDay = scheduleDate != null && scheduleDate.isAfter(todayDate);
    final isToday =
        scheduleDate == null || scheduleDate.isAtSameMomentAs(todayDate);

    final vm = context.read<ShalatViewModel>();
    ShalatDaySchedule? todaySchedule;
    for (final s in vm.schedules) {
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

    DateTime? todayIsyaTime;
    if (todaySchedule != null) {
      try {
        final timeParts = todaySchedule.isya.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        todayIsyaTime = DateTime(now.year, now.month, now.day, hour, minute);
      } catch (_) {}
    }

    final bool isAfterTodayIsya =
        todayIsyaTime != null &&
        (now.isAfter(todayIsyaTime) || now.isAtSameMomentAs(todayIsyaTime));

    bool headerIsToday = isToday;
    bool headerIsPastDay = isPastDay;
    bool headerIsFutureDay = isFutureDay;

    if (isAfterTodayIsya) {
      if (scheduleDate != null) {
        if (scheduleDate.isAtSameMomentAs(todayDate)) {
          headerIsToday = false;
          headerIsPastDay = true;
          headerIsFutureDay = false;
        } else if (scheduleDate.isAtSameMomentAs(tomorrowDate)) {
          headerIsToday = true;
          headerIsPastDay = false;
          headerIsFutureDay = false;
        }
      }
    }

    List<Map<String, dynamic>> candidates = [];

    if (headerIsToday) {
      for (final item in shalatItems) {
        try {
          final timeStr = item['time']!;
          final timeParts = timeStr.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          final targetDate = scheduleDate ?? todayDate;
          final targetTime = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            hour,
            minute,
          );

          if (targetTime.isAfter(now)) {
            candidates.add({'item': item, 'dateTime': targetTime});
          } else {
            final tomorrowTime = targetTime.add(const Duration(days: 1));
            candidates.add({
              'item': {'name': '${item['name']} (Besok)', 'time': item['time']},
              'dateTime': tomorrowTime,
            });
          }
        } catch (_) {}
      }

      if (candidates.isNotEmpty) {
        candidates.sort(
          (a, b) =>
              (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime),
        );
        final nextCandidate = candidates.first;
        upcomingShalat = Map<String, String>.from(nextCandidate['item'] as Map);
        timeRemaining = (nextCandidate['dateTime'] as DateTime).difference(now);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Jadwal Shalat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              _formatFriendlyDate(widget.schedule.tanggal),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.8,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 16.0,
              ),
              child: _buildHeaderCard(
                context: context,
                theme: theme,
                isToday: headerIsToday,
                isPastDay: headerIsPastDay,
                isFutureDay: headerIsFutureDay,
                upcomingShalat: upcomingShalat,
                timeRemaining: timeRemaining,
              ),
            ),

            ...shalatItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isFirst = i == 0;
              final isLast = i == shalatItems.length - 1;

              String status = 'upcoming';
              if (isPastDay) {
                status = 'passed';
              } else if (isFutureDay) {
                status = 'upcoming';
              } else {
                try {
                  final timeStr = item['time']!;
                  final timeParts = timeStr.split(':');
                  final hour = int.parse(timeParts[0]);
                  final minute = int.parse(timeParts[1]);
                  final shalatTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    hour,
                    minute,
                  );

                  String? nextTimeStr;
                  if (item['name'] == 'Subuh') {
                    nextTimeStr = widget.schedule.terbit;
                  } else if (i < shalatItems.length - 1) {
                    nextTimeStr = shalatItems[i + 1]['time'];
                  }

                  if (nextTimeStr != null) {
                    final nextParts = nextTimeStr.split(':');
                    final nextHour = int.parse(nextParts[0]);
                    final nextMinute = int.parse(nextParts[1]);
                    final nextShalatTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      nextHour,
                      nextMinute,
                    );

                    if (now.isAfter(shalatTime) &&
                        now.isBefore(nextShalatTime)) {
                      status = 'current';
                    } else if (now.isAfter(nextShalatTime) ||
                        now.isAtSameMomentAs(nextShalatTime)) {
                      status = 'passed';
                    } else if (now.isBefore(shalatTime)) {
                      status = 'upcoming';
                    } else {
                      status = 'passed';
                    }
                  } else {
                    if (now.isAfter(shalatTime) ||
                        now.isAtSameMomentAs(shalatTime)) {
                      status = 'current';
                    } else {
                      status = 'upcoming';
                    }
                  }
                } catch (_) {}
              }

              Color bgColor;
              double iconAlpha;
              Color textColor;
              Color timeColor;
              FontWeight textWeight;

              switch (status) {
                case 'passed':
                  bgColor = theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.10,
                  );
                  iconAlpha = 0.3;
                  textColor = theme.colorScheme.onSurface.withValues(
                    alpha: 0.4,
                  );
                  timeColor = theme.colorScheme.onSurface.withValues(
                    alpha: 0.4,
                  );
                  textWeight = FontWeight.w400;
                  break;
                case 'current':
                  bgColor = theme.colorScheme.primary.withValues(alpha: 0.15);
                  iconAlpha = 1.0;
                  textColor = theme.colorScheme.primary;
                  timeColor = theme.colorScheme.primary;
                  textWeight = FontWeight.bold;
                  break;
                default:
                  bgColor = theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.25,
                  );
                  iconAlpha = 1.0;
                  textColor = theme.colorScheme.onSurface;
                  timeColor = theme.colorScheme.onSurface;
                  textWeight = FontWeight.w500;
              }

              final borderRadius = BorderRadius.only(
                topLeft: Radius.circular(isFirst ? 16 : 0),
                topRight: Radius.circular(isFirst ? 16 : 0),
                bottomLeft: Radius.circular(isLast ? 16 : 0),
                bottomRight: Radius.circular(isLast ? 16 : 0),
              );

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Material(
                      color: bgColor,
                      borderRadius: borderRadius,
                      clipBehavior: Clip.antiAlias,
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
                                color: status == 'current'
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.2,
                                      )
                                    : theme.colorScheme.primary.withValues(
                                        alpha: 0.1 * iconAlpha,
                                      ),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _getShalatIcon(item['name']!),
                                size: 20,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: iconAlpha,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item['name']!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: textWeight,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Text(
                              item['time']!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: timeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: theme.colorScheme.surface,
                        thickness: 1.5,
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
