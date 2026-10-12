import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';
import '../auth/login_screen.dart';

/// Menampilkan & mengedit profil unit Bank Sampah yang sedang login.
class ProfilUnitScreen extends StatefulWidget {
  const ProfilUnitScreen({super.key});

  @override
  State<ProfilUnitScreen> createState() => _ProfilUnitScreenState();
}

class _ProfilUnitScreenState extends State<ProfilUnitScreen> {
  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Sumber Foto Profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.photo_library_rounded, color: Color(0xFF166534)),
                ),
                title: const Text('Galeri Foto'),
                subtitle: const Text('Pilih foto dari galeri HP'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.camera_alt_rounded, color: Color(0xFF166534)),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Ambil foto langsung dengan kamera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null && mounted) {
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null && mounted) {
        final auth = context.read<AuthProvider>();
        final admin = auth.currentUser?.adminBank;
        if (admin != null) {
          final success = await auth.updateAdminProfile(
            namaUnit: admin.namaUnit,
            namaPengelola: admin.namaPengelola,
            telp: admin.telp,
            fotoFile: File(picked.path),
          );
          if (success && mounted) {
            showSuccessSnackbar(context, 'Foto profil berhasil diperbarui!');
          }
        }
      }
    }
  }

  void _showEditProfileSheet(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final admin = auth.currentUser?.adminBank;
    if (admin == null) return;

    final namaUnitController = TextEditingController(text: admin.namaUnit);
    final namaPengelolaController = TextEditingController(text: admin.namaPengelola);
    final telpController = TextEditingController(text: admin.telp);
    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                        const Text(
                          'Edit Profil Unit Bank Sampah',
                          style: TextStyle(
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

                    // Avatar Edit Preview inside Sheet
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                            ),
                            child: ClipOval(
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: selectedImage != null
                                    ? Image.file(selectedImage!, fit: BoxFit.cover)
                                    : _buildAvatarImage(admin.foto, size: 80),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
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
                                    setSheetState(() {
                                      selectedImage = File(picked.path);
                                    });
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Nama Unit Bank Sampah',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: namaUnitController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama unit',
                        prefixIcon: const Icon(Icons.storefront_rounded, color: AppColors.primary),
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
                      'Nama Pengelola',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: namaPengelolaController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama pengelola',
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
                      'No. Telepon Unit',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: telpController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Masukkan no telepon unit',
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
                        label: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final newUnit = namaUnitController.text.trim();
                          final newPengelola = namaPengelolaController.text.trim();
                          final newTelp = telpController.text.trim();

                          if (newUnit.isEmpty || newPengelola.isEmpty || newTelp.isEmpty) {
                            showErrorSnackbar(context, 'Semua bidang harus diisi!');
                            return;
                          }

                          final success = await auth.updateAdminProfile(
                            namaUnit: newUnit,
                            namaPengelola: newPengelola,
                            telp: newTelp,
                            fotoFile: selectedImage,
                          );

                          if (mounted && ctx.mounted) {
                            Navigator.pop(ctx);
                            if (success) {
                              showSuccessSnackbar(context, 'Profil Unit berhasil diperbarui!');
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarImage(String? foto, {double size = 88}) {
    if (foto != null && foto.isNotEmpty) {
      final file = File(foto);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover, width: size, height: size);
      } else if (foto.startsWith('http')) {
        return Image.network(foto, fit: BoxFit.cover, width: size, height: size);
      }
    }
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      child: Icon(Icons.storefront_rounded, size: size * 0.55, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = auth.currentUser?.adminBank;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: admin == null
          ? const EmptyView(message: 'Data profil tidak ditemukan')
          : CustomScrollView(
              slivers: [
                // ── Header ─────────────────────────────────────────────
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
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        child: Column(
                          children: [
                            const Text(
                              'Profil Unit Bank Sampah',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Avatar with Interactive Camera Badge
                            GestureDetector(
                              onTap: () => _pickImage(context),
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: 88,
                                        height: 88,
                                        child: _buildAvatarImage(admin.foto),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              admin.namaUnit,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Pengelola: ${admin.namaPengelola}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Detail Info & Action Buttons ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoTile(
                          icon: Icons.storefront_rounded,
                          label: 'Nama Unit',
                          value: admin.namaUnit,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 10),
                        _InfoTile(
                          icon: Icons.person_rounded,
                          label: 'Nama Pengelola',
                          value: admin.namaPengelola,
                          color: const Color(0xFF3B82F6),
                        ),
                        const SizedBox(height: 10),
                        _InfoTile(
                          icon: Icons.phone_rounded,
                          label: 'No. Telepon Unit',
                          value: admin.telp,
                          color: const Color(0xFF0EA5E9),
                        ),
                        const SizedBox(height: 20),

                        // Edit Profil Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text(
                              'Edit Profil Unit',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            onPressed: () => _showEditProfileSheet(context),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusDitolak,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text(
                              'Keluar dari Akun',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            onPressed: () async {
                              await context.read<AuthProvider>().logout();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
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
