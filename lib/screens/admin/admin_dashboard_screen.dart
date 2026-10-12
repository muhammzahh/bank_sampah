import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/setor_sampah_provider.dart';
import '../../providers/penukaran_poin_provider.dart';
import '../widgets/common_widgets.dart';
import 'nasabah_crud_screen.dart';
import 'kategori_crud_screen.dart';
import 'hadiah_crud_screen.dart';
import 'konfirmasi_setor_screen.dart';
import 'konfirmasi_penukaran_screen.dart';
import 'transaksi_screen.dart';
import 'rekapitulasi_screen.dart';
import 'profil_unit_screen.dart';
import '../notifikasi_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _DashboardTab(),
    const TransaksiScreen(),
    const NasabahCrudScreen(),
    const RekapitulasiScreen(),
    const ProfilUnitScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _ModernAdminBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Modern Floating Bottom Navigation Bar for Admin
// ─────────────────────────────────────────────────────────────────────────────
class _ModernAdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ModernAdminBottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard'),
    (icon: Icons.receipt_long_rounded, label: 'Transaksi'),
    (icon: Icons.people_rounded, label: 'Data'),
    (icon: Icons.bar_chart_rounded, label: 'Laporan'),
    (icon: Icons.person_rounded, label: 'Akun'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2417), // Dark forest green matching design
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = currentIndex == i;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: selected ? 58 : 50,
                  height: selected ? 58 : 50,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF22C55E) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: selected ? 20 : 18,
                        color: selected ? const Color(0xFF0C2417) : Colors.white,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          color: selected ? const Color(0xFF0C2417) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Tab
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchStats();
      context.read<SetorSampahProvider>().fetchAdminList(status: 'menunggu_konfirmasi');
      context.read<PenukaranPoinProvider>().fetchAdminList();
    });
  }

  void _showAdminNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
    );
  }



  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();
    final namaUnit = auth.currentUser?.adminBank?.namaUnit ?? 'Admin';
    final stats = adminProvider.stats;

    return CustomScrollView(
      slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Halo Admin 👋',
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            namaUnit,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAdminNotifications(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: AppColors.textDark, size: 24),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
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

        // ── Stats Grid ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: stats == null
                ? const LoadingView()
                : GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _StatBox(
                        icon: Icons.people_rounded,
                        label: 'Total Nasabah',
                        value: '${stats.totalNasabah}',
                        color: const Color(0xFF3B82F6),
                      ),
                      _StatBox(
                        icon: Icons.category_rounded,
                        label: 'Kategori Sampah',
                        value: '${stats.totalKategoriSampah}',
                        color: const Color(0xFF10B981),
                      ),
                      _StatBox(
                        icon: Icons.receipt_long_rounded,
                        label: 'Total Transaksi',
                        value: '${stats.totalTransaksiSetor}',
                        color: const Color(0xFFF59E0B),
                      ),
                      _StatBox(
                        icon: Icons.card_giftcard_rounded,
                        label: 'Katalog Hadiah',
                        value: '${stats.totalHadiah}',
                        color: const Color(0xFF8B5CF6),
                      ),
                    ],
                  ),
          ),
        ),

        // ── Quick Menu ────────────────────────────────────────────────────
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Menu Cepat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.fact_check_rounded,
                  label: 'Konfirmasi Penyetoran Sampah',
                  subtitle: 'Verifikasi pengajuan dari nasabah',
                  color: AppColors.primary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KonfirmasiSetorScreen()),
                  ),
                ),
                _MenuTile(
                  icon: Icons.confirmation_number_rounded,
                  label: 'Konfirmasi Penukaran Hadiah',
                  subtitle: 'Verifikasi pengajuan tukar poin nasabah',
                  color: const Color(0xFFD97706),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KonfirmasiPenukaranScreen()),
                  ),
                ),
                _MenuTile(
                  icon: Icons.people_rounded,
                  label: 'Kelola Data Nasabah',
                  subtitle: 'Tambah, edit, hapus nasabah',
                  color: const Color(0xFF3B82F6),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NasabahCrudScreen()),
                  ),
                ),
                _MenuTile(
                  icon: Icons.category_rounded,
                  label: 'Kelola Kategori Sampah',
                  subtitle: 'Atur jenis dan harga sampah',
                  color: const Color(0xFF10B981),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KategoriCrudScreen()),
                  ),
                ),
                _MenuTile(
                  icon: Icons.card_giftcard_rounded,
                  label: 'Kelola Hadiah / Voucher',
                  subtitle: 'Atur katalog penukaran poin',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HadiahCrudScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
