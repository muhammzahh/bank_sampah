import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../models/kategori_sampah_model.dart';
import '../../models/rekapitulasi_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kategori_sampah_provider.dart';
import '../../providers/setor_sampah_provider.dart';
import '../../services/dashboard_service.dart';

import '../notifikasi_screen.dart';

import 'kategori_sampah_screen.dart';
import 'ajukan_setor_screen.dart';
import 'status_setor_screen.dart';
import 'hadiah_screen.dart';
import 'nota_setor_screen.dart';
import 'profil_nasabah_screen.dart';

class NasabahHomeScreen extends StatefulWidget {
  const NasabahHomeScreen({super.key});

  @override
  State<NasabahHomeScreen> createState() => _NasabahHomeScreenState();
}

class _NasabahHomeScreenState extends State<NasabahHomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<_BerandaTabState> _berandaKey = GlobalKey<_BerandaTabState>();

  List<Widget> _buildPages() {
    return [
      _BerandaTab(
        key: _berandaKey,
        onSelectTab: (index) => setState(() => _currentIndex = index),
      ),
      KategoriSampahScreen(
        title: 'Jenis sampah',
        subtitle: 'Pilih jenis sampah atau ajukan setor langsung',
        showSetorColumn: true,
        onAjukanSetor: (k) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AjukanSetorScreen(initialKategori: k),
            ),
          );
        },
      ),
      const StatusSetorScreen(isTab: true),
      const ProfilNasabahScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      body: IndexedStack(
        index: _currentIndex,
        children: _buildPages(),
      ),
      bottomNavigationBar: _MinimalBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) {
            _berandaKey.currentState?.reload();
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Minimal Modern Bottom Navigation Bar (Beranda, Setor, Harga, Profil)
// ─────────────────────────────────────────────────────────────────────────────
class _MinimalBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MinimalBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Beranda'),
              _buildNavItem(1, Icons.delete_rounded, Icons.delete_outline_rounded, 'Setor'),
              _buildNavItem(2, Icons.history_rounded, Icons.history_outlined, 'Riwayat'),
              _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = currentIndex == index;
    const activeColor = Color(0xFF144D37);
    const inactiveColor = Color(0xFF6B7280);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD9F99D) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? activeIcon : inactiveIcon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab Beranda (New Clean Design Matching Mockup)
// ─────────────────────────────────────────────────────────────────────────────
class _BerandaTab extends StatefulWidget {
  final ValueChanged<int>? onSelectTab;
  const _BerandaTab({super.key, this.onSelectTab});

