import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/ramadhan_view_model.dart';
import '../model/ramadhan_record.dart';

class RamadhanPage extends StatefulWidget {
  const RamadhanPage({super.key});

  @override
  State<RamadhanPage> createState() => _RamadhanPageState();
}

class _RamadhanPageState extends State<RamadhanPage> {
  int _selectedDay = 1; // Default hari ke-1 Ramadhan

  // Helper untuk format rupiah sederhana tanpa library eksternal
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

  // Helper untuk format tanggal sederhana
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catatan Ramadhan'),
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

  // ================= TAB SHALAT =================
  Widget _buildShalatTab(BuildContext context, RamadhanViewModel viewModel) {
    final theme = Theme.of(context);
    final currentLog = viewModel.shalatLogs[_selectedDay - 1];

    final fardhuPrayers = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
    final sunnahPrayers = ['Tarawih', 'Witir', 'Dhuha', 'Tahajjud'];

    // Hitung persentase ketercapaian hari ini
    final totalPrayers = fardhuPrayers.length + sunnahPrayers.length;
    final donePrayers = currentLog.prayers.values.where((v) => v).length;
    final percent = donePrayers / totalPrayers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row Selector Hari
          Card(
            elevation: 0,
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Hari Ramadhan:',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<int>(
                    value: _selectedDay,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(12),
                    icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                    items: List.generate(30, (index) {
                      final dayNum = index + 1;
                      return DropdownMenuItem<int>(
                        value: dayNum,
                        child: Text(
                          'Hari ke-$dayNum',
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDay = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar ketercapaian
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress Ibadah Hari ke-$_selectedDay',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$donePrayers/$totalPrayers Ibadah',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: percent,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 10,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Judul Shalat Fardhu
          _buildSectionHeader(context, 'Shalat Fardhu'),
          const SizedBox(height: 8),
          ...fardhuPrayers.map((prayer) => _buildPrayerTile(context, viewModel, _selectedDay, prayer)),
          const SizedBox(height: 20),

          // Judul Shalat Sunnah
          _buildSectionHeader(context, 'Shalat Sunnah'),
          const SizedBox(height: 8),
          ...sunnahPrayers.map((prayer) => _buildPrayerTile(context, viewModel, _selectedDay, prayer)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPrayerTile(
    BuildContext context, 
    RamadhanViewModel viewModel, 
    int day, 
    String prayerName
  ) {
    final theme = Theme.of(context);
    final log = viewModel.shalatLogs[day - 1];
    final isChecked = log.prayers[prayerName] ?? false;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isChecked 
              ? theme.colorScheme.primary.withValues(alpha: 0.5) 
              : theme.colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 8.0),
      color: isChecked 
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1) 
          : theme.colorScheme.surface,
      child: CheckboxListTile(
        title: Text(
          prayerName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isChecked ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          isChecked ? 'Sudah dilaksanakan' : 'Belum dilaksanakan',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isChecked ? theme.colorScheme.primary.withValues(alpha: 0.8) : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        value: isChecked,
        activeColor: theme.colorScheme.primary,
        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: (_) {
          viewModel.togglePrayer(day, prayerName);
        },
      ),
    );
  }

  // ================= TAB CERAMAH =================
  Widget _buildCeramahTab(BuildContext context, RamadhanViewModel viewModel) {
    final theme = Theme.of(context);

    if (viewModel.ceramahLogs.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_late, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'Belum ada catatan ceramah.',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                'Catat ceramah tarawih atau kultum Anda di sini.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddCeramahDialog(context, viewModel),
          label: const Text('Tambah Catatan'),
          icon: const Icon(Icons.add),
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: viewModel.ceramahLogs.length,
        itemBuilder: (context, index) {
          final log = viewModel.ceramahLogs[index];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showCeramahDetailBottomSheet(context, log, viewModel),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            log.title,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
                          onPressed: () => _showDeleteConfirmDialog(
                            context: context,
                            title: 'Hapus Catatan',
                            content: 'Apakah Anda yakin ingin menghapus catatan ceramah "${log.title}"?',
                            onConfirm: () => viewModel.deleteCeramahLog(log.id),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          log.speaker,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_month, size: 16, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(log.date),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      log.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCeramahDialog(context, viewModel),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCeramahDialog(BuildContext context, RamadhanViewModel viewModel) {
    final titleController = TextEditingController();
    final speakerController = TextEditingController();
    final summaryController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.menu_book, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Catat Ceramah'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul / Tema Materi',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Judul tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: speakerController,
                    decoration: const InputDecoration(
                      labelText: 'Penceramah / Ustadz',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nama penceramah tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: summaryController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Ringkasan Catatan Materi',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Ringkasan tidak boleh kosong' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  viewModel.addCeramahLog(
                    speaker: speakerController.text,
                    title: titleController.text,
                    summary: summaryController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Catatan ceramah berhasil ditambahkan!')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showCeramahDetailBottomSheet(BuildContext context, CeramahLog log, RamadhanViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    log.title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person, size: 14, color: theme.colorScheme.onPrimaryContainer),
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
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    'Ringkasan Ceramah:',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    log.summary,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================= TAB INFAQ =================
  Widget _buildInfaqTab(BuildContext context, RamadhanViewModel viewModel) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Accumulation Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'TOTAL SEDEKAH & INFAQ RAMADHAN',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatRupiah(viewModel.totalInfaq),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Semoga menjadi amal jariyah yang dilipatgandakan. Aamiin.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Riwayat Transaksi Infaq',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: viewModel.infaqLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volunteer_activism_outlined, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada transaksi infaq.',
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mulai tabungan akhirat dengan berinfaq.',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: viewModel.infaqLogs.length,
                    itemBuilder: (context, index) {
                      final log = viewModel.infaqLogs[index];
                      return Card(
                        elevation: 0.5,
                        margin: const EdgeInsets.only(bottom: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                            child: Icon(Icons.volunteer_activism, color: theme.colorScheme.primary, size: 20),
                          ),
                          title: Text(
                            _formatRupiah(log.amount),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.notes, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(log.date),
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
                            onPressed: () => _showDeleteConfirmDialog(
                              context: context,
                              title: 'Hapus Transaksi',
                              content: 'Apakah Anda yakin ingin menghapus catatan infaq sebesar ${_formatRupiah(log.amount)}?',
                              onConfirm: () => viewModel.deleteInfaqLog(log.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInfaqDialog(context, viewModel),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddInfaqDialog(BuildContext context, RamadhanViewModel viewModel) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.volunteer_activism, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Catat Sedekah / Infaq'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nominal Rupiah (Rp)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan (Penerima / Peruntukan)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Keterangan tidak boleh kosong' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final amount = double.parse(amountController.text);
                  viewModel.addInfaqLog(
                    amount: amount,
                    notes: notesController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Catatan sedekah berhasil disimpan!')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // ================= GENERAL COMMON DIALOGS =================
  void _showDeleteConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
