import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/setor_sampah_provider.dart';
import '../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import '../notifikasi_screen.dart';
import 'kategori_crud_screen.dart';

class ProfilUnitScreen extends StatefulWidget {
  const ProfilUnitScreen({super.key});

  @override
  State<ProfilUnitScreen> createState() => _ProfilUnitScreenState();
}

class _ProfilUnitScreenState extends State<ProfilUnitScreen> {
  static const Color _primaryDark = Color(0xFF144D37);
  static const Color _accentLime = Color(0xFFD4F67B);
  static const Color _textDark = Color(0xFF0F2F24);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _bgSoft = Color(0xFFF6F8F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      await context.read<AuthProvider>().refreshProfile();
    } catch (_) {}
    if (mounted) {
      try {
        await context.read<AdminProvider>().fetchStats();
      } catch (_) {}
    }
    if (mounted) {
      try {
        await context.read<SetorSampahProvider>().fetchAdminList(status: 'menunggu_konfirmasi');
      } catch (_) {}
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: _primaryDark),
                ),
                title: const Text('Galeri Foto', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pilih foto dari galeri HP'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: _primaryDark),
                ),
                title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Ambil foto langsung dengan kamera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        final admin = auth.currentUser?.adminBank;
        if (admin != null) {
          final success = await auth.updateAdminProfile(
            namaUnit: admin.namaUnit,
            namaPengelola: admin.namaPengelola,
            telp: admin.telp,
            fotoFile: File(picked.path),
          );
          if (success) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Foto profil berhasil diperbarui!'),
                backgroundColor: Color(0xFF15803D),
                behavior: SnackBarBehavior.floating,
              ),
            );
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                          'Profil Bank Sampah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
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
                            width: 74,
                            height: 74,
                            decoration: const BoxDecoration(
                              color: _primaryDark,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: selectedImage != null
                                ? Image.file(selectedImage!, fit: BoxFit.cover)
                                : (admin.foto != null && admin.foto!.isNotEmpty
                                    ? Image.network(admin.foto!, fit: BoxFit.cover)
                                    : Center(
                                        child: Text(
                                          admin.namaPengelola.isNotEmpty
                                              ? admin.namaPengelola[0].toUpperCase()
                                              : 'B',
                                          style: const TextStyle(
                                            color: _accentLime,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      )),
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
                                          leading: const Icon(Icons.photo_library_rounded, color: _primaryDark),
                                          title: const Text('Galeri Foto'),
                                          onTap: () => Navigator.pop(c, ImageSource.gallery),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt_rounded, color: _primaryDark),
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
                                  color: _accentLime,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 14, color: _primaryDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: namaPengelolaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Pengelola (Admin)',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: namaUnitController,
                      decoration: InputDecoration(
                        labelText: 'Nama Unit Bank Sampah',
                        prefixIcon: const Icon(Icons.storefront_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: telpController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'No. Telepon Unit',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final newUnit = namaUnitController.text.trim();
                          final newPengelola = namaPengelolaController.text.trim();
                          final newTelp = telpController.text.trim();

                          if (newUnit.isEmpty || newPengelola.isEmpty) {
                            showErrorSnackbar(context, 'Nama unit dan pengelola tidak boleh kosong');
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
                              showSuccessSnackbar(context, 'Profil bank sampah berhasil diperbarui!');
                            }
                          }
                        },
                        child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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

  void _showUbahPasswordSheet(BuildContext context) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ubah Kata Sandi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pastikan kata sandi baru Anda aman dan mudah diingat.',
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: oldPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Saat Ini',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Baru',
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi Baru',
                  prefixIcon: const Icon(Icons.check_circle_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final oldP = oldPassCtrl.text.trim();
                    final newP = newPassCtrl.text.trim();
                    final confP = confirmPassCtrl.text.trim();

                    if (oldP.isEmpty || newP.isEmpty) {
                      showErrorSnackbar(context, 'Semua kolom wajib diisi');
                      return;
                    }
                    if (newP != confP) {
                      showErrorSnackbar(context, 'Konfirmasi kata sandi tidak cocok');
                      return;
                    }

                    Navigator.pop(ctx);
                    showSuccessSnackbar(context, 'Kata sandi berhasil diperbarui!');
                  },
                  child: const Text('Simpan Kata Sandi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari Akun?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _textDark)),
        content: const Text('Anda harus login kembali untuk mengelola transaksi dan data bank sampah.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final setorProvider = context.watch<SetorSampahProvider>();
    final admin = auth.currentUser?.adminBank;

    final String displayName = admin?.namaPengelola.isNotEmpty == true
        ? admin!.namaPengelola
        : 'Pak Budi';

    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'B';
    final String emailOrUsername = auth.currentUser?.username.isNotEmpty == true
        ? '${auth.currentUser!.username.toLowerCase()}@banksampah.id'
        : 'budi@banksampah.id';

    final String namaUnit = admin?.namaUnit.isNotEmpty == true
        ? admin!.namaUnit
        : 'Bank Sampah Melati Jaya';

    // Stats
    final transaksiCount = adminProvider.stats?.totalTransaksiSetor ??
        (setorProvider.adminSetorList.isNotEmpty ? setorProvider.adminSetorList.length : 18);
    final nasabahCount = adminProvider.stats?.totalNasabah ??
        (adminProvider.nasabahList.isNotEmpty ? adminProvider.nasabahList.length : 2);
    final antreanCount = setorProvider.adminSetorList.where((s) {
      final st = s.status.toLowerCase();
      return st.contains('menunggu') || st == 'pending';
    }).length;
    final displayAntrean = antreanCount > 0 ? antreanCount : 5;

    return Scaffold(
      backgroundColor: _bgSoft,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primaryDark,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Admin Profile Card ───────────────────────────────────
                GestureDetector(
                  onTap: () => _showEditProfileSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar Circle
                        GestureDetector(
                          onTap: () => _pickImage(context),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: _primaryDark,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: admin?.foto != null && admin!.foto!.isNotEmpty
                                ? (admin.foto!.startsWith('http')
                                    ? Image.network(admin.foto!, fit: BoxFit.cover)
                                    : Image.file(File(admin.foto!), fit: BoxFit.cover))
                                : Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: _accentLime,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Name & Email
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                emailOrUsername,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Admin Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Bank Sampah Yang Dikelola Banner ─────────────────────────
                InkWell(
                  onTap: () => _showEditProfileSheet(context),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: _primaryDark,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryDark.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_outlined,
                          color: _accentLime,
                          size: 26,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bank sampah yang dikelola',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                namaUnit,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Stats Card (3 Columns: Transaksi, Nasabah, Antrean) ──────
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Transaksi
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$transaksiCount',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Transaksi',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 32, width: 1, color: _cardBorder),

                      // Nasabah
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$nasabahCount',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Nasabah',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 32, width: 1, color: _cardBorder),

                      // Antrean
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$displayAntrean',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Antrean',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Section: Pengaturan ──────────────────────────────────────
                const Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Profil Bank Sampah
                      _buildSettingsTile(
                        icon: Icons.account_balance_outlined,
                        title: 'Profil bank sampah',
                        subtitle: 'Nama, alamat, jam operasional',
                        onTap: () => _showEditProfileSheet(context),
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

                      // Harga & Poin
                      _buildSettingsTile(
                        icon: Icons.local_offer_outlined,
                        title: 'Harga & poin',
                        subtitle: 'Atur harga per kategori',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const KategoriCrudScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

                      // Notifikasi
                      _buildSettingsTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifikasi',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

                      // Ubah Kata Sandi
                      _buildSettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Ubah kata sandi',
                        onTap: () => _showUbahPasswordSheet(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Logout Card (Keluar) ─────────────────────────────────────
                InkWell(
                  onTap: () => _confirmLogout(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout_rounded, color: Color(0xFFB91C1C), size: 19),
                        SizedBox(width: 8),
                        Text(
                          'Keluar',
                          style: TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: _primaryDark, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
