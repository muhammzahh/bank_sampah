import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/penukaran_poin_model.dart';
import '../../providers/penukaran_poin_provider.dart';
import '../widgets/common_widgets.dart';

/// Halaman Admin untuk verifikasi dan konfirmasi penukaran hadiah nasabah.
class KonfirmasiPenukaranScreen extends StatefulWidget {
  const KonfirmasiPenukaranScreen({super.key});

  @override
  State<KonfirmasiPenukaranScreen> createState() => _KonfirmasiPenukaranScreenState();
}

class _KonfirmasiPenukaranScreenState extends State<KonfirmasiPenukaranScreen> {
  String _filterStatus = 'semua'; // 'semua', 'menunggu', 'selesai', 'ditolak'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PenukaranPoinProvider>().fetchAdminList();
    });
  }

  bool _isFinalized(String status) {
    final st = status.toLowerCase().trim();
    return st == 'selesai' || st == 'ditolak';
  }

  Future<void> _handleUpdateStatus(String id, String newStatus, String successMsg) async {
    final ok = await context.read<PenukaranPoinProvider>().updateStatus(
          id: id,
          status: newStatus,
        );
    if (mounted) {
      if (ok) {
        showSuccessSnackbar(context, successMsg);
      } else {
        final err = context.read<PenukaranPoinProvider>().errorMessage ?? 'Gagal memproses penukaran';
        showErrorSnackbar(context, err);
      }
    }
  }

  void _showDetailModal(PenukaranPoinModel item) {
    final isDone = _isFinalized(item.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.namaHadiah ?? 'Detail Penukaran',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ),
                  StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.person_rounded, 'Nasabah', item.namaNasabah ?? '-'),
                    if (item.telpNasabah != null && item.telpNasabah!.isNotEmpty)
                      _infoRow(Icons.phone_rounded, 'No. Telepon', item.telpNasabah!),
                    _infoRow(Icons.calendar_today_rounded, 'Tanggal', Formatters.tanggalIndo(item.tanggal)),
                    _infoRow(Icons.card_giftcard_rounded, 'Hadiah', item.namaHadiah ?? '-'),
                    _infoRow(Icons.stars_rounded, 'Poin Ditukar', '${item.poinTerpakai} Poin'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (!isDone)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.statusDitolak,
                          side: const BorderSide(color: AppColors.statusDitolak),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _handleUpdateStatus(item.id, 'ditolak', 'Penukaran poin ditolak');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Setujui', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _handleUpdateStatus(item.id, 'selesai', 'Penukaran poin berhasil disetujui!');
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftImage(String? foto) {
    if (foto != null && foto.isNotEmpty) {
      final file = File(foto);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      } else if (foto.startsWith('http')) {
        return Image.network(foto, fit: BoxFit.cover);
      }
    }
    return Container(
      color: const Color(0xFFFEF3C7),
      child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFFD97706), size: 24),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filterStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filterStatus = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textGrey,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PenukaranPoinProvider>();

    final filteredList = provider.adminPenukaranList.where((p) {
      if (_filterStatus == 'semua') return true;
      final st = p.status.toLowerCase().trim();
      if (_filterStatus == 'menunggu') {
        return !_isFinalized(st);
      }
      return st == _filterStatus;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header Gradien Hijau Full Width ────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (Navigator.canPop(context)) ...[
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                    const Text(
                      'Konfirmasi Penukaran 🎁',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verifikasi & proses pengajuan penukaran poin nasabah',
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

          // ── Filter Chips ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('semua', 'Semua'),
                  _filterChip('menunggu', 'Menunggu Konfirmasi'),
                  _filterChip('selesai', 'Disetujui / Selesai'),
                  _filterChip('ditolak', 'Ditolak'),
                ],
              ),
            ),
          ),

          // ── List Penukaran Poin ───────────────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const LoadingView()
                : filteredList.isEmpty
                    ? const EmptyView(
                        message: 'Tidak ada pengajuan penukaran poin',
                        icon: Icons.card_giftcard_rounded,
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => provider.fetchAdminList(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredList.length,
                          itemBuilder: (context, i) {
                            final p = filteredList[i];
                            final isDone = _isFinalized(p.status);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                              ),
                              child: InkWell(
                                onTap: () => _showDetailModal(p),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Row: Avatar, Info, Status Badge
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: _buildGiftImage(p.fotoHadiah),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p.namaNasabah ?? 'Nasabah',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Hadiah: ${p.namaHadiah ?? '-'}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${Formatters.tanggalSingkat(p.tanggal)}  •  ${p.poinTerpakai} Poin',
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          StatusBadge(status: p.status),
                                        ],
                                      ),

                                      // Direct Action Row (if not finalized)
                                      if (!isDone) ...[
                                        const SizedBox(height: 12),
                                        const Divider(height: 1),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 36,
                                                child: OutlinedButton.icon(
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: AppColors.statusDitolak,
                                                    side: const BorderSide(color: AppColors.statusDitolak),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  icon: const Icon(Icons.close_rounded, size: 16),
                                                  label: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                  onPressed: () => _handleUpdateStatus(p.id, 'ditolak', 'Penukaran poin ditolak'),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: SizedBox(
                                                height: 36,
                                                child: ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.primary,
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  icon: const Icon(Icons.check_rounded, size: 16),
                                                  label: const Text('Setujui', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                  onPressed: () => _handleUpdateStatus(p.id, 'selesai', 'Penukaran poin berhasil disetujui!'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
