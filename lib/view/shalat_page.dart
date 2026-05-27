import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/shalat_view_model.dart';
import '../repository/shalat_repository.dart';
import 'shalat_detail_page.dart';
import 'auth_dialogs.dart';

class ShalatPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  static const routeName = '/shalat';
  const ShalatPage({super.key, required this.scaffoldKey});

  @override
  State<ShalatPage> createState() => _ShalatPageState();
}

class _ShalatPageState extends State<ShalatPage> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isScrolled = false;

  late final ShalatViewModel _viewModel;
  bool _needsScrollToToday = true;

  Timer? _debounceTimer;
  Future<List<Map<String, dynamic>>>? _searchFuture;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    _viewModel = context.read<ShalatViewModel>();
    _viewModel.addListener(_onViewModelChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_viewModel.updateLocationAndFetchSchedule());
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _viewModel.removeListener(_onViewModelChanged);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    setState(() {
      _searchQuery = query;
      _searchFuture = null;
    });

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchFuture = context.read<ShalatRepository>().searchCities(trimmed);
      });
    });
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 0;
    if (scrolled != _isScrolled) {
      setState(() {
        _isScrolled = scrolled;
      });
    }
  }

  void _onViewModelChanged() {
    if (_viewModel.isLoading) {
      _needsScrollToToday = true;
    } else if (_needsScrollToToday && _viewModel.schedules.isNotEmpty) {
      _needsScrollToToday = false;
      final index = _findCurrentDayIndex();
      if (index >= 0) {
        final offset = index == 0 ? 0.0 : (12.0 + index * 73.0);
        _scrollController.dispose();
        _scrollController = ScrollController(initialScrollOffset: offset)
          ..addListener(_onScroll);
        _isScrolled = offset > 0;
      }
    }
  }

  int _findCurrentDayIndex() {
    final schedules = _viewModel.schedules;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < schedules.length; i++) {
      final d = schedules[i];
      try {
        final parts = d.tanggal.split(', ');
        if (parts.length >= 2) {
          final dateParts = parts[1].split('/');
          if (dateParts.length >= 3) {
            final day = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final year = int.parse(dateParts[2]);
            final scheduleDate = DateTime(year, month, day);
            if (scheduleDate.isAtSameMomentAs(todayDate)) {
              return i;
            }
          }
        }
      } catch (_) {}
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShalatViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 8.0,
        title: Container(
          height: 48,
          margin: const EdgeInsets.only(right: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: _searchController,
            textAlignVertical: TextAlignVertical.center,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari kota...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.6,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              isDense: true,
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        actions: [ProfileMonogram(scaffoldKey: widget.scaffoldKey)],
      ),
      body: RefreshIndicator(
        onRefresh: () => context
            .read<ShalatViewModel>()
            .updateLocationAndFetchSchedule(forceGPS: true),
        child: Builder(
          builder: (context) {
            if (_searchQuery.isNotEmpty) {
              if (_searchFuture == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _searchFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Gagal mencari kota: ${snapshot.error}',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    );
                  }

                  final cities = snapshot.data ?? [];
                  if (cities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Kota "$_searchQuery" tidak ditemukan',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: cities.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 2),
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      final cityName = city['lokasi'] as String? ?? '';
                      final cityIdStr = city['id'] as String? ?? '';
                      final cityId = int.tryParse(cityIdStr);

                      final isFirst = index == 0;
                      final isLast = index == cities.length - 1;
                      final borderRadius = BorderRadius.only(
                        topLeft: Radius.circular(isFirst ? 16 : 0),
                        topRight: Radius.circular(isFirst ? 16 : 0),
                        bottomLeft: Radius.circular(isLast ? 16 : 0),
                        bottomRight: Radius.circular(isLast ? 16 : 0),
                      );

                      return Card.filled(
                        margin: EdgeInsets.zero,
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.15,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: borderRadius,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 4.0,
                          ),
                          leading: Icon(
                            Icons.location_city,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            cityName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                            size: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: borderRadius,
                          ),
                          onTap: () {
                            if (cityId != null) {
                              unawaited(vm.selectCity(cityId, cityName));
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _searchQuery = '';
                              });
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }

            if (vm.isLoadingLocation) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Mendeteksi koordinat GPS...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error != null) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Gagal memuat data:\n${vm.error}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => context
                                  .read<ShalatViewModel>()
                                  .updateLocationAndFetchSchedule(
                                    forceGPS: true,
                                  ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            if (vm.schedules.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(child: const Text('Data kosong')),
                    ),
                  );
                },
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card.filled(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.18,
                            ),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.location_on_rounded,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          vm.cityName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: vm.schedules.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: theme.colorScheme.surface,
                      thickness: 1.5,
                    ),
                    itemBuilder: (context, i) {
                      final d = vm.schedules[i];
                      final isFirst = i == 0;
                      final isLast = i == vm.schedules.length - 1;

                      final now = DateTime.now();
                      final todayDate = DateTime(now.year, now.month, now.day);

                      DateTime? scheduleDate;
                      try {
                        final parts = d.tanggal.split(', ');
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

                      String status = 'upcoming';
                      if (scheduleDate != null) {
                        if (scheduleDate.isBefore(todayDate)) {
                          status = 'passed';
                        } else if (scheduleDate.isAtSameMomentAs(todayDate)) {
                          status = 'current';
                        }
                      }

                      Color bgColor;
                      Color textColor;
                      Color chevronColor;
                      FontWeight textWeight;

                      switch (status) {
                        case 'passed':
                          bgColor = theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.10);
                          textColor = theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          );
                          chevronColor = theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.3);
                          textWeight = FontWeight.w400;
                          break;
                        case 'current':
                          bgColor = theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          );
                          textColor = theme.colorScheme.primary;
                          chevronColor = theme.colorScheme.primary;
                          textWeight = FontWeight.bold;
                          break;
                        default:
                          bgColor = theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.25);
                          textColor = theme.colorScheme.onSurface;
                          chevronColor = theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.8);
                          textWeight = FontWeight.w500;
                      }

                      String mainTitle = '';
                      String subtitle = '';

                      try {
                        final parts = d.tanggal.split(', ');
                        if (parts.length >= 2) {
                          final dayName = parts[0];
                          final dateParts = parts[1].split('/');
                          if (dateParts.length >= 3) {
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

                            final today = DateTime.now();
                            final todayDate = DateTime(
                              today.year,
                              today.month,
                              today.day,
                            );
                            final targetDate = DateTime(year, month, day);

                            if (targetDate.isAtSameMomentAs(todayDate)) {
                              mainTitle = 'Hari Ini';
                              subtitle = "$dayName, $day $monthName $year";
                            } else if (targetDate.isAtSameMomentAs(
                              todayDate.add(const Duration(days: 1)),
                            )) {
                              mainTitle = 'Besok';
                              subtitle = "$dayName, $day $monthName $year";
                            } else if (targetDate.isAtSameMomentAs(
                              todayDate.subtract(const Duration(days: 1)),
                            )) {
                              mainTitle = 'Kemarin';
                              subtitle = "$dayName, $day $monthName $year";
                            } else {
                              mainTitle = dayName;
                              subtitle = "$day $monthName $year";
                            }
                          }
                        }
                      } catch (_) {
                        mainTitle = d.tanggal;
                        subtitle = '';
                      }

                      final borderRadius = BorderRadius.only(
                        topLeft: Radius.circular(isFirst ? 16 : 0),
                        topRight: Radius.circular(isFirst ? 16 : 0),
                        bottomLeft: Radius.circular(isLast ? 16 : 0),
                        bottomRight: Radius.circular(isLast ? 16 : 0),
                      );

                      return Material(
                        color: bgColor,
                        borderRadius: borderRadius,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            unawaited(
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ShalatDetailPage(schedule: d),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mainTitle,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: textWeight,
                                            color: textColor,
                                          ),
                                    ),
                                    if (subtitle.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        subtitle,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: status == 'passed'
                                                  ? theme.colorScheme.onSurface
                                                        .withValues(alpha: 0.3)
                                                  : theme
                                                        .colorScheme
                                                        .onSurfaceVariant
                                                        .withValues(alpha: 0.8),
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: chevronColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
