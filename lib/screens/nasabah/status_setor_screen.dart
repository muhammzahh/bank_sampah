import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/setor_sampah_provider.dart';
import '../widgets/common_widgets.dart';
import 'nota_setor_screen.dart';

class StatusSetorScreen extends StatefulWidget {
  const StatusSetorScreen({super.key});

  @override
  State<StatusSetorScreen> createState() => _StatusSetorScreenState();
}

class _StatusSetorScreenState extends State<StatusSetorScreen> {
  String _filterStatus = 'semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SetorSampahProvider>().fetchMySetor();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SetorSampahProvider>();
    final filtered = _filterStatus == 'semua'
        ? provider.mySetorList
        : provider.mySetorList.where((s) => s.status == _filterStatus).toList();

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
                      'Riwayat Penyetoran',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pantau status dan riwayat transaksi sampah Anda',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Filter Horizontal Chips
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _filterChip('semua', 'Semua'),
                          _filterChip('menunggu_konfirmasi', 'Menunggu'),
                          _filterChip('diverifikasi', 'Diverifikasi'),
                          _filterChip('selesai', 'Selesai'),
                          _filterChip('ditolak', 'Ditolak'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: provider.isLoading
                ? const LoadingView()
                : filtered.isEmpty
                    ? const EmptyView(
                        message: 'Belum ada riwayat penyetoran',
                        icon: Icons.recycling_rounded,
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => provider.fetchMySetor(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            return _SetorCard(
                              setor: s,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => NotaSetorScreen(setorId: s.id),
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
}

class _SetorCard extends StatelessWidget {
  final dynamic setor;
  final VoidCallback onTap;

  const _SetorCard({required this.setor, required this.onTap});

  String _getNamaSampahDisplay(dynamic setor) {
    if (setor.detailSetors != null && setor.detailSetors.isNotEmpty) {
      final names = setor.detailSetors
          .map((d) => d.namaKategori ?? d.jenis ?? '')
          .where((name) => name.toString().isNotEmpty)
          .toSet()
          .join(', ');
      if (names.isNotEmpty) return names;
    }
    return setor.kodeSetor ?? 'Setoran Sampah';
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _getNamaSampahDisplay(setor);
    final kodeText = setor.kodeSetor != null ? '${setor.kodeSetor}  •  ' : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.recycling_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$kodeText${Formatters.tanggalSingkat(setor.tanggal)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _InfoChip(
                        label: '${setor.totalBeratKg} Kg',
                        icon: Icons.scale_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      _InfoChip(
                        label: '${setor.totalPoin ?? setor.estimasiTotalPoin ?? 0} Poin',
                        icon: Icons.stars_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(status: setor.status),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _InfoChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
