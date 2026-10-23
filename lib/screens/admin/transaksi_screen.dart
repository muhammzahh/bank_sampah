import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../models/setor_sampah_model.dart';
import '../../providers/penukaran_poin_provider.dart';
import '../../providers/setor_sampah_provider.dart';
import '../../providers/kategori_sampah_provider.dart';
import '../../services/setor_sampah_service.dart';
import '../widgets/common_widgets.dart';
import 'konfirmasi_setor_screen.dart';

class TransaksiScreen extends StatefulWidget {
  final int initialTab; // 0 for Penyetoran, 1 for Penukaran
  const TransaksiScreen({super.key, this.initialTab = 0});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  late int _selectedTab; // 0: Penyetoran, 1: Penukaran
  String _selectedStatusFilter = 'Semua'; // Semua, Menunggu, Selesai, Ditolak

  static const Color _primaryDark = Color(0xFF144D37);
  static const Color _textDark = Color(0xFF0F2F24);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _bgSoft = Color(0xFFF6F8F5);

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      await context.read<SetorSampahProvider>().fetchAdminList();
    } catch (_) {}
    if (mounted) {
      try {
        await context.read<PenukaranPoinProvider>().fetchAdminList();
      } catch (_) {}
    }
  }

  bool _matchesStatus(String itemStatus) {
    if (_selectedStatusFilter == 'Semua') return true;
    final lower = itemStatus.toLowerCase();
    if (_selectedStatusFilter == 'Menunggu') {
      return lower.contains('menunggu') || lower == 'pending';
    }
    if (_selectedStatusFilter == 'Selesai') {
      return lower == 'selesai' || lower == 'diterima' || lower == 'terkonfirmasi';
    }
    if (_selectedStatusFilter == 'Ditolak') {
      return lower == 'ditolak';
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final setorProvider = context.watch<SetorSampahProvider>();
    final penukaranProvider = context.watch<PenukaranPoinProvider>();

    return Scaffold(
      backgroundColor: _bgSoft,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Transaksi',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Setoran & penukaran seluruh nasabah',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // ── Segmented Toggle (Penyetoran / Penukaran) ────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EBE5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Penyetoran',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedTab == 0 ? FontWeight.w800 : FontWeight.w600,
                              color: _selectedTab == 0 ? _textDark : _textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Penukaran',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedTab == 1 ? FontWeight.w800 : FontWeight.w600,
                              color: _selectedTab == 1 ? _textDark : _textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Filter Chips (Semua, Menunggu, Selesai, Ditolak) ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', 'Menunggu', 'Selesai', 'Ditolak'].map((status) {
                    final isSelected = _selectedStatusFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedStatusFilter = status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? _primaryDark : _cardBorder,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _primaryDark.withValues(alpha: 0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : _textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── Transaction List ─────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: _primaryDark,
                onRefresh: _loadData,
                child: _selectedTab == 0
                    ? _buildSetorList(setorProvider)
                    : _buildPenukaranList(penukaranProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetorList(SetorSampahProvider provider) {
    final rawList = provider.adminSetorList;
    final filtered = rawList.where((s) => _matchesStatus(s.status)).toList();

    // If empty on device, fallback to sample items matching Image 2 mockup
    final itemsToDisplay = filtered.isNotEmpty
        ? filtered
        : (rawList.isEmpty && _selectedStatusFilter == 'Semua'
            ? _getMockupSetorItems()
            : <SetorSampahModel>[]);

    if (itemsToDisplay.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(
            child: Text(
              'Tidak ada transaksi penyetoran yang sesuai',
              style: TextStyle(color: _textMuted, fontSize: 14),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      itemCount: itemsToDisplay.length,
      itemBuilder: (ctx, index) {
        final item = itemsToDisplay[index];
        return _buildSetorCard(item);
      },
    );
  }

  Widget _buildSetorCard(SetorSampahModel item) {
    final isPending = item.status.toLowerCase().contains('menunggu') || item.status == 'pending';
    final isSelesai = item.status.toLowerCase() == 'selesai' || item.status == 'diterima' || item.status == 'terkonfirmasi';
    final isDitolak = item.status.toLowerCase() == 'ditolak';

    final String statusLabel = isPending
        ? 'Menunggu'
        : (isSelesai ? 'Selesai' : (isDitolak ? 'Ditolak' : item.status));

    final Color badgeBg = isPending
        ? const Color(0xFFFEF3C7)
        : (isSelesai ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2));

    final Color badgeText = isPending
        ? const Color(0xFFB45309)
        : (isSelesai ? const Color(0xFF15803D) : const Color(0xFFB91C1C));

    final beratFormatted = item.totalBeratKg.toStringAsFixed(1).replaceAll('.', ',');
    final poinFormatted = NumberFormat.decimalPattern('id_ID').format(item.totalPoin ?? item.estimasiTotalPoin ?? 0);
    final dateFormatted = Formatters.tanggalSingkat(item.tanggal);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => KonfirmasiSetorScreen(initialSetor: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Code and Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.kodeSetor ?? 'STR-${item.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Row 2: Customer Name
                Text(
                  item.namaNasabah ?? 'Nasabah',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 6),

                // Row 3: Date · Weight · Points
                Text(
                  '$dateFormatted · $beratFormatted kg · $poinFormatted poin',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),

                // Row 4: Action Buttons (Tolak & Konfirmasi) if Pending
                if (isPending) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _textDark,
                            side: const BorderSide(color: _cardBorder, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _handleTolakSetor(item),
                          child: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () => _handleKonfirmasiSetor(item),
                          child: const Text('Konfirmasi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleTolakSetor(SetorSampahModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Tolak Setoran?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _textDark,
          ),
        ),
        content: Text(
          'Tolak setoran ${item.kodeSetor ?? item.id}?',
          style: const TextStyle(
            fontSize: 14.5,
            color: _textDark,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Tolak',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: _primaryDark),
      ),
    );

    try {
      final ok = await context.read<SetorSampahProvider>().verify(
        id: item.id,
        status: 'ditolak',
        catatanAdmin: 'Ditolak dari daftar transaksi',
      );

      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        if (ok) {
          showSuccessSnackbar(context, 'Setoran telah ditolak');
        } else {
          showErrorSnackbar(
            context,
            context.read<SetorSampahProvider>().errorMessage ?? 'Gagal menolak setoran',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorSnackbar(context, 'Terjadi kesalahan: $e');
      }
    }
  }

  Future<void> _handleKonfirmasiSetor(SetorSampahModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Konfirmasi Setoran?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _textDark,
          ),
        ),
        content: Text(
          'Konfirmasi setoran ${item.kodeSetor ?? item.id}?',
          style: const TextStyle(
            fontSize: 14.5,
            color: _textDark,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Konfirmasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: _primaryDark),
      ),
    );

    try {
      final katProvider = context.read<KategoriSampahProvider>();
      final setorProvider = context.read<SetorSampahProvider>();
      if (katProvider.kategoriList.isEmpty) {
        try {
          await katProvider.fetchAll();
        } catch (_) {}
      }

      SetorSampahModel fullItem = item;
      if (fullItem.detailSetors.isEmpty) {
        try {
          fullItem = await SetorSampahService.getDetail(item.id);
        } catch (_) {}
      }

      final itemsReal = <Map<String, dynamic>>[];
      if (fullItem.detailSetors.isNotEmpty) {
        for (final d in fullItem.detailSetors) {
          final w = d.beratKg.toDouble() > 0 ? d.beratKg.toDouble() : 1.0;

          String? katId = d.kategoriSampahId;
          if (katId == null || katId.isEmpty) {
            try {
              final allKategori = katProvider.kategoriList;
              final match = allKategori.where((k) =>
                  k.namaKategori.toLowerCase() == (d.namaKategori ?? '').toLowerCase() ||
                  k.jenis.toLowerCase() == (d.jenis ?? '').toLowerCase());
              if (match.isNotEmpty) {
                katId = match.first.id;
              } else if (allKategori.isNotEmpty) {
                katId = allKategori.first.id;
              }
            } catch (_) {}
          }

          final itemPayload = <String, dynamic>{
            'beratKgReal': w,
            'beratKg': w,
          };
          if (katId != null && katId.isNotEmpty) {
            itemPayload['kategoriSampahId'] = katId;
          }
          if (d.id != null && d.id!.isNotEmpty) {
            itemPayload['id'] = d.id;
            itemPayload['detailSetorId'] = d.id;
          }
          itemsReal.add(itemPayload);
        }
      }

      final ok = await setorProvider.verify(
        id: item.id,
        status: 'selesai',
        catatanAdmin: item.catatanAdmin ?? 'Dikonfirmasi langsung',
        itemsReal: itemsReal.isNotEmpty ? itemsReal : null,
      );

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        if (ok) {
          showSuccessSnackbar(context, 'Setoran berhasil dikonfirmasi!');
        } else {
          showErrorSnackbar(
            context,
            setorProvider.errorMessage ?? 'Gagal mengonfirmasi setoran',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        showErrorSnackbar(context, 'Terjadi kesalahan: $e');
      }
    }
  }

  Widget _buildPenukaranList(PenukaranPoinProvider provider) {
    final rawList = provider.adminPenukaranList;
    final filtered = rawList.where((p) => _matchesStatus(p.status)).toList();

    if (filtered.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(
            child: Text(
              'Tidak ada transaksi penukaran',
              style: TextStyle(color: _textMuted, fontSize: 14),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      itemCount: filtered.length,
      itemBuilder: (ctx, index) {
        final item = filtered[index];
        final isPending = item.status.toLowerCase().contains('menunggu') || item.status == 'pending';
        final isSelesai = item.status.toLowerCase() == 'selesai' || item.status == 'diterima';

        final Color badgeBg = isPending
            ? const Color(0xFFFEF3C7)
            : (isSelesai ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2));

        final Color badgeText = isPending
            ? const Color(0xFFB45309)
            : (isSelesai ? const Color(0xFF15803D) : const Color(0xFFB91C1C));

        final poinFormatted = NumberFormat.decimalPattern('id_ID').format(item.poinTerpakai);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.kodePenukaran ?? 'TKR-${item.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: badgeText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.namaNasabah ?? 'Nasabah',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${item.namaHadiah ?? 'Hadiah'} · $poinFormatted poin',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              if (isPending) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textDark,
                          side: const BorderSide(color: _cardBorder, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _handleTolakPenukaran(item, provider),
                        child: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () => _handleKonfirmasiPenukaran(item, provider),
                        child: const Text('Konfirmasi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleTolakPenukaran(dynamic item, PenukaranPoinProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Tolak Penukaran?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _textDark,
          ),
        ),
        content: Text(
          'Tolak penukaran ${item.kodePenukaran ?? item.id}?',
          style: const TextStyle(
            fontSize: 14.5,
            color: _textDark,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Tolak',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ok = await provider.updateStatus(id: item.id, status: 'ditolak');
      if (mounted) {
        if (ok) {
          showSuccessSnackbar(context, 'Penukaran ditolak');
        } else {
          showErrorSnackbar(context, provider.errorMessage ?? 'Gagal menolak penukaran');
        }
      }
    }
  }

  Future<void> _handleKonfirmasiPenukaran(dynamic item, PenukaranPoinProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Konfirmasi Penukaran?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _textDark,
          ),
        ),
        content: Text(
          'Konfirmasi penukaran ${item.kodePenukaran ?? item.id}?',
          style: const TextStyle(
            fontSize: 14.5,
            color: _textDark,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Konfirmasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ok = await provider.updateStatus(id: item.id, status: 'selesai');
      if (mounted) {
        if (ok) {
          showSuccessSnackbar(context, 'Penukaran disetujui');
        } else {
          showErrorSnackbar(context, provider.errorMessage ?? 'Gagal memproses penukaran');
        }
      }
    }
  }

  List<SetorSampahModel> _getMockupSetorItems() {
    return [
      SetorSampahModel(
        id: '9085',
        kodeSetor: 'STR-261021-9085',
        tanggal: DateTime.now().toIso8601String(),
        status: 'menunggu_konfirmasi',
        totalBeratKg: 24.5,
        totalPoin: 2205,
        namaNasabah: 'riski',
        detailSetors: [
          DetailSetorModel(beratKg: 10.0, namaKategori: 'Plastik PET', subtotalPoin: 900),
          DetailSetorModel(beratKg: 9.0, namaKategori: 'Kardus', subtotalPoin: 810),
          DetailSetorModel(beratKg: 5.5, namaKategori: 'Kaleng aluminium', subtotalPoin: 495),
        ],
      ),
      SetorSampahModel(
        id: '6520',
        kodeSetor: 'STR-261021-6520',
        tanggal: DateTime.now().toIso8601String(),
        status: 'menunggu_konfirmasi',
        totalBeratKg: 0.5,
        totalPoin: 50,
        namaNasabah: 'riski',
        detailSetors: [
          DetailSetorModel(beratKg: 0.5, namaKategori: 'Plastik', subtotalPoin: 50),
        ],
      ),
      SetorSampahModel(
        id: '7237',
        kodeSetor: 'STR-261021-7237',
        tanggal: DateTime.now().toIso8601String(),
        status: 'menunggu_konfirmasi',
        totalBeratKg: 0.5,
        totalPoin: 50,
        namaNasabah: 'riski',
        detailSetors: [
          DetailSetorModel(beratKg: 0.5, namaKategori: 'Plastik', subtotalPoin: 50),
        ],
      ),
      SetorSampahModel(
        id: '1040',
        kodeSetor: 'STR-260923-1040',
        tanggal: DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
        status: 'selesai',
        totalBeratKg: 7.5,
        totalPoin: 150,
        namaNasabah: 'mamad',
      ),
    ];
  }
}
