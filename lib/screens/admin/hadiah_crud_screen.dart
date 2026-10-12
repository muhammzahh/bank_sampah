import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/hadiah_model.dart';
import '../../providers/hadiah_provider.dart';
import '../widgets/common_widgets.dart';
import 'konfirmasi_penukaran_screen.dart';

class HadiahCrudScreen extends StatefulWidget {
  const HadiahCrudScreen({super.key});

  @override
  State<HadiahCrudScreen> createState() => _HadiahCrudScreenState();
}

class _HadiahCrudScreenState extends State<HadiahCrudScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HadiahProvider>().fetchAll();
    });
  }

  void _showForm({HadiahModel? existing}) {
    final namaCtrl = TextEditingController(text: existing?.namaHadiah ?? '');
    final poinCtrl = TextEditingController(text: existing?.poinDibutuhkan.toString() ?? '');
    final stokCtrl = TextEditingController(text: existing?.stok.toString() ?? '');
    File? selectedFoto;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                    Text(
                      existing == null ? 'Tambah Hadiah Baru 🎁' : 'Edit Hadiah / Voucher 🎁',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Photo Selector for Gift
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final source = await showModalBottomSheet<ImageSource>(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (c) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                                title: const Text('Galeri Foto'),
                                onTap: () => Navigator.pop(c, ImageSource.gallery),
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                                title: const Text('Kamera'),
                                onTap: () => Navigator.pop(c, ImageSource.camera),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (source != null) {
                        final picked = await picker.pickImage(source: source, imageQuality: 85);
                        if (picked != null) {
                          setModalState(() {
                            selectedFoto = File(picked.path);
                          });
                        }
                      }
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: selectedFoto != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(selectedFoto!, fit: BoxFit.cover),
                            )
                          : existing?.foto != null && existing!.foto!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: _buildGiftImage(existing.foto!),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo_rounded, size: 28, color: AppColors.primary),
                                    SizedBox(height: 4),
                                    Text(
                                      'Foto',
                                      style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Nama Hadiah / Voucher',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: namaCtrl,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Voucher Pulsa Rp 25.000',
                    prefixIcon: const Icon(Icons.card_giftcard_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Poin Dibutuhkan',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: poinCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: false),
                            decoration: InputDecoration(
                              hintText: 'Contoh: 100',
                              prefixIcon: const Icon(Icons.stars_rounded, color: Colors.amber),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stok Hadiah',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: stokCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: false),
                            decoration: InputDecoration(
                              hintText: 'Contoh: 10',
                              prefixIcon: const Icon(Icons.inventory_2_rounded, color: Color(0xFF0EA5E9)),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: Text(
                      existing == null ? 'Simpan Hadiah' : 'Update Hadiah',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final nama = namaCtrl.text.trim();
                      final poin = num.tryParse(poinCtrl.text.trim());
                      final stok = num.tryParse(stokCtrl.text.trim());

                      if (nama.isEmpty || poin == null || stok == null) {
                        showErrorSnackbar(context, 'Semua bidang wajib diisi dengan benar');
                        return;
                      }

                      Navigator.pop(ctx);
                      final provider = context.read<HadiahProvider>();
                      bool ok;

                      if (existing == null) {
                        ok = await provider.create(
                          namaHadiah: nama,
                          poinDibutuhkan: poin,
                          stok: stok,
                          foto: selectedFoto,
                        );
                      } else {
                        ok = await provider.update(
                          id: existing.id,
                          namaHadiah: nama,
                          poinDibutuhkan: poin,
                          stok: stok,
                          foto: selectedFoto,
                        );
                      }

                      if (mounted) {
                        ok
                            ? showSuccessSnackbar(context, 'Hadiah berhasil disimpan')
                            : showErrorSnackbar(context, provider.errorMessage ?? 'Gagal menyimpan hadiah');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(HadiahModel h) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Hadiah', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus "${h.namaHadiah}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDitolak,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    final provider = context.read<HadiahProvider>();
    final ok = await provider.delete(h.id);
    if (mounted) {
      ok
          ? showSuccessSnackbar(context, 'Hadiah berhasil dihapus')
          : showErrorSnackbar(context, provider.errorMessage ?? 'Gagal menghapus hadiah');
    }
  }

  Widget _buildGiftImage(String? foto) {
    if (foto != null && foto.isNotEmpty) {
      final file = File(foto);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      } else if (foto.startsWith('http://') || foto.startsWith('https://')) {
        return Image.network(
          foto,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildPlaceholder(),
        );
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.card_giftcard_rounded, color: AppColors.primary, size: 26),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HadiahProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Hadiah', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showForm(),
      ),
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
                      'Kelola Hadiah / Voucher 🎁',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Atur katalog voucher dan stok hadiah nasabah',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const KonfirmasiPenukaranScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Konfirmasi Penukaran Poin',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── List Hadiah ──────────────────────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const LoadingView()
                : provider.hadiahList.isEmpty
                    ? const EmptyView(message: 'Belum ada hadiah / voucher')
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => provider.fetchAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          itemCount: provider.hadiahList.length,
                          itemBuilder: (context, i) {
                            final h = provider.hadiahList[i];
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
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Image / Avatar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: SizedBox(
                                        width: 52,
                                        height: 52,
                                        child: _buildGiftImage(h.foto),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Content Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            h.namaHadiah,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              // Points Badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEF3C7),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.stars_rounded, size: 14, color: Color(0xFFD97706)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${h.poinDibutuhkan} Poin',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFFB45309),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 6),

                                              // Stock Badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: h.stok > 0 ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  h.stok > 0 ? 'Stok: ${h.stok}' : 'Habis',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: h.stok > 0 ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Action Buttons
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          style: IconButton.styleFrom(
                                            backgroundColor: const Color(0xFFF0FDF4),
                                            padding: const EdgeInsets.all(8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 18),
                                          onPressed: () => _showForm(existing: h),
                                        ),
                                        const SizedBox(width: 6),
                                        IconButton(
                                          style: IconButton.styleFrom(
                                            backgroundColor: const Color(0xFFFEE2E2),
                                            padding: const EdgeInsets.all(8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusDitolak, size: 18),
                                          onPressed: () => _delete(h),
                                        ),
                                      ],
                                    ),
                                  ],
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
