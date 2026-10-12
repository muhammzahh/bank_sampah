import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/setor_sampah_model.dart';
import '../../providers/setor_sampah_provider.dart';
import '../widgets/common_widgets.dart';

class KonfirmasiSetorScreen extends StatefulWidget {
  const KonfirmasiSetorScreen({super.key});

  @override
  State<KonfirmasiSetorScreen> createState() => _KonfirmasiSetorScreenState();
}

class _KonfirmasiSetorScreenState extends State<KonfirmasiSetorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SetorSampahProvider>().fetchAdminList(status: 'menunggu_konfirmasi');
    });
  }

  void _showDetail(SetorSampahModel setor) {
    final catatanCtrl = TextEditingController();

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          setor.namaNasabah ?? 'Detail Setoran',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          setor.kodeSetor ?? 'Kode Setor',
                          style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: setor.status),
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
                    _infoRow(Icons.person_rounded, 'Nasabah', setor.namaNasabah ?? '-'),
                    _infoRow(Icons.calendar_today_rounded, 'Tanggal', Formatters.tanggalIndo(setor.tanggal)),
                    _infoRow(Icons.scale_rounded, 'Total Berat', '${setor.totalBeratKg} Kg'),
                    _infoRow(Icons.stars_rounded, 'Estimasi Poin', '${setor.estimasiTotalPoin ?? setor.totalPoin ?? 0} Poin'),
                    if (setor.catatan != null && setor.catatan!.isNotEmpty)
                      _infoRow(Icons.note_rounded, 'Catatan Nasabah', setor.catatan!),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Rincian Sampah Disetor:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),

              ...setor.detailSetors.map((d) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.recycling_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              d.namaKategori ?? 'Kategori',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
                            ),
                          ],
                        ),
                        Text(
                          '${d.beratKg} Kg',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),

              TextField(
                controller: catatanCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Catatan Admin (opsional)',
                  hintText: 'Tambahkan catatan verifikasi...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

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
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final ok = await context.read<SetorSampahProvider>().verify(
                              id: setor.id,
                              status: 'ditolak',
                              catatanAdmin: catatanCtrl.text.trim(),
                              currentFilterStatus: _filterStatus,
                            );
                        if (mounted) {
                          ok
                              ? showSuccessSnackbar(context, 'Setoran telah ditolak')
                              : showErrorSnackbar(context, 'Gagal memproses setoran');
                        }
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
                      label: const Text('Verifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final ok = await context.read<SetorSampahProvider>().verify(
                              id: setor.id,
                              status: 'selesai',
                              catatanAdmin: catatanCtrl.text.trim(),
                              currentFilterStatus: _filterStatus,
                            );
                        if (mounted) {
                          ok
                              ? showSuccessSnackbar(context, 'Setoran berhasil diverifikasi!')
                              : showErrorSnackbar(context, 'Gagal memproses setoran');
                        }
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
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  final String _filterStatus = 'menunggu_konfirmasi';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SetorSampahProvider>();

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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                      'Konfirmasi Setoran 📋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verifikasi dan setujui penimbangan sampah dari nasabah',
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

          // ── List Setoran Menunggu Konfirmasi ─────────────────────────
          Expanded(
            child: provider.isLoading
                ? const LoadingView()
                : provider.adminSetorList.isEmpty
                    ? const EmptyView(
                        message: 'Tidak ada setoran yang membutuhkan konfirmasi',
                        icon: Icons.fact_check_outlined,
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => provider.fetchAdminList(status: _filterStatus),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.adminSetorList.length,
                          itemBuilder: (context, i) {
                            final s = provider.adminSetorList[i];
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
                              child: ListTile(
                                onTap: () => _showDetail(s),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.pending_actions_rounded, color: AppColors.primary, size: 24),
                                ),
                                title: Text(
                                  s.namaNasabah ?? 'Nasabah',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${Formatters.tanggalSingkat(s.tanggal)}  •  ${s.totalBeratKg} Kg',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                    ),
                                    const SizedBox(height: 6),
                                    StatusBadge(status: s.status),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
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
