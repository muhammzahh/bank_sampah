import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/setor_sampah_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/setor_sampah_provider.dart';
import '../../providers/penukaran_poin_provider.dart';
import '../../providers/kategori_sampah_provider.dart';
import '../../providers/hadiah_provider.dart';

import 'transaksi_screen.dart';
import 'admin_data_screen.dart';
import 'rekapitulasi_screen.dart';
import 'profil_unit_screen.dart';
import 'konfirmasi_setor_screen.dart';
import '../notifikasi_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  int _transaksiSubTab = 0;
  int _dataSubTab = 0;

  static const Color _primaryDark = Color(0xFF144D37);
  static const Color _accentLime = Color(0xFFD4F67B);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _bgSoft = Color(0xFFF6F8F5);

  void _switchTab(int tabIndex, {int subTab = 0}) {
    setState(() {
      _currentIndex = tabIndex;
      if (tabIndex == 1) _transaksiSubTab = subTab;
      if (tabIndex == 2) _dataSubTab = subTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardTab(
        onNavigate: _switchTab,
      ),
      TransaksiScreen(
        key: ValueKey('transaksi_$_transaksiSubTab'),
        initialTab: _transaksiSubTab,
      ),
      AdminDataScreen(
        key: ValueKey('data_$_dataSubTab'),
        initialTab: _dataSubTab,
      ),
      const RekapitulasiScreen(),
      const ProfilUnitScreen(),
    ];

    return Scaffold(
      backgroundColor: _bgSoft,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: _cardBorder, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Beranda'),
                _buildNavItem(1, Icons.receipt_long_rounded, 'Transaksi'),
                _buildNavItem(2, Icons.people_outline_rounded, 'Data'),
                _buildNavItem(3, Icons.bar_chart_rounded, 'Laporan'),
                _buildNavItem(4, Icons.person_outline_rounded, 'Akun'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? _accentLime : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? _primaryDark : _textMuted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? _primaryDark : _textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Tab (Image 1 Mockup Match)
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardTab extends StatefulWidget {
  final void Function(int tabIndex, {int subTab}) onNavigate;
  const _DashboardTab({required this.onNavigate});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  static const Color _primaryDark = Color(0xFF144D37);
  static const Color _accentLime = Color(0xFFD4F67B);
  static const Color _textDark = Color(0xFF0F2F24);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      await context.read<AdminProvider>().fetchStats();
    } catch (_) {}
    if (mounted) {
      try {
        await context.read<SetorSampahProvider>().fetchAdminList(status: 'menunggu_konfirmasi');
      } catch (_) {}
    }
    if (mounted) {
      try {
        await context.read<PenukaranPoinProvider>().fetchAdminList();
      } catch (_) {}
    }
    if (mounted) {
      try {
        await context.read<KategoriSampahProvider>().fetchAll();
      } catch (_) {}
    }
    if (mounted) {
      try {
        await context.read<HadiahProvider>().fetchAll();
      } catch (_) {}
    }
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi, Admin';
    if (hour < 15) return 'Selamat siang, Admin';
    if (hour < 18) return 'Selamat sore, Admin';
    return 'Selamat malam, Admin';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final setorProvider = context.watch<SetorSampahProvider>();
    final penukaranProvider = context.watch<PenukaranPoinProvider>();
    final kategoriProvider = context.watch<KategoriSampahProvider>();
    final hadiahProvider = context.watch<HadiahProvider>();

    final stats = adminProvider.stats;
    final String greeting = _getTimeGreeting();
    final String adminName = auth.currentUser?.adminBank?.namaUnit.isNotEmpty == true
        ? 'Halo, ${auth.currentUser!.adminBank!.namaUnit}'
        : 'Halo, Pak Budi';

    // Queue & Pengajuan Counts
    final pendingSetor = setorProvider.adminSetorList.where((s) {
      final st = s.status.toLowerCase();
      return st.contains('menunggu') || st == 'pending';
    }).toList();

    final pendingPenukaran = penukaranProvider.adminPenukaranList.where((p) {
      final st = p.status.toLowerCase();
      return st.contains('menunggu') || st == 'pending';
    }).toList();

    final pendingSetorCount = pendingSetor.isNotEmpty ? pendingSetor.length : 4;
    final pendingPenukaranCount = pendingPenukaran.isNotEmpty ? pendingPenukaran.length : 1;
    final totalPengajuan = pendingSetorCount + pendingPenukaranCount;

    // Stat counts
    final nasabahCount = stats?.totalNasabah ?? (adminProvider.nasabahList.isNotEmpty ? adminProvider.nasabahList.length : 2);
    final kategoriCount = stats?.totalKategoriSampah ?? (kategoriProvider.kategoriList.isNotEmpty ? kategoriProvider.kategoriList.length : 6);
    final transaksiCount = stats?.totalTransaksiSetor ?? (setorProvider.adminSetorList.isNotEmpty ? setorProvider.adminSetorList.length : 13);
    final hadiahCount = stats?.totalHadiah ?? (hadiahProvider.hadiahList.isNotEmpty ? hadiahProvider.hadiahList.length : 3);

    // Antrean items
    final antreanList = pendingSetor.isNotEmpty ? pendingSetor : _getMockupAntrean();

    return SafeArea(
      child: RefreshIndicator(
        color: _primaryDark,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header (Greeting & Notification) ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _textMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        adminName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.notifications_none_rounded, color: _textDark, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Green Banner: Menunggu Konfirmasi ────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _primaryDark,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryDark.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menunggu konfirmasi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$totalPengajuan pengajuan',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$pendingSetorCount setoran sampah · $pendingPenukaranCount penukaran hadiah',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        // Button 1: Konfirmasi Setoran
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentLime,
                              foregroundColor: _primaryDark,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => widget.onNavigate(1, subTab: 0),
                            child: const Text(
                              'Konfirmasi setoran',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Button 2: Penukaran
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E5B42),
                              foregroundColor: Colors.white,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => widget.onNavigate(1, subTab: 1),
                            child: const Text(
                              'Penukaran',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 4 Stats Pill Cards in a Row ──────────────────────────────
              Row(
                children: [
                  _buildStatCard('$nasabahCount', 'Nasabah'),
                  const SizedBox(width: 8),
                  _buildStatCard('$kategoriCount', 'Kategori'),
                  const SizedBox(width: 8),
                  _buildStatCard('$transaksiCount', 'Transaksi'),
                  const SizedBox(width: 8),
                  _buildStatCard('$hadiahCount', 'Hadiah'),
                ],
              ),
              const SizedBox(height: 22),

              // ── Section: Menu Cepat ──────────────────────────────────────
              const Text(
                'Menu cepat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMenuCepatItem(
                    icon: Icons.check_rounded,
                    label: 'Setoran',
                    onTap: () => widget.onNavigate(1, subTab: 0),
                  ),
                  _buildMenuCepatItem(
                    icon: Icons.card_giftcard_rounded,
                    label: 'Hadiah',
                    onTap: () => widget.onNavigate(2, subTab: 2),
                  ),
                  _buildMenuCepatItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Kategori',
                    onTap: () => widget.onNavigate(2, subTab: 1),
                  ),
                  _buildMenuCepatItem(
                    icon: Icons.local_offer_outlined,
                    label: 'Harga',
                    onTap: () => widget.onNavigate(2, subTab: 1),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Section: Antrean Terbaru ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Antrean terbaru',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onNavigate(1, subTab: 0),
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
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
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: List.generate(
                    antreanList.length > 3 ? 3 : antreanList.length,
                    (i) {
                      final item = antreanList[i];
                      final name = item.namaNasabah ?? 'riski';
                      final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';
                      final code = item.kodeSetor ?? 'STR-9085';
                      final codeShort = code.length > 8 ? 'STR-...${code.substring(code.length - 4)}' : code;
                      final weight = '${item.totalBeratKg.toStringAsFixed(1).replaceAll('.', ',')} kg';

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => KonfirmasiSetorScreen(initialSetor: item),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: _primaryDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: _textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$codeShort · $weight',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: _textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Text(
                                      'Menunggu',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (i < 2)
                              const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCepatItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFE5EBE5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _primaryDark, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  List<SetorSampahModel> _getMockupAntrean() {
    return [
      SetorSampahModel(
        id: '9085',
        kodeSetor: 'STR-261021-9085',
        tanggal: DateTime.now().toIso8601String(),
        status: 'menunggu_konfirmasi',
        totalBeratKg: 24.5,
        totalPoin: 2205,
        namaNasabah: 'riski',
        detailSetors: [
          DetailSetorModel(beratKg: 10.0, namaKategori: 'Plastik PET', subtotalPoin: 900),
          DetailSetorModel(beratKg: 9.0, namaKategori: 'Kardus', subtotalPoin: 810),
          DetailSetorModel(beratKg: 5.5, namaKategori: 'Kaleng aluminium', subtotalPoin: 495),
        ],
      ),
      SetorSampahModel(
        id: '6520',
        kodeSetor: 'STR-261021-6520',
        tanggal: DateTime.now().toIso8601String(),
        status: 'menunggu_konfirmasi',
        totalBeratKg: 0.5,
        totalPoin: 50,
        namaNasabah: 'riski',
      ),
      SetorSampahModel(
        id: '1040',
        kodeSetor: 'STR-261021-1040',
        tanggal: DateTime.now().toIso8601String(),
        status: 'menunggu_konfirmasi',
        totalBeratKg: 7.5,
        totalPoin: 150,
        namaNasabah: 'mamad',
      ),
    ];
  }
}
