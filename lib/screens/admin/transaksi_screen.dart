import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/penukaran_poin_provider.dart';
import '../../providers/setor_sampah_provider.dart';
import '../widgets/common_widgets.dart';

/// Sesuai wireframe Lampiran D poin 8: "Data Transaksi (Penyetoran & Penukaran)".
/// Berbeda dari KonfirmasiSetorScreen (untuk AKSI verifikasi), layar ini
/// murni untuk MELIHAT seluruh transaksi dengan filter per bulan.
class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final bulan = Formatters.bulanTahun(_selectedMonth);
    await context.read<SetorSampahProvider>().fetchAdminList(bulan: bulan);
    await context.read<PenukaranPoinProvider>().fetchAdminList(bulan: bulan);
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _selectedMonth = picked);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final setorProvider = context.watch<SetorSampahProvider>();
    final penukaranProvider = context.watch<PenukaranPoinProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header Gradien Hijau Zamrud ────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF10B981)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Data Transaksi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickMonth,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  Formatters.bulanTahunLabel(_selectedMonth),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Laporan penyetoran & penukaran seluruh nasabah',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.amberAccent,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      tabs: const [
                        Tab(text: 'Penyetoran'),
                        Tab(text: 'Penukaran'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
          // Tab Penyetoran (read-only)
          setorProvider.isLoading
              ? const LoadingView()
              : setorProvider.adminSetorList.isEmpty
                  ? const EmptyView(message: 'Tidak ada transaksi penyetoran bulan ini')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: setorProvider.adminSetorList.length,
                      itemBuilder: (context, index) {
                        final s = setorProvider.adminSetorList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(s.kodeSetor ?? s.id, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              '${s.namaNasabah ?? '-'}\n${Formatters.tanggalSingkat(s.tanggal)} • ${s.totalBeratKg} Kg • ${s.totalPoin ?? 0} Poin',
                            ),
                            isThreeLine: true,
                            trailing: StatusBadge(status: s.status),
                          ),
                        );
                      },
                    ),
          // Tab Penukaran (read-only)
          penukaranProvider.isLoading
              ? const LoadingView()
              : penukaranProvider.adminPenukaranList.isEmpty
                  ? const EmptyView(message: 'Tidak ada transaksi penukaran bulan ini')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: penukaranProvider.adminPenukaranList.length,
                      itemBuilder: (context, index) {
                        final p = penukaranProvider.adminPenukaranList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(p.kodePenukaran ?? p.id, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${p.namaNasabah ?? '-'} • ${p.namaHadiah ?? '-'}\n${p.poinTerpakai} Poin'),
                            trailing: StatusBadge(status: p.status),
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
