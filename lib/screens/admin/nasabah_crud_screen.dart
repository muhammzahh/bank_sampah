import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/nasabah_model.dart';
import '../../providers/admin_provider.dart';
import '../widgets/common_widgets.dart';

class NasabahCrudScreen extends StatefulWidget {
  const NasabahCrudScreen({super.key});

  @override
  State<NasabahCrudScreen> createState() => _NasabahCrudScreenState();
}

class _NasabahCrudScreenState extends State<NasabahCrudScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchNasabahList();
    });
  }

  void _showForm({NasabahModel? existing}) {
    final usernameCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final namaCtrl = TextEditingController(text: existing?.namaNasabah ?? '');
    final alamatCtrl = TextEditingController(text: existing?.alamat ?? '');
    final telpCtrl = TextEditingController(text: existing?.telp ?? '');
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
                      existing == null ? 'Tambah Nasabah Baru 👥' : 'Edit Data Nasabah 👥',
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
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: selectedFoto != null
                          ? ClipOval(child: Image.file(selectedFoto!, fit: BoxFit.cover))
                          : existing?.foto != null && existing!.foto!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    existing.foto!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_rounded, size: 26, color: AppColors.primary),
                                    SizedBox(height: 2),
                                    Text(
                                      'Foto',
                                      style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (existing == null) ...[
                  const Text(
                    'Username Login',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Contoh: nasabah01',
                      prefixIcon: const Icon(Icons.account_circle_rounded, color: AppColors.primary),
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
                    'Password',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Masukkan password',
                      prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.primary),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                const Text(
                  'Nama Lengkap Nasabah',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: namaCtrl,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Ahmad Subagyo',
                    prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
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
                  'Alamat Tempat Tinggal',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: alamatCtrl,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Jl. Merdeka No. 45 Malang',
                    prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary),
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
                  'No. Telepon / WhatsApp',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: telpCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 081234567890',
                    prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
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
                      existing == null ? 'Simpan Data Nasabah' : 'Update Data Nasabah',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final nama = namaCtrl.text.trim();
                      final alamat = alamatCtrl.text.trim();
                      final telp = telpCtrl.text.trim();

                      if (existing == null) {
                        final username = usernameCtrl.text.trim();
                        final password = passCtrl.text;
                        if (username.isEmpty || password.isEmpty || nama.isEmpty || alamat.isEmpty || telp.isEmpty) {
                          showErrorSnackbar(context, 'Semua bidang wajib diisi dengan benar');
                          return;
                        }
                        Navigator.pop(ctx);
                        final provider = context.read<AdminProvider>();
                        final ok = await provider.createNasabah(
                          username: username,
                          password: password,
                          namaNasabah: nama,
                          alamat: alamat,
                          telp: telp,
                          foto: selectedFoto,
                        );
                        if (mounted) {
                          ok
                              ? showSuccessSnackbar(context, 'Nasabah baru berhasil ditambahkan')
                              : showErrorSnackbar(context, provider.errorMessage ?? 'Gagal menambahkan nasabah');
                        }
                      } else {
                        if (nama.isEmpty || alamat.isEmpty || telp.isEmpty) {
                          showErrorSnackbar(context, 'Semua bidang wajib diisi dengan benar');
                          return;
                        }
                        Navigator.pop(ctx);
                        final provider = context.read<AdminProvider>();
                        final ok = await provider.updateNasabah(
                          id: existing.id,
                          namaNasabah: nama,
                          alamat: alamat,
                          telp: telp,
                          foto: selectedFoto,
                        );
                        if (mounted) {
                          ok
                              ? showSuccessSnackbar(context, 'Data nasabah berhasil diperbarui')
                              : showErrorSnackbar(context, provider.errorMessage ?? 'Gagal mengedit nasabah');
                        }
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

  Future<void> _delete(NasabahModel n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Nasabah', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus nasabah "${n.namaNasabah}"?'),
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
    final provider = context.read<AdminProvider>();
    final ok = await provider.deleteNasabah(n.id);
    if (mounted) {
      ok
          ? showSuccessSnackbar(context, 'Nasabah berhasil dihapus')
          : showErrorSnackbar(context, provider.errorMessage ?? 'Gagal menghapus nasabah');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Nasabah', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      'Kelola Data Nasabah 👥',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Daftar nasabah terdaftar di unit bank sampah',
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

          // ── List Nasabah ─────────────────────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const LoadingView()
                : provider.nasabahList.isEmpty
                    ? const EmptyView(
                        message: 'Belum ada nasabah terdaftar',
                        icon: Icons.people_outline_rounded,
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => provider.fetchNasabahList(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          itemCount: provider.nasabahList.length,
                          itemBuilder: (context, i) {
                            final n = provider.nasabahList[i];
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
                                    // Avatar
                                    ClipOval(
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: n.foto != null && n.foto!.isNotEmpty
                                            ? Image.network(
                                                n.foto!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) => Container(
                                                  color: AppColors.primarySurface,
                                                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                                                ),
                                              )
                                            : Container(
                                                color: AppColors.primarySurface,
                                                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Content Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n.namaNasabah,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            n.alamat,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              // Phone Tag
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.phone_rounded, size: 12, color: AppColors.textGrey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      n.telp,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.textDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

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
                                                    const Icon(Icons.stars_rounded, size: 13, color: Color(0xFFD97706)),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      '${n.saldoPoin} Poin',
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
                                          onPressed: () => _showForm(existing: n),
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
                                          onPressed: () => _delete(n),
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