  @override
  State<_BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<_BerandaTab> {
  DashboardSummaryModel? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void reload() {
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final summary = await DashboardService.getNasabahSummary();
      if (mounted) {
        setState(() {
          _summary = summary;
        });
      }
    } catch (_) {}
    if (mounted) {
      await context.read<SetorSampahProvider>().fetchMySetor();
      if (!mounted) return;
      await context.read<KategoriSampahProvider>().fetchAll();
      if (!mounted) return;
      await context.read<AuthProvider>().refreshProfile();
      if (mounted) setState(() => _loading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _getNextJemputanDate() {
    final now = DateTime.now();
    // Default jemputan hari Kamis atau 2 hari ke depan
    final target = now.add(const Duration(days: 2));
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dayName = days[target.weekday - 1];
    final monthName = months[target.month - 1];
    return '$dayName, ${target.day} $monthName';
  }

  void _showJemputanDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.local_shipping_rounded, color: Color(0xFF144D37)),
            SizedBox(width: 10),
            Text('Jadwal Penjemputan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Petugas bank sampah akan menjemput sampah Anda sesuai jadwal berikut:',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hari/Tanggal: ${_getNextJemputanDate()}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  const Text('Waktu: 08.00 – 10.00 WIB', style: TextStyle(fontSize: 13, color: Color(0xFF334155))),
                  const SizedBox(height: 4),
                  const Text('Petugas: Budi Santoso (0812-3456-7890)', style: TextStyle(fontSize: 13, color: Color(0xFF334155))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onSelectTab?.call(1);
            },
            child: const Text('Atur Jadwal Jemput', style: TextStyle(color: Color(0xFF144D37), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String nama, String jenis) {
    final lower = '$nama $jenis'.toLowerCase();
    if (lower.contains('plastik') || lower.contains('botol')) return Icons.water_drop_outlined;
    if (lower.contains('kardus') || lower.contains('kertas')) return Icons.inventory_2_outlined;
    if (lower.contains('kaleng') || lower.contains('logam') || lower.contains('besi')) return Icons.view_agenda_outlined;
    if (lower.contains('kaca') || lower.contains('beling')) return Icons.wine_bar_outlined;
    return Icons.eco_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final setorProvider = context.watch<SetorSampahProvider>();
    final katProvider = context.watch<KategoriSampahProvider>();

    final nasabah = auth.currentUser?.nasabah;
    final saldoPoin = nasabah?.saldoPoin ?? 0;
    // Nilai rupiah saldo tabungan (1 poin = Rp 1000 atau nominal saldo)
    final saldoRupiah = saldoPoin * 1000;

    final totalDisetorKg = _summary?.totalSampahDisetorKg ??
        setorProvider.mySetorList
            .where((s) => s.status.toLowerCase() == 'selesai' || s.status.toLowerCase() == 'diverifikasi')
            .fold<num>(0, (sum, item) => sum + item.totalBeratKg);

    final firstName = nasabah != null && nasabah.namaNasabah.trim().isNotEmpty
        ? nasabah.namaNasabah.trim().split(' ').first
        : (auth.currentUser?.username ?? 'Nasabah');

    return RefreshIndicator(
      color: const Color(0xFF144D37),
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Header Greeting & Notification ─────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Halo, $firstName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Center(
                              child: Icon(
                                Icons.notifications_none_rounded,
                                color: Color(0xFF0F172A),
                                size: 22,
                              ),
                            ),
                            if (setorProvider.mySetorList.isNotEmpty)
                              Positioned(
                                right: 10,
                                top: 10,
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

            // ── Saldo Tabungan Hero Card ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF144D37),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF144D37).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo tabungan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _loading
                        ? const SizedBox(
                            height: 36,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              ),
                            ),
                          )
                        : Text(
                            Formatters.rupiah(saldoRupiah),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                    const SizedBox(height: 14),

                    // Badges (Poin & Kg Disetor)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E5B42),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: Text(
                            '${Formatters.rupiah(saldoPoin).replaceAll('Rp ', '')} poin',
                            style: const TextStyle(
                              color: Color(0xFFA7F3D0),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E5B42),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: Text(
                            '${totalDisetorKg.toString().replaceAll('.', ',')} kg disetor',
                            style: const TextStyle(
                              color: Color(0xFFA7F3D0),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Two Action Buttons: Setor Sampah & Tarik Saldo
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4F67B), // Lime yellow-green
                              foregroundColor: const Color(0xFF144D37),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              widget.onSelectTab?.call(1);
                            },
                            child: const Text(
                              'Setor sampah',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF144D37),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F3E2B), // Dark translucent green
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const HadiahScreen()),
                              ).then((_) => _load());
                            },
                            child: const Text(
                              'Tukar poin',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Jemputan Card ──────────────────────────────────────────────
            GestureDetector(
              onTap: _showJemputanDialog,
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        color: Color(0xFF144D37),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jemputan ${_getNextJemputanDate()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '08.00–10.00 • Petugas Budi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),

            // ── Harga Hari Ini Section ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Harga hari ini',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onSelectTab?.call(1), // switch to Jenis Sampah
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF144D37),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Price Cards
            SizedBox(
              height: 144,
              child: katProvider.kategoriList.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: katProvider.kategoriList.length,
                      itemBuilder: (context, index) {
                        final k = katProvider.kategoriList[index];
                        return _buildPriceCard(k);
                      },
                    )
                  : _buildDefaultPriceCards(),
            ),

            // ── Aktivitas Terakhir Section ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aktivitas terakhir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onSelectTab?.call(2), // switch to Riwayat tab
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF144D37),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: setorProvider.mySetorList.isNotEmpty
                    ? Column(
                        children: List.generate(
                          setorProvider.mySetorList.length > 3 ? 3 : setorProvider.mySetorList.length,
                          (i) {
                            final item = setorProvider.mySetorList[i];
                            final isLast = i == (setorProvider.mySetorList.length > 3 ? 2 : setorProvider.mySetorList.length - 1);
                            final poin = item.totalPoin ?? item.estimasiTotalPoin ?? 0;
                            final rupiah = poin * 1000;

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => NotaSetorScreen(setorId: item.id)),
                                    );
                                  },
                                  leading: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_upward_rounded,
                                      color: Color(0xFF15803D),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    'Setor ${item.namaSampahDisplay.toLowerCase()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${Formatters.tanggalSingkat(item.tanggal)} • ${item.totalBeratKg} kg',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  trailing: Text(
                                    '+${Formatters.rupiah(rupiah)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                                if (!isLast)
                                  const Divider(height: 1, indent: 68, endIndent: 16, color: Color(0xFFF1F5F9)),
                              ],
                            );
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: const [
                              Icon(Icons.receipt_long_outlined, size: 36, color: Color(0xFF94A3B8)),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada aktivitas penyetoran',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(KategoriSampahModel k) {
    return GestureDetector(
      onTap: () {
        widget.onSelectTab?.call(1);
      },
      child: Container(
        width: 112,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(k.namaKategori, k.jenis),
                color: const Color(0xFF144D37),
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              k.namaKategori,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rp',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${Formatters.rupiah(k.hargaPerKg).replaceAll('Rp ', '')}/kg',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPriceCards() {
    final sampleItems = [
      {'nama': 'Plastik PET', 'harga': 3200, 'icon': Icons.water_drop_outlined},
      {'nama': 'Kardus', 'harga': 1800, 'icon': Icons.inventory_2_outlined},
      {'nama': 'Kaleng', 'harga': 4500, 'icon': Icons.view_agenda_outlined},
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sampleItems.length,
      itemBuilder: (context, index) {
        final item = sampleItems[index];
        return GestureDetector(
          onTap: () => widget.onSelectTab?.call(1),
          child: Container(
            width: 112,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: const Color(0xFF144D37),
                    size: 20,
                  ),
                ),
                Text(
                  item['nama'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rp',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${Formatters.rupiah(item['harga'] as num).replaceAll('Rp ', '')}/kg',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
