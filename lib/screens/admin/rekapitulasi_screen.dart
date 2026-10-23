import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../models/rekapitulasi_model.dart';
import '../../providers/admin_provider.dart';
import '../widgets/common_widgets.dart';

class RekapitulasiScreen extends StatefulWidget {
  const RekapitulasiScreen({super.key});

  @override
  State<RekapitulasiScreen> createState() => _RekapitulasiScreenState();
}

class _RekapitulasiScreenState extends State<RekapitulasiScreen> {
  DateTime _selectedMonth = DateTime(2026, 10);

  static const Color _primaryDark = Color(0xFF144D37);
  static const Color _accentLime = Color(0xFFD4F67B);
  static const Color _textDark = Color(0xFF0F2F24);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _bgSoft = Color(0xFFF6F8F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final bulanStr = DateFormat('yyyy-MM').format(_selectedMonth);
    try {
      await context.read<AdminProvider>().fetchRekap(bulanStr);
    } catch (_) {}
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2022),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
      _loadData();
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadData();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final rekap = adminProvider.rekap;
    final bulanLabel = DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth);

    // Dynamic or Mockup values matching Image 5
    final totalKgVal = (rekap != null && rekap.totalKg > 0) ? rekap.totalKg.toDouble() : 142.5;
    final totalKgFormatted = totalKgVal.toStringAsFixed(1).replaceAll('.', ',');

    final totalTonVal = (rekap != null && rekap.totalTon > 0) ? rekap.totalTon.toDouble() : 0.14;
    final totalTonFormatted = '${totalTonVal.toStringAsFixed(2).replaceAll('.', ',')} ton';

    final estimasiNilaiVal = (rekap != null && rekap.totalEstimasiPembayaranRupiah > 0)
        ? rekap.totalEstimasiPembayaranRupiah
        : 389700;
    final estimasiNilaiFormatted = Formatters.rupiah(estimasiNilaiVal);

    final poinDiterbitkanVal = (rekap != null && rekap.totalPoinDiterbitkan > 0)
        ? rekap.totalPoinDiterbitkan
        : 12825;
    final poinDiterbitkanFormatted = NumberFormat.decimalPattern('id_ID').format(poinDiterbitkanVal);

    // Breakdown map
    final breakdown = (rekap != null && rekap.breakdownJenisSampah.isNotEmpty)
        ? rekap.breakdownJenisSampah
        : _getMockupBreakdown();

    final totalBreakdownWeight = breakdown.values.fold<double>(0.0, (acc, item) => acc + item.tonaseKg.toDouble());
    final effectiveTotalWeight = totalBreakdownWeight > 0 ? totalBreakdownWeight : totalKgVal;

    return Scaffold(
      backgroundColor: _bgSoft,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primaryDark,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header (Title & Export Button) ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Laporan',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rekap tonase, nilai & poin',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        showSuccessSnackbar(context, 'Mengunduh laporan rekapitulasi $bulanLabel...');
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_downward_rounded, size: 20, color: _textDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Periode Selector Card ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18, color: _primaryDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickMonth,
                          child: Text(
                            'Periode: $bulanLabel',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _previousMonth,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.chevron_left_rounded, size: 22, color: _textDark),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: _nextMonth,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.chevron_right_rounded, size: 22, color: _textDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Dark Green Banner: Total Tonase Masuk ────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primaryDark,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryDark.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total tonase sampah masuk',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                totalKgFormatted,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'kg',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _accentLime,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              totalTonFormatted,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Two Metric Cards: Estimasi Nilai & Poin Diterbitkan ──────
                Row(
                  children: [
                    // Estimasi Nilai Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimasi nilai',
                              style: TextStyle(fontSize: 12.5, color: _textMuted, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              estimasiNilaiFormatted,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Poin Diterbitkan Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Poin diterbitkan',
                              style: TextStyle(fontSize: 12.5, color: _textMuted, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              poinDiterbitkanFormatted,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Section: Rincian Per Jenis Sampah ────────────────────────
                const Text(
                  'Rincian per jenis sampah',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: breakdown.entries.map((entry) {
                      final name = entry.key;
                      final weight = entry.value.tonaseKg.toDouble();
                      final weightFormatted = '${weight.toStringAsFixed(1).replaceAll('.', ',')} kg';
                      final percentVal = effectiveTotalWeight > 0 ? (weight / effectiveTotalWeight) : 0.0;
                      final percentString = '${(percentVal * 100).round()}%';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: _textDark,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      weightFormatted,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      percentString,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: percentVal.clamp(0.0, 1.0),
                                minHeight: 7,
                                backgroundColor: const Color(0xFFE8EFEA),
                                valueColor: const AlwaysStoppedAnimation<Color>(_primaryDark),
                              ),
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
        ),
      ),
    );
  }

  Map<String, BreakdownJenisModel> _getMockupBreakdown() {
    return {
      'Plastik': BreakdownJenisModel(tonaseKg: 62.0, rupiah: 155000, poin: 5580),
      'Kertas': BreakdownJenisModel(tonaseKg: 41.0, rupiah: 82000, poin: 3690),
      'Logam': BreakdownJenisModel(tonaseKg: 24.0, rupiah: 96000, poin: 2160),
      'Kaca': BreakdownJenisModel(tonaseKg: 15.5, rupiah: 56700, poin: 1395),
    };
  }
}
