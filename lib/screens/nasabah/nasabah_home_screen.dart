import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kategori_sampah_provider.dart';
import '../../providers/setor_sampah_provider.dart';

import '../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import '../notifikasi_screen.dart';

import 'kategori_sampah_screen.dart';
import 'ajukan_setor_screen.dart';
import 'status_setor_screen.dart';
import 'lokasi_bank_sampah_screen.dart';
import 'nota_setor_screen.dart';

class NasabahHomeScreen extends StatefulWidget {
  const NasabahHomeScreen({super.key});

  @override
  State<NasabahHomeScreen> createState() => _NasabahHomeScreenState();
}

class _NasabahHomeScreenState extends State<NasabahHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _BerandaTab(),
    const StatusSetorScreen(), // Riwayat
    const SizedBox(), // Placeholder for Scanner FAB
    const LokasiBankSampahScreen(), // Lokasi
    const _AkunNasabahTab(), // Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Scanner / QR Action
        },
        backgroundColor: const Color(0xFF1E402D), // Dark Green
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i != 2) setState(() => _currentIndex = i);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 20,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Beranda',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.receipt_long_rounded,
              label: 'Riwayat',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 40), // Space for FAB
            _NavItem(
              icon: Icons.location_on_rounded,
              label: 'Lokasi',
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              isSelected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF1E402D) : const Color(0xFF94A3B8);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(height: 7), // Placeholder for line
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Beranda Tab
// ─────────────────────────────────────────────────────────────────────────────
class _BerandaTab extends StatefulWidget {
  const _BerandaTab();

  @override
  State<_BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<_BerandaTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KategoriSampahProvider>().fetchAll();
    });
  }

  IconData _jenisIcon(String jenis, [String nama = '']) {
    final s = '$jenis $nama'.toLowerCase();
    if (s.contains('plastik')) return Icons.local_drink_rounded;
    if (s.contains('kertas') || s.contains('kardus')) return Icons.inventory_2_rounded;
    if (s.contains('logam')) return Icons.hardware_rounded;
    if (s.contains('kaca')) return Icons.wine_bar_rounded;
    if (s.contains('styrofoam')) return Icons.takeout_dining_rounded;
    return Icons.recycling_rounded;
  }

  String _getSub(String nama) {
    final s = nama.toLowerCase();
    if (s.contains('plastik')) return 'Botol, gelas, kemasan plastik';
    if (s.contains('kertas')) return 'Koran, kardus, kertas HVS';
    if (s.contains('logam')) return 'Kaleng, besi, aluminium';
    if (s.contains('kaca')) return 'Botol kaca, pecahan kaca';
    if (s.contains('kardus')) return 'Kardus bekas, dus';
    if (s.contains('styrofoam')) return 'Wadah makanan, styrofoam';
    return 'Daur ulang sampah ini';
  }

  @override
  Widget build(BuildContext context) {
    final katProvider = context.watch<KategoriSampahProvider>();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => katProvider.fetchAll(),
      child: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E402D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bank Sampah',
                            style: TextStyle(
                              color: Color(0xFF1E402D),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ubah sampah jadi nilai,\nuntuk lingkungan yang lebih baik.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E402D), size: 24),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
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

          // ── Top Banner ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5F0), // Light green
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.eco_rounded, color: Color(0xFF1E402D), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ayo mulai pilah sampah\ndari sekarang!',
                                  style: const TextStyle(
                                    color: Color(0xFF1E402D),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Kategori yang tepat, nilai lebih besar.',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Illustration placeholder
                    const Icon(Icons.public_rounded, color: Color(0xFF86EFAC), size: 64),
                  ],
                ),
              ),
            ),
          ),

          // ── Kategori Grid Header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Kategori Sampah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E402D),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey.shade600, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Grid Kategori ───────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: katProvider.isLoading && katProvider.kategoriList.isEmpty
                ? const SliverToBoxAdapter(child: LoadingView())
                : katProvider.kategoriList.isEmpty
                    ? const SliverToBoxAdapter(
                        child: EmptyView(message: 'Belum ada kategori', icon: Icons.recycling),
                      )
                    : SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8, // Adjust ratio for taller cards
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final k = katProvider.kategoriList[index];
                            final sub = _getSub(k.namaKategori);

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AjukanSetorScreen(initialKategori: k),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(_jenisIcon(k.jenis, k.namaKategori), color: const Color(0xFF64748B), size: 24),
                                        ),
                                        Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      k.namaKategori,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: Color(0xFF1E293B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sub,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    // Info Badges Row
                                    Row(
                                      children: [
                                        _DetailBadge(
                                          icon: Icons.attach_money_rounded,
                                          text: '${Formatters.rupiah(k.hargaPerKg)}/kg',
                                          color: const Color(0xFF1E402D),
                                          bgColor: const Color(0xFFEAF5F0),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          height: 12,
                                          width: 1,
                                          color: Colors.grey.shade300,
                                        ),
                                        _DetailBadge(
                                          icon: Icons.star_outline_rounded,
                                          text: '${k.poinPerKg} Poin/kg',
                                          color: const Color(0xFF1E402D),
                                          bgColor: Colors.transparent, // or a soft orange if desired, but design looks transparent
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: katProvider.kategoriList.length,
                        ),
                      ),
          ),

          // ── Bottom Banner ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.eco_rounded, color: Color(0xFF1E402D), size: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Yuk, kumpulkan sampahmu!',
                            style: TextStyle(
                              color: Color(0xFF1E402D),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Setiap kilogramnya berarti untuk lingkungan.',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AjukanSetorScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E402D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Ajukan Setor',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color bgColor;

  const _DetailBadge({
    required this.icon,
    required this.text,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profil Tab (Minimal)
// ─────────────────────────────────────────────────────────────────────────────
class _AkunNasabahTab extends StatefulWidget {
  const _AkunNasabahTab();
  @override
  State<_AkunNasabahTab> createState() => _AkunNasabahTabState();
}

class _AkunNasabahTabState extends State<_AkunNasabahTab> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final nasabah = auth.currentUser?.nasabah;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: Color(0xFF1E402D), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF5F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, size: 50, color: Color(0xFF1E402D)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              nasabah?.namaNasabah ?? auth.currentUser?.username ?? 'Nasabah',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E402D)),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }
}

