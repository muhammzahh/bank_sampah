import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/hadiah_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hadiah_provider.dart';
import '../../providers/penukaran_poin_provider.dart';
import 'nota_penukaran_screen.dart';
import '../widgets/common_widgets.dart';

class HadiahScreen extends StatefulWidget {
  const HadiahScreen({super.key});

  @override
  State<HadiahScreen> createState() => _HadiahScreenState();
}

class _HadiahScreenState extends State<HadiahScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HadiahProvider>().fetchAll();
    });
  }

  Future<void> _konfirmasiTukar(HadiahModel hadiah) async {
    final auth = context.read<AuthProvider>();
    final saldoPoin = auth.currentUser?.nasabah?.saldoPoin ?? 0;

    if (saldoPoin < hadiah.poinDibutuhkan) {
      showErrorSnackbar(context, 'Saldo poin tidak mencukupi untuk hadiah ini');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.redeem_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Konfirmasi Penukaran'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tukar poin dengan:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hadiah.namaHadiah,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${hadiah.poinDibutuhkan} Poin',
                          style: const TextStyle(color: AppColors.primary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tukar Sekarang', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final penukaranProvider = context.read<PenukaranPoinProvider>();
    final res = await penukaranProvider.tukar(hadiah.id);
    if (!mounted) return;
    if (res != null) {
      showSuccessSnackbar(context, 'Penukaran "${hadiah.namaHadiah}" berhasil diajukan! Menunggu verifikasi admin 🎁');
      await auth.refreshProfile();
      await penukaranProvider.fetchMyPenukaran();
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NotaPenukaranScreen(penukaranId: res.id),
          ),
        );
      }
    } else {
      showErrorSnackbar(context, penukaranProvider.errorMessage ?? 'Gagal menukar poin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hadiahProvider = context.watch<HadiahProvider>();
    final auth = context.watch<AuthProvider>();
    final saldoPoin = auth.currentUser?.nasabah?.saldoPoin ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
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
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                      const Text(
                        'Tukar Poin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Saldo Poin: $saldoPoin Poin',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),


          // ── Content ──────────────────────────────────────────────────────
          if (hadiahProvider.isLoading)
            const SliverToBoxAdapter(child: LoadingView())
          else if (hadiahProvider.hadiahList.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyView(
                message: 'Belum ada hadiah tersedia',
                icon: Icons.card_giftcard_rounded,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final h = hadiahProvider.hadiahList[index];
                    final canRedeem = saldoPoin >= h.poinDibutuhkan && h.stok > 0;
                    return _HadiahCard(
                      hadiah: h,
                      canRedeem: canRedeem,
                      onTukar: () => _konfirmasiTukar(h),
                    );
                  },
                  childCount: hadiahProvider.hadiahList.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HadiahCard extends StatelessWidget {
  final HadiahModel hadiah;
  final bool canRedeem;
  final VoidCallback onTukar;

  const _HadiahCard({
    required this.hadiah,
    required this.canRedeem,
    required this.onTukar,
  });

  Widget _buildGiftCardImage(String? foto, bool canRedeem) {
    if (foto != null && foto.isNotEmpty) {
      if (foto.startsWith('http://') || foto.startsWith('https://')) {
        return Image.network(
          foto,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildPlaceholderIcon(canRedeem),
        );
      }
    }
    return _buildPlaceholderIcon(canRedeem);
  }

  Widget _buildPlaceholderIcon(bool canRedeem) {
    return Container(
      color: canRedeem ? AppColors.primarySurface : const Color(0xFFF8FAFC),
      child: Center(
        child: Icon(
          Icons.card_giftcard_rounded,
          size: 44,
          color: canRedeem ? AppColors.primary : AppColors.textLight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Icon area
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 96,
              child: _buildGiftCardImage(hadiah.foto, canRedeem),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hadiah.namaHadiah,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 13, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Text(
                      '${hadiah.poinDibutuhkan} Poin',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Stok: ${hadiah.stok}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canRedeem ? AppColors.primary : AppColors.textLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: hadiah.stok > 0 ? onTukar : null,
                    child: Text(
                      hadiah.stok <= 0 ? 'Habis' : 'Tukar',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
