import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import 'widgets/common_widgets.dart';
import 'nasabah/nota_setor_screen.dart';
import 'nasabah/nota_penukaran_screen.dart';
import 'admin/konfirmasi_setor_screen.dart';
import 'admin/konfirmasi_penukaran_screen.dart';

/// Standalone Full-Page Screen untuk membaca detail notifikasi / pesan masuk.
class DetailNotifikasiScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailNotifikasiScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final color = item['color'] as Color? ?? AppColors.primary;
    final icon = item['icon'] as IconData? ?? Icons.notifications_rounded;
    final title = item['title'] as String? ?? 'Pemberitahuan';
    final message = item['message'] as String? ?? '';
    final status = item['status'] as String? ?? 'Selesai';
    final date = item['date'] as String? ?? '';
    final kode = item['kode'] as String?;
    final subDetail = item['sub_detail'] as String?;
    final rawId = item['raw_id'] as String?;
    final type = item['type'] as String?;

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
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Detail Notifikasi 📩',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pesan pemberitahuan status transaksi sampah Anda',
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

          // ── Main Body Content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: color.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: 6),
                              StatusBadge(status: status),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Detail Body Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('Tanggal Pemberitahuan', Formatters.tanggalIndo(date)),
                        if (kode != null && kode.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _infoRow('Kode Transaksi', kode),
                        ],
                        if (subDetail != null && subDetail.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _infoRow('Informasi Rincian', subDetail),
                        ],
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        const Text(
                          'Pesan Lengkap:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Action Buttons ──────────────────────────────────────
                  Row(
                    children: [
                      if (rawId != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (type == 'setor') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NotaSetorScreen(setorId: rawId),
                                  ),
                                );
                              } else if (type == 'penukaran') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NotaPenukaranScreen(penukaranId: rawId),
                                  ),
                                );
                              } else if (type == 'admin_setor') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const KonfirmasiSetorScreen(),
                                  ),
                                );
                              } else if (type == 'admin_penukaran') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const KonfirmasiPenukaranScreen(),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.receipt_long_rounded, size: 18),
                            label: const Text('Buka Detail'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(true); // Return true to mark as read & remove
                          },
                          icon: const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                          label: const Text(
                            'Selesai Dibaca',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
