import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/rekapitulasi_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/setor_sampah_provider.dart';
import '../../services/dashboard_service.dart';

import '../auth/login_screen.dart';
import '../notifikasi_screen.dart';
import '../widgets/common_widgets.dart';
import 'lokasi_bank_sampah_screen.dart';

class ProfilNasabahScreen extends StatefulWidget {
  const ProfilNasabahScreen({super.key});

  @override
  State<ProfilNasabahScreen> createState() => _ProfilNasabahScreenState();
}

class _ProfilNasabahScreenState extends State<ProfilNasabahScreen> {
  final picker = ImagePicker();
  DashboardSummaryModel? _summary;
  bool _loading = false;

  static const Color _primaryDark = Color(0xFF144D37);
  static const Color _accentLime = Color(0xFFD4F67B);
  static const Color _badgeLime = Color(0xFFE4F7AB);
  static const Color _textDark = Color(0xFF0F2F24);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _bgSoft = Color(0xFFF6F8F5);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final summary = await DashboardService.getNasabahSummary();
      if (mounted) {
        setState(() => _summary = summary);
      }
    } catch (_) {}

    if (mounted) {
      try {
        final setor = context.read<SetorSampahProvider>();
        await setor.fetchMySetor();
      } catch (_) {}
    }

    if (mounted) {
      try {
        final auth = context.read<AuthProvider>();
        await auth.refreshProfile();
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                'Ganti Foto Profil',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: _primaryDark),
                ),
                title: const Text('Ambil dari Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: _primaryDark),
                ),
                title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null && mounted) {
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        if (!mounted) return;
        final auth = context.read<AuthProvider>();
        final nasabah = auth.currentUser?.nasabah;
        if (nasabah != null) {
          final success = await auth.updateNasabahProfile(
            namaNasabah: nasabah.namaNasabah,
            alamat: nasabah.alamat,
            telp: nasabah.telp,
            fotoFile: File(picked.path),
          );
          if (success && mounted) {
            showSuccessSnackbar(context, 'Foto profil berhasil diperbarui!');
          }
        }
      }
    }
  }

  void _showEditProfileSheet(BuildContext context, {bool focusAddress = false}) {
    final auth = context.read<AuthProvider>();
    final nasabah = auth.currentUser?.nasabah;
    if (nasabah == null) return;

    final namaController = TextEditingController(text: nasabah.namaNasabah);
    final alamatController = TextEditingController(text: nasabah.alamat);
    final telpController = TextEditingController(text: nasabah.telp);
    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
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
                  children: [
                    Text(
                      focusAddress ? 'Alamat Tersimpan' : 'Edit Profil Nasabah',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                      if (picked != null) {
                        setSheetState(() => selectedImage = File(picked.path));
                      }
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: _primaryDark,
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : (nasabah.foto != null && nasabah.foto!.isNotEmpty
                                  ? (nasabah.foto!.startsWith('http')
                                      ? NetworkImage(nasabah.foto!) as ImageProvider
                                      : FileImage(File(nasabah.foto!)))
                                  : null),
                          child: (selectedImage == null && (nasabah.foto == null || nasabah.foto!.isEmpty))
                              ? Text(
                                  nasabah.namaNasabah.isNotEmpty
                                      ? nasabah.namaNasabah[0].toUpperCase()
                                      : 'N',
                                  style: const TextStyle(
                                    color: _accentLime,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: _accentLime,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 14, color: _primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: telpController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'No. Telepon',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: alamatController,
                  autofocus: focusAddress,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Alamat',
                    prefixIcon: const Icon(Icons.location_on_outlined),
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
                      final newNama = namaController.text.trim();
                      final newAlamat = alamatController.text.trim();
                      final newTelp = telpController.text.trim();

                      if (newNama.isEmpty) {
                        showErrorSnackbar(context, 'Nama tidak boleh kosong');
                        return;
                      }

                      final success = await auth.updateNasabahProfile(
                        namaNasabah: newNama,
                        alamat: newAlamat,
                        telp: newTelp,
                        fotoFile: selectedImage,
                      );

                      if (mounted && ctx.mounted) {
                        Navigator.pop(ctx);
                        if (success) {
                          showSuccessSnackbar(context, 'Profil berhasil diperbarui!');
                        }
                      }
                    },
                    child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEWalletSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
              const Text(
                'Rekening & E-Wallet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih metode penerimaan dana hasil setor sampah:',
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
              const SizedBox(height: 16),
              _buildWalletTile(
                title: 'GoPay',
                subtitle: '0812-****-7890 (Utama)',
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF00AED6),
                isSelected: true,
              ),
              const SizedBox(height: 10),
              _buildWalletTile(
                title: 'DANA',
                subtitle: '0812-****-7890',
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF118EEA),
                isSelected: false,
              ),
              const SizedBox(height: 10),
              _buildWalletTile(
                title: 'Bank Central Asia (BCA)',
                subtitle: '123-****-890',
                icon: Icons.account_balance_rounded,
                color: const Color(0xFF005EAD),
                isSelected: false,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryDark,
                    side: const BorderSide(color: _primaryDark),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Tambah Rekening / E-Wallet', style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    showSuccessSnackbar(context, 'Fitur tambah rekening baru akan segera hadir.');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF86EFAC) : _cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _textDark),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: _textMuted),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 20)
          else
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
        ],
      ),
    );
  }

  void _showBantuanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
              const Text(
                'Pusat Bantuan & Layanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Butuh bantuan terkait setor sampah atau penukaran poin?',
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF15803D)),
                ),
                title: const Text('WhatsApp Petugas', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('+62 812-3456-7890 (Chat Aktif)', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  showSuccessSnackbar(context, 'Membuka layanan chat bantuan...');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.mail_outline_rounded, color: Color(0xFF0284C7)),
                ),
                title: const Text('Email Dukungan', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('support@banksampah.id', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  showSuccessSnackbar(context, 'Email dukungan tersalin ke clipboard.');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.access_time_rounded, color: Color(0xFFB45309)),
                ),
                title: const Text('Jam Operasional Bank Sampah', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Senin - Sabtu: 08.00 - 16.00 WIB', style: TextStyle(fontSize: 12)),
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
        title: const Text(
          'Keluar dari Akun?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _textDark),
        ),
        content: const Text(
          'Anda harus login kembali untuk mengakses data rekening dan riwayat setor sampah Anda.',
          style: TextStyle(fontSize: 14, color: _textMuted),
        ),
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

  String _getTierLevel(int points) {
    if (points >= 2000) return 'Level Emas';
    if (points >= 1000) return 'Level Perak';
    return 'Level Perunggu';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final setorProvider = context.watch<SetorSampahProvider>();
    final nasabah = auth.currentUser?.nasabah;

    // Calculations for stats
    final totalKgValue = (_summary?.totalSampahDisetorKg != null && _summary!.totalSampahDisetorKg > 0)
        ? _summary!.totalSampahDisetorKg
        : 86.4; // fallback mockup
    final totalKgFormatted = totalKgValue.toStringAsFixed(1).replaceAll('.', ',');

    final kaliSetor = setorProvider.mySetorList.isNotEmpty
        ? setorProvider.mySetorList.length
        : 21; // fallback mockup

    final nasabahPoin = nasabah?.saldoPoin;
    final poinValue = (nasabahPoin != null && nasabahPoin > 0)
        ? nasabahPoin
        : (_summary?.saldoPoinSaatIni != null && _summary!.saldoPoinSaatIni > 0
            ? _summary!.saldoPoinSaatIni.toInt()
            : 1240); // fallback mockup
    final poinFormatted = NumberFormat.decimalPattern('id_ID').format(poinValue);

    final String displayName = (nasabah != null && nasabah.namaNasabah.isNotEmpty)
        ? nasabah.namaNasabah
        : (auth.currentUser?.username.isNotEmpty == true
            ? auth.currentUser!.username
            : 'Rina Wulandari');

    final String displayTelp = (nasabah != null && nasabah.telp.isNotEmpty)
        ? nasabah.telp
        : '+62 812 3456 7890';

    final String initialChar = displayName.trim().isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : 'R';

    final String nasabahId = (nasabah != null && nasabah.id.isNotEmpty)
        ? (nasabah.id.startsWith('NSB-') ? nasabah.id : 'NSB-${nasabah.id}')
        : 'NSB-0231';

    final String tier = _getTierLevel(poinValue);

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
                // ── Header (Profil & Theme Button) ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mode terang aktif'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _cardBorder, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.light_mode_outlined,
                          color: _textDark,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_loading) ...[
                  const SizedBox(height: 12),
                  const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: _primaryDark,
                      backgroundColor: Color(0xFFE8F5E9),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Top User Profile Card ────────────────────────────────────
                GestureDetector(
                  onTap: () => _showEditProfileSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _cardBorder, width: 1),
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
                          onTap: _pickAndUploadPhoto,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: _primaryDark,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: nasabah?.foto != null && nasabah!.foto!.isNotEmpty
                                ? (nasabah.foto!.startsWith('http')
                                    ? Image.network(nasabah.foto!, fit: BoxFit.cover)
                                    : Image.file(File(nasabah.foto!), fit: BoxFit.cover))
                                : Center(
                                    child: Text(
                                      initialChar,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: _accentLime,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Name, Phone & Tier Badge
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
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                displayTelp,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _badgeLime,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tier,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Stats Card (3 Columns: Total setor, Kali setor, Poin hijau) ─
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _cardBorder, width: 1),
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
                      // Total Setor
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$totalKgFormatted kg',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Total setor',
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

                      // Kali Setor
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$kaliSetor',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Kali setor',
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

                      // Poin Hijau
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              poinFormatted,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Poin hijau',
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

                // ── Section: Bank Sampah Saya ────────────────────────────────
                const Text(
                  'Bank sampah saya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LokasiBankSampahScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _primaryDark,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryDark.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E5B42),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.home_outlined,
                            color: _accentLime,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bank Sampah Melati Asri',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ID nasabah $nasabahId · Buka 08.00–16.00',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                    border: Border.all(color: _cardBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Alamat Tersimpan
                      _buildMenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Alamat tersimpan',
                        onTap: () => _showEditProfileSheet(context, focusAddress: true),
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

                      // Rekening & E-wallet
                      _buildMenuItem(
                        icon: Icons.credit_card_outlined,
                        title: 'Rekening & e-wallet',
                        onTap: () => _showEWalletSheet(context),
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

                      // Notifikasi
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifikasi',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

                      // Bantuan
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Bantuan',
                        onTap: () => _showBantuanSheet(context),
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

                      // Keluar
                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        title: 'Keluar',
                        isDestructive: true,
                        showChevron: false,
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showChevron = true,
  }) {
    final itemColor = isDestructive ? const Color(0xFFC2410C) : _textDark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: itemColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: isDestructive ? FontWeight.w700 : FontWeight.w600,
                  color: itemColor,
                ),
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF94A3B8),
              ),
          ],
        ),
      ),
    );
  }
}
