import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/kategori_sampah_model.dart';
import '../../providers/kategori_sampah_provider.dart';
import '../widgets/common_widgets.dart';

class KategoriCrudScreen extends StatefulWidget {
  const KategoriCrudScreen({super.key});

  @override
  State<KategoriCrudScreen> createState() => _KategoriCrudScreenState();
}

class _KategoriCrudScreenState extends State<KategoriCrudScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KategoriSampahProvider>().fetchAll();
    });
  }

  void _showForm({KategoriSampahModel? existing}) {
    final namaCtrl = TextEditingController(text: existing?.namaKategori ?? '');
    final hargaCtrl = TextEditingController(text: existing?.hargaPerKg.toString() ?? '');
    final poinCtrl = TextEditingController(text: existing?.poinPerKg.toString() ?? '');
    String jenis = existing?.jenis.toLowerCase() ?? 'plastik';
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
                      existing == null ? 'Tambah Kategori Sampah ♻️' : 'Edit Kategori Sampah ♻️',
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

                // Photo Selector
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
                                  child: Image.network(existing.foto!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _buildDefaultIcon(jenis)),
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
                  'Nama Kategori',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: namaCtrl,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Botol Plastik PET',
                    prefixIcon: const Icon(Icons.recycling_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Jenis Sampah',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: jenis,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.category_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'plastik', child: Text('Plastik')),
                    DropdownMenuItem(value: 'kertas', child: Text('Kertas')),
                    DropdownMenuItem(value: 'logam', child: Text('Logam')),
                    DropdownMenuItem(value: 'kaca', child: Text('Kaca')),
                  ],
                  onChanged: (v) => setModalState(() => jenis = v ?? jenis),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Harga per Kg (Rp)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: hargaCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Contoh: 3000',
                              prefixIcon: const Icon(Icons.payments_rounded, color: Color(0xFF10B981)),
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
                            'Poin per Kg',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: poinCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Contoh: 10',
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
                      existing == null ? 'Simpan Kategori' : 'Update Kategori',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final nama = namaCtrl.text.trim();
                      final harga = num.tryParse(hargaCtrl.text.trim());
                      final poin = num.tryParse(poinCtrl.text.trim());

                      if (nama.isEmpty || harga == null || poin == null) {
                        showErrorSnackbar(context, 'Semua bidang wajib diisi dengan benar');
                        return;
                      }

                      Navigator.pop(ctx);
                      final provider = context.read<KategoriSampahProvider>();
                      bool ok;

                      if (existing == null) {
                        ok = await provider.create(
                          namaKategori: nama,
                          hargaPerKg: harga,
                          poinPerKg: poin,
                          jenis: jenis,
                          foto: selectedFoto,
                        );
                      } else {
                        ok = await provider.update(
                          id: existing.id,
                          namaKategori: nama,
                          hargaPerKg: harga,
                          poinPerKg: poin,
                          jenis: jenis,
                          foto: selectedFoto,
                        );
                      }

                      if (mounted) {
                        ok
                            ? showSuccessSnackbar(context, 'Kategori sampah berhasil disimpan')
                            : showErrorSnackbar(context, provider.errorMessage ?? 'Gagal menyimpan kategori');
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

  Future<void> _delete(KategoriSampahModel k) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus "${k.namaKategori}"?'),
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
    final provider = context.read<KategoriSampahProvider>();
    final ok = await provider.delete(k.id);
    if (mounted) {
      ok
          ? showSuccessSnackbar(context, 'Kategori sampah berhasil dihapus')
          : showErrorSnackbar(context, provider.errorMessage ?? 'Gagal menghapus kategori');
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
        return Icons.local_drink_rounded;
      case 'kertas':
        return Icons.description_rounded;
      case 'logam':
        return Icons.hardware_rounded;
      case 'kaca':
        return Icons.wine_bar_rounded;
      default:
        return Icons.recycling_rounded;
    }
  }

  Widget _buildDefaultIcon(String jenis) {
    final assetIcon = _jenisAssetIcon(jenis);
    final iconData = _jenisIcon(jenis);
    return Container(
      width: 48,
      height: 48,
      padding: assetIcon != null ? const EdgeInsets.all(9) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: assetIcon != null
          ? Image.asset(
              assetIcon,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(iconData, color: AppColors.primary, size: 24),
            )
          : Icon(iconData, color: AppColors.primary, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KategoriSampahProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      'Kelola Kategori Sampah ♻️',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Atur jenis, harga per kg, dan poin per kg',
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

          // ── List Kategori Sampah ──────────────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const LoadingView()
                : provider.kategoriList.isEmpty
                    ? const EmptyView(
                        message: 'Belum ada kategori sampah',
                        icon: Icons.recycling_rounded,
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => provider.fetchAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          itemCount: provider.kategoriList.length,
                          itemBuilder: (context, i) {
                            final k = provider.kategoriList[i];
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
                                        child: k.foto != null && k.foto!.isNotEmpty
                                            ? Image.network(
                                                k.foto!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) => _buildDefaultIcon(k.jenis),
                                              )
                                            : _buildDefaultIcon(k.jenis),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Content Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            k.namaKategori,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              // Price Tag
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFDCFCE7),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${Formatters.rupiah(k.hargaPerKg)}/kg',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF15803D),
                                                  ),
                                                ),
                                              ),

                                              // Point Tag
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEF3C7),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.stars_rounded, size: 13, color: Color(0xFFD97706)),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      '${k.poinPerKg} Poin/kg',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFFB45309),
                                                      ),
                                                    ),
                                                  ],
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
                                          onPressed: () => _showForm(existing: k),
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
                                          onPressed: () => _delete(k),
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
