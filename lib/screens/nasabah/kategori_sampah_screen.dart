import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/setor_sampah_model.dart';
import '../../providers/kategori_sampah_provider.dart';
import '../../providers/setor_sampah_provider.dart';
import '../widgets/common_widgets.dart';
import 'ajukan_setor_screen.dart';
import 'nota_setor_screen.dart';

class KategoriSampahScreen extends StatefulWidget {
  const KategoriSampahScreen({super.key});

  @override
  State<KategoriSampahScreen> createState() => _KategoriSampahScreenState();
}

class _KategoriSampahScreenState extends State<KategoriSampahScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KategoriSampahProvider>().fetchAll();
      context.read<SetorSampahProvider>().fetchMySetor();
    });
  }

  IconData _jenisIcon(String jenis, [String nama = '']) {
    final s = '$jenis $nama'.toLowerCase();
    if (s.contains('plastik')) return Icons.local_drink_rounded;
    if (s.contains('kertas'))  return Icons.description_rounded;
    if (s.contains('logam'))   return Icons.hardware_rounded;
    if (s.contains('kaca'))    return Icons.wine_bar_rounded;
    if (s.contains('organik')) return Icons.eco_rounded;
    return Icons.recycling_rounded;
  }

  String? _jenisAssetIcon(String jenis, [String nama = '']) {
    final s = '$jenis $nama'.toLowerCase();
    if (s.contains('plastik')) return 'assets/icons/plastik.png';
    if (s.contains('kertas'))  return 'assets/icons/kertas.png';
    if (s.contains('logam'))   return 'assets/icons/logam.png';
    if (s.contains('kaca'))    return 'assets/icons/kaca.webp';
    return null;
  }

  Color _jenisColor(String jenis, [String nama = '']) {
    final s = '$jenis $nama'.toLowerCase();
    if (s.contains('plastik')) return const Color(0xFF3B82F6);
    if (s.contains('kertas'))  return const Color(0xFFF59E0B);
    if (s.contains('logam'))   return const Color(0xFF6B7280);
    if (s.contains('kaca'))    return const Color(0xFF06B6D4);
    if (s.contains('organik')) return const Color(0xFF10B981);
    return AppColors.primary;
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color text;
    String label;
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'diverifikasi':
      case 'disetujui':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF166534);
        label = 'Disetujui';
        break;
      case 'ditolak':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFF991B1B);
        label = 'Ditolak';
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFF92400E);
        label = 'Menunggu';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text)),
    );
  }

  String _getNamaSampahDisplay(SetorSampahModel item) {
    if (item.detailSetors.isNotEmpty) {
      final names = item.detailSetors
          .map((d) => d.namaKategori ?? d.jenis ?? '')
          .where((name) => name.isNotEmpty)
          .toSet()
          .join(', ');
      if (names.isNotEmpty) return names;
    }
    return item.kodeSetor ?? 'Setoran Sampah';
  }

  @override
  Widget build(BuildContext context) {
    final katProvider = context.watch<KategoriSampahProvider>();
    final setorProvider = context.watch<SetorSampahProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final setorProv = context.read<SetorSampahProvider>();
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AjukanSetorScreen()),
          );
          setorProv.fetchMySetor();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajukan Setor', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: (katProvider.isLoading && katProvider.kategoriList.isEmpty)
          ? const LoadingView()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await katProvider.fetchAll();
                await setorProvider.fetchMySetor();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── Top Dark Green Header ────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF163223), // Dark green background from design
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
                              Row(
                                children: [
                                  const Text(
                                    'Setor Sampah',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.recycling_rounded, color: Color(0xFF10B981), size: 24),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pilih kategori dan ajukan penimbangan sampah',
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
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const Text(
                          'Pilih Kategori Sampah',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                    // ── Grid Kategori ──────────────────────────────────
                    if (katProvider.kategoriList.isEmpty)
                      const EmptyView(
                        message: 'Belum ada kategori sampah',
                        icon: Icons.recycling_rounded,
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.35,
                        ),
                        itemCount: katProvider.kategoriList.length,
                        itemBuilder: (context, index) {
                          final k = katProvider.kategoriList[index];
                          final color = _jenisColor(k.jenis, k.namaKategori);
                          final assetIcon = _jenisAssetIcon(k.jenis, k.namaKategori);

                          return GestureDetector(
                            onTap: () async {
                              final setorProv = context.read<SetorSampahProvider>();
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AjukanSetorScreen(initialKategori: k),
                                ),
                              );
                              setorProv.fetchMySetor();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        padding: assetIcon != null ? const EdgeInsets.all(7) : EdgeInsets.zero,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: assetIcon != null
                                            ? Image.asset(
                                                assetIcon,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) => Icon(_jenisIcon(k.jenis, k.namaKategori), color: color, size: 18),
                                              )
                                            : Icon(_jenisIcon(k.jenis, k.namaKategori), color: color, size: 18),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.textGrey.withValues(alpha: 0.5),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    k.namaKategori,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 3,
                                    children: [
                                      _InfoBadge(
                                        label: '${Formatters.rupiah(k.hargaPerKg)}/kg',
                                        color: const Color(0xFF10B981),
                                      ),
                                      _InfoBadge(
                                        label: '${k.poinPerKg} Poin/kg',
                                        color: const Color(0xFFF59E0B),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 24),

                    // ── Header Section 2: Pengajuan Penyetoran Saya ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pengajuan Penyetoran Saya',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (setorProvider.mySetorList.isNotEmpty)
                          Text(
                            '${setorProvider.mySetorList.length} Pengajuan',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Daftar Pengajuan Setor ─────────────────────────
                    if (setorProvider.mySetorList.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.assignment_outlined, size: 36, color: AppColors.textGrey),
                            SizedBox(height: 8),
                            Text(
                              'Belum ada pengajuan penyetoran',
                              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tekan "+ Ajukan Setor" untuk membuat pengajuan baru',
                              style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: setorProvider.mySetorList.length,
                        itemBuilder: (context, index) {
                          final item = setorProvider.mySetorList[index];
                          final poin = item.totalPoin ?? item.estimasiTotalPoin ?? 0;
                          final dateStr = item.tanggal.length >= 10
                              ? item.tanggal.substring(0, 10)
                              : item.tanggal;
                          final titleText = _getNamaSampahDisplay(item);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NotaSetorScreen(setorId: item.id),
                                  ),
                                );
                              },
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.recycling_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      titleText,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  _buildStatusChip(item.status),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$dateStr  •  ${item.totalBeratKg} Kg',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                    ),
                                    Text(
                                      '+$poin Poin',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
