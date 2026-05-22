import 'package:flutter/material.dart';
import '../model/shalat_schedule_response.dart';

class ShalatDetailPage extends StatefulWidget {
  final ShalatDaySchedule schedule;

  const ShalatDetailPage({super.key, required this.schedule});

  @override
  State<ShalatDetailPage> createState() => _ShalatDetailPageState();
}

class _ShalatDetailPageState extends State<ShalatDetailPage> {
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

    final shalatItems = [
      {'name': 'Imsak', 'time': widget.schedule.imsak},
      {'name': 'Subuh', 'time': widget.schedule.subuh},
      {'name': 'Terbit', 'time': widget.schedule.terbit},
      {'name': 'Dhuha', 'time': widget.schedule.dhuha},
      {'name': 'Dzuhur', 'time': widget.schedule.dzuhur},
      {'name': 'Ashar', 'time': widget.schedule.ashar},
      {'name': 'Maghrib', 'time': widget.schedule.maghrib},
      {'name': 'Isya', 'time': widget.schedule.isya},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Jadwal ${widget.schedule.tanggal}'),
        centerTitle: false,
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.separated(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: shalatItems.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: theme.colorScheme.surface,
            thickness: 1.5,
          ),
          itemBuilder: (context, i) {
            final item = shalatItems[i];
            final isFirst = i == 0;
            final isLast = i == shalatItems.length - 1;

            final borderRadius = BorderRadius.only(
              topLeft: Radius.circular(isFirst ? 16 : 0),
              topRight: Radius.circular(isFirst ? 16 : 0),
              bottomLeft: Radius.circular(isLast ? 16 : 0),
              bottomRight: Radius.circular(isLast ? 16 : 0),
            );

            return Material(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              borderRadius: borderRadius,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  children: [
                    // Circular Star Badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Shalat Name
                    Expanded(
                      child: Text(
                        item['name']!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Shalat Time
                    Text(
                      item['time']!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
