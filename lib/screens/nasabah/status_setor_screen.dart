import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../models/setor_sampah_model.dart';
import '../../providers/setor_sampah_provider.dart';
import 'nota_setor_screen.dart';

class StatusSetorScreen extends StatefulWidget {
  final bool isTab;
  const StatusSetorScreen({super.key, this.isTab = false});

  @override
  State<StatusSetorScreen> createState() => _StatusSetorScreenState();
}

class _StatusSetorScreenState extends State<StatusSetorScreen> {
  static const Color _bgColor = Color(0xFFF6F8F5);
  static const Color _primaryDark = Color(0xFF144D37);
  static const Color _lime = Color(0xFFD4F67B);
  static const Color _textDark = Color(0xFF0F2F24);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE5E7EB);

  String _selectedTab = 'semua'; // 'semua', 'menunggu', 'terkonfirmasi'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SetorSampahProvider>().fetchMySetor();
    });
  }

  bool _isMenunggu(String status) {
    final s = status.toLowerCase();
    return s.contains('menunggu') || s == 'diproses' || s == 'pending';
  }

  bool _isTerkonfirmasi(String status) {
    final s = status.toLowerCase();
    return s == 'diverifikasi' ||
        s == 'selesai' ||
        s == 'terkonfirmasi' ||
        (s.contains('konfirmasi') && !s.contains('menunggu'));
  }

  List<SetorSampahModel> _filterList(List<SetorSampahModel> fullList) {
    if (_selectedTab == 'menunggu') {
      return fullList.where((it) => _isMenunggu(it.status)).toList();
    } else if (_selectedTab == 'terkonfirmasi') {
      return fullList.where((it) => _isTerkonfirmasi(it.status)).toList();
    }
    return fullList;
  }

  IconData _iconForCategory(String nama) {
    final lower = nama.toLowerCase();
    if (lower.contains('plastik')) return Icons.liquor_outlined;
    if (lower.contains('kardus')) return Icons.inventory_2_outlined;
    if (lower.contains('kertas')) return Icons.description_outlined;
    if (lower.contains('kaleng') || lower.contains('logam') || lower.contains('besi')) {
      return Icons.smart_screen_outlined;
    }
    if (lower.contains('kaca')) return Icons.wine_bar_outlined;
    return Icons.recycling_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SetorSampahProvider>();
    final allList = provider.mySetorList;
    final filtered = _filterList(allList);

    final countSemua = allList.length;
    final countMenunggu = allList.where((s) => _isMenunggu(s.status)).length;
    final countTerkonfirmasi = allList.where((s) => _isTerkonfirmasi(s.status)).length;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Section ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isTab && Navigator.canPop(context)) ...[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _borderColor),
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: _textDark,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                  const Text(
                    'Riwayat setor',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pantau status pengajuan dan konfirmasi sampah',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 3 Menu Tabs (Semua, Menunggu, Terkonfirmasi) ─────────
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EFEA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTabItem(
                            id: 'semua',
                            label: 'Semua',
                            count: countSemua,
                          ),
                        ),
                        Expanded(
                          child: _buildTabItem(
                            id: 'menunggu',
                            label: 'Menunggu',
                            count: countMenunggu,
                          ),
                        ),
                        Expanded(
                          child: _buildTabItem(
                            id: 'terkonfirmasi',
                            label: 'Terkonfirmasi',
                            count: countTerkonfirmasi,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── List of Transactions ─────────────────────────────────────
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _primaryDark,
                        strokeWidth: 2.5,
                      ),
                    )
                  : filtered.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: _primaryDark,
                          onRefresh: () => provider.fetchMySetor(),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return _buildSetorItemCard(item);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String id,
    required String label,
    required int count,
  }) {
    final isSelected = _selectedTab == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = id),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryDark.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _lime
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? _primaryDark : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSetorItemCard(SetorSampahModel item) {
    final poin = item.totalPoin ?? item.estimasiTotalPoin ?? 0;
    final rupiah = poin * 1000;
    final categoryName = item.namaSampahDisplay.isNotEmpty
        ? item.namaSampahDisplay
        : 'Sampah Daur Ulang';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NotaSetorScreen(setorId: item.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForCategory(categoryName),
                color: _primaryDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Main Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setor $categoryName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${Formatters.tanggalSingkat(item.tanggal)} • ${item.totalBeratKg.toStringAsFixed(1).replaceAll('.', ',')} kg',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildStatusBadge(item.status),
                ],
              ),
            ),

            // Value & Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rupiah > 0
                      ? Formatters.rupiah(rupiah)
                      : '${item.totalBeratKg} kg',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    if (_isMenunggu(status)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 12, color: Color(0xFFB45309)),
            SizedBox(width: 4),
            Text(
              'Menunggu',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB45309),
              ),
            ),
          ],
        ),
      );
    } else if (_isTerkonfirmasi(status)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF065F46)),
            SizedBox(width: 4),
            Text(
              'Terkonfirmasi',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF065F46),
              ),
            ),
          ],
        ),
      );
    } else if (status.toLowerCase() == 'ditolak') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel_rounded, size: 12, color: Color(0xFFB91C1C)),
            SizedBox(width: 4),
            Text(
              'Ditolak',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB91C1C),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        Formatters.statusLabel(status),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = 'Belum ada riwayat penyetoran';
    String submessage = 'Mulai setor sampah untuk mendapatkan poin dan saldo.';
    if (_selectedTab == 'menunggu') {
      message = 'Tidak ada yang menunggu';
      submessage = 'Semua pengajuan setor Anda telah diproses.';
    } else if (_selectedTab == 'terkonfirmasi') {
      message = 'Belum ada yang terkonfirmasi';
      submessage = 'Pengajuan yang telah dikonfirmasi petugas akan muncul di sini.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: _primaryDark,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              submessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: _textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
