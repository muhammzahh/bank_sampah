import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/rekapitulasi_model.dart';
import '../../providers/admin_provider.dart';

class RekapitulasiScreen extends StatefulWidget {
  const RekapitulasiScreen({super.key});

  @override
  State<RekapitulasiScreen> createState() => _RekapitulasiScreenState();
}

class _RekapitulasiScreenState extends State<RekapitulasiScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final bulanStr = DateFormat('yyyy-MM').format(_selectedMonth);
    await context.read<AdminProvider>().fetchRekap(bulanStr);
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Pilih Bulan & Tahun Rekapitulasi',
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
      _loadData();
    }
  }

  String? _jenisAssetIcon(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'plastik':
        return 'assets/icons/plastik.png';
      case 'kertas':
        return 'assets/icons/kertas.png';
      case 'logam':
        return 'assets/icons/logam.png';
      case 'kaca':
        return 'assets/icons/kaca.webp';
      default:
        return null;
    }
  }

  IconData _jenisIcon(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'plastik':
        return Icons.local_drink_outlined;
      case 'kertas':
        return Icons.description_outlined;
      case 'logam':
        return Icons.precision_manufacturing_outlined;
      case 'kaca':
        return Icons.wine_bar_outlined;
      case 'organik':
        return Icons.eco_outlined;
      default:
        return Icons.delete_outline;
    }
  }

  Color _jenisColor(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'plastik':
        return Colors.blue;
      case 'kertas':
        return Colors.orange;
      case 'logam':
        return Colors.blueGrey;
      case 'kaca':
        return Colors.teal;
      case 'organik':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final rekap = adminProvider.rekap;
    final bulanLabel = DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header Gradien Hijau Zamrud ────────────────────────────
          Container(
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Laporan Rekapitulasi',
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
                                  bulanLabel,
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
                      'Rekap tonase, estimasi nilai, dan penukaran poin',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: adminProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : rekap == null
                      ? _buildEmptyOrError(adminProvider.errorMessage)
                      : _buildContent(rekap, bulanLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrError(String? error) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        const Icon(
          Icons.bar_chart_outlined,
          size: 72,
          color: AppColors.textGrey,
        ),
        const SizedBox(height: 16),
        Text(
          error ?? 'Belum ada data rekapitulasi untuk periode ini',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppColors.textGrey),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(RekapitulasiModel rekap, String bulanLabel) {
    final breakdown = rekap.breakdownJenisSampah;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card Header Periode
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.date_range, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Periode: ${rekap.periode.isNotEmpty ? rekap.periode : bulanLabel}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section 1: Penyetoran Sampah Masuk
        const Text(
          'Rekapitulasi Sampah Masuk',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),

        // Highlight Card: Total Berat Sampah
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.scale, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text('Total Tonase Sampah', style: TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${rekap.totalKg}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('Kg', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${rekap.totalTon} Ton',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Row of 2 stats: Nilai Rupiah & Poin Diterbitkan
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.monetization_on_outlined,
                iconColor: Colors.amber.shade800,
                label: 'Estimasi Nilai',
                value: Formatters.rupiah(rekap.totalEstimasiPembayaranRupiah),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.stars_outlined,
                iconColor: Colors.deepPurple,
                label: 'Poin Diterbitkan',
                value: '${rekap.totalPoinDiterbitkan} Poin',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Section 2: Breakdown per Jenis Sampah
        const Text(
          'Rincian per Jenis Sampah',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),

        if (breakdown.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Belum ada rincian kategori untuk periode ini',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
          )
        else
          ...breakdown.entries.map((entry) {
            final jenis = entry.key;
            final data = entry.value;
            final color = _jenisColor(jenis);
            final icon = _jenisIcon(jenis);
            final assetIcon = _jenisAssetIcon(jenis);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: assetIcon != null
                          ? Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                assetIcon,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(icon, color: color, size: 22),
                              ),
                            )
                          : Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jenis.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nilai: ${Formatters.rupiah(data.rupiah)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${data.tonaseKg} Kg',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${data.poin} Poin',
                          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 24),

        // Section 3: Rekapitulasi Penukaran Poin
        const Text(
          'Rekapitulasi Penukaran Hadiah',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.receipt_long_outlined,
                iconColor: Colors.indigo,
                label: 'Total Transaksi Tukar',
                value: '${rekap.totalTransaksiPenukaran}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.redeem_outlined,
                iconColor: Colors.redAccent,
                label: 'Total Poin Ditukar',
                value: '${rekap.totalPoinTerpakai} Poin',
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
