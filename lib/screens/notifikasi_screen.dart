import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/storage/local_storage.dart';
import '../core/utils/formatters.dart';
import '../providers/auth_provider.dart';
import '../providers/setor_sampah_provider.dart';
import '../providers/penukaran_poin_provider.dart';
import 'widgets/common_widgets.dart';
import 'nasabah/nota_setor_screen.dart';
import 'nasabah/nota_penukaran_screen.dart';
import 'admin/konfirmasi_setor_screen.dart';
import 'admin/konfirmasi_penukaran_screen.dart';

/// Halaman Khusus Notifikasi & Pemberitahuan Masuk (Nasabah & Admin).
/// Pengguna dapat membaca rincian lewat Bottom Sheet & menandai selesai dibaca agar notifikasi hilang.
class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  String _filterType = 'semua'; // 'semua', 'setor', 'penukaran'
  Set<String> _readNotifIds = {};
  bool _loadingReadIds = true;

  @override
  void initState() {
    super.initState();
    _loadReadNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser?.isAdmin == true) {
        context.read<SetorSampahProvider>().fetchAdminList(status: 'menunggu_konfirmasi');
        context.read<PenukaranPoinProvider>().fetchAdminList();
      } else {
        context.read<SetorSampahProvider>().fetchMySetor();
        context.read<PenukaranPoinProvider>().fetchMyPenukaran();
      }
    });
  }

  Future<void> _loadReadNotifications() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? 'guest';
    final readList = await LocalStorage.getReadNotifications(userId);
    if (mounted) {
      setState(() {
        _readNotifIds = readList.toSet();
        _loadingReadIds = false;
      });
    }
  }

  Future<void> _markAsRead(String notifId) async {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? 'guest';
    await LocalStorage.markNotificationRead(userId, notifId);
    if (mounted) {
      setState(() {
        _readNotifIds.add(notifId);
      });
      showSuccessSnackbar(context, 'Notifikasi telah selesai dibaca dan dibersihkan 👍');
    }
  }

  Future<void> _clearAllReadState() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? 'guest';
    await LocalStorage.clearReadNotifications(userId);
    if (mounted) {
      setState(() {
        _readNotifIds.clear();
      });
      showSuccessSnackbar(context, 'Riwayat notifikasi berhasil ditampilkan kembali 🔄');
    }
  }

  Future<void> _markAllVisibleAsRead(List<Map<String, dynamic>> visibleNotifs) async {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? 'guest';
    for (var n in visibleNotifs) {
      final notifId = n['id'] as String;
      await LocalStorage.markNotificationRead(userId, notifId);
      _readNotifIds.add(notifId);
    }
    if (mounted) {
      setState(() {});
      showSuccessSnackbar(context, 'Semua notifikasi telah ditandai selesai dibaca ✨');
    }
  }

  void _showDetailNotifikasiModal(BuildContext context, Map<String, dynamic> item) {
    final color = item['color'] as Color;
    final icon = item['icon'] as IconData;
    final notifId = item['id'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator pill
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StatusBadge(status: item['status']),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Detail Cards
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Tanggal Pemberitahuan', Formatters.tanggalIndo(item['date'])),
                    if (item['kode'] != null) ...[
                      const SizedBox(height: 10),
                      _detailRow('Kode Transaksi', item['kode']),
                    ],
                    if (item['sub_detail'] != null) ...[
                      const SizedBox(height: 10),
                      _detailRow('Informasi Tambahan', item['sub_detail']),
                    ],
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    const Text(
                      'Pesan Lengkap:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['message'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  if (item['raw_id'] != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (item['type'] == 'setor') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NotaSetorScreen(setorId: item['raw_id']),
                              ),
                            );
                          } else if (item['type'] == 'penukaran') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NotaPenukaranScreen(penukaranId: item['raw_id']),
                              ),
                            );
                          } else if (item['type'] == 'admin_setor') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const KonfirmasiSetorScreen(),
                              ),
                            );
                          } else if (item['type'] == 'admin_penukaran') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const KonfirmasiPenukaranScreen(),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.receipt_long_rounded, size: 18),
                        label: const Text('Buka Detail'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _markAsRead(notifId);
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.white),
                      label: const Text('Selesai Dibaca', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filterType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filterType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textGrey,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.currentUser?.isAdmin == true;

    final setorProvider = context.watch<SetorSampahProvider>();
    final penukaranProvider = context.watch<PenukaranPoinProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (Navigator.canPop(context))
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                            ),
                          )
                        else
                          const SizedBox(),
                        if (_readNotifIds.isNotEmpty)
                          TextButton.icon(
                            onPressed: _clearAllReadState,
                            icon: const Icon(Icons.restore_rounded, color: Colors.white, size: 16),
                            label: const Text(
                              'Reset Histori',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pemberitahuan & Notifikasi 🔔',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAdmin
                          ? 'Daftar pengajuan masuk yang membutuhkan konfirmasi admin'
                          : 'Riwayat pemberitahuan status transaksi sampah Anda',
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

          // ── Filter Chips ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                _filterChip('semua', 'Semua Notifikasi'),
                _filterChip('setor', 'Penyetoran'),
                _filterChip('penukaran', 'Penukaran'),
              ],
            ),
          ),

          // ── Notification Content ──────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                if (isAdmin) {
                  await setorProvider.fetchAdminList(status: 'menunggu_konfirmasi');
                  await penukaranProvider.fetchAdminList();
                } else {
                  await setorProvider.fetchMySetor();
                  await penukaranProvider.fetchMyPenukaran();
                }
                await _loadReadNotifications();
              },
              child: _loadingReadIds
                  ? const LoadingView()
                  : (isAdmin
                      ? _buildAdminNotificationList(context, setorProvider, penukaranProvider)
                      : _buildNasabahNotificationList(context, setorProvider, penukaranProvider)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNasabahNotificationList(
    BuildContext context,
    SetorSampahProvider setorProvider,
    PenukaranPoinProvider penukaranProvider,
  ) {
    if (setorProvider.isLoading || penukaranProvider.isLoading) {
      return const LoadingView();
    }

    final allNotifs = <Map<String, dynamic>>[];

    // Add Setoran notifications
    if (_filterType == 'semua' || _filterType == 'setor') {
      for (var s in setorProvider.mySetorList) {
        final notifId = 'setor_${s.id}';
        if (_readNotifIds.contains(notifId)) continue; // Skip read notifications

        final st = s.status.toLowerCase();
        final isDone = st == 'diverifikasi' || st == 'selesai' || st == 'disetujui';
        final isRejected = st == 'ditolak';

        allNotifs.add({
          'id': notifId,
          'type': 'setor',
          'raw_id': s.id,
          'kode': s.kodeSetor,
          'sub_detail': 'Berat: ${s.totalBeratKg} Kg',
          'date': s.tanggal,
          'raw_date': s.createdAt ?? s.tanggal,
          'title': isDone
              ? 'Setoran Disetujui! 🎉'
              : isRejected
                  ? 'Setoran Ditolak ❌'
                  : 'Menunggu Verifikasi ⏳',
          'message': isDone
              ? 'Pengajuan setor ${s.kodeSetor ?? ''} (${s.totalBeratKg} Kg) telah diverifikasi & poin telah ditambahkan.'
              : isRejected
                  ? 'Pengajuan setor ${s.kodeSetor ?? ''} telah ditolak oleh Admin.'
                  : 'Pengajuan setor ${s.kodeSetor ?? ''} (${s.totalBeratKg} Kg) sedang ditinjau oleh Admin.',
          'status': s.status,
          'color': isDone
              ? AppColors.primary
              : isRejected
                  ? AppColors.statusDitolak
                  : AppColors.statusMenunggu,
          'icon': isDone
              ? Icons.check_circle_rounded
              : isRejected
                  ? Icons.cancel_rounded
                  : Icons.hourglass_top_rounded,
        });
      }
    }

    // Add Penukaran notifications
    if (_filterType == 'semua' || _filterType == 'penukaran') {
      for (var p in penukaranProvider.myPenukaranList) {
        final notifId = 'tukar_${p.id}';
        if (_readNotifIds.contains(notifId)) continue; // Skip read notifications

        final st = p.status.toLowerCase();
        final isDone = st == 'selesai' || st == 'disetujui';
        final isRejected = st == 'ditolak';

        allNotifs.add({
          'id': notifId,
          'type': 'penukaran',
          'raw_id': p.id,
          'kode': p.kodePenukaran,
          'sub_detail': 'Hadiah: ${p.namaHadiah ?? '-'} (${p.poinTerpakai} Poin)',
          'date': p.tanggal,
          'raw_date': p.createdAt ?? p.tanggal,
          'title': isDone
              ? 'Penukaran Hadiah Disetujui! 🎁'
              : isRejected
                  ? 'Penukaran Hadiah Ditolak ❌'
                  : 'Penukaran Poin Diproses ⏳',
          'message': isDone
              ? 'Penukaran poin untuk hadiah "${p.namaHadiah ?? 'Hadiah'}" (${p.poinTerpakai} Poin) telah berhasil disetujui.'
              : isRejected
                  ? 'Penukaran poin untuk "${p.namaHadiah ?? 'Hadiah'}" ditolak oleh Admin.'
                  : 'Penukaran poin untuk "${p.namaHadiah ?? 'Hadiah'}" sedang diproses Admin.',
          'status': p.status,
          'color': isDone
              ? const Color(0xFF8B5CF6)
              : isRejected
                  ? AppColors.statusDitolak
                  : const Color(0xFFF59E0B),
          'icon': isDone
              ? Icons.card_giftcard_rounded
              : isRejected
                  ? Icons.cancel_rounded
                  : Icons.pending_actions_rounded,
        });
      }
    }

    // Sort notifications by timestamp descending so latest penukaran & setoran appear on top
    allNotifs.sort((a, b) {
      final dateA = DateTime.tryParse(a['raw_date']?.toString() ?? a['date']?.toString() ?? '') ?? DateTime(1970);
      final dateB = DateTime.tryParse(b['raw_date']?.toString() ?? b['date']?.toString() ?? '') ?? DateTime(1970);
      final cmp = dateB.compareTo(dateA);
      if (cmp != 0) return cmp;

      // Priority for in-progress / pending items if date string is identical
      final statusA = (a['status']?.toString() ?? '').toLowerCase();
      final statusB = (b['status']?.toString() ?? '').toLowerCase();
      final isPendingA = statusA.contains('menunggu') || statusA.contains('proses');
      final isPendingB = statusB.contains('menunggu') || statusB.contains('proses');

      if (isPendingB && !isPendingA) return 1;
      if (isPendingA && !isPendingB) return -1;

      return (b['id']?.toString() ?? '').compareTo(a['id']?.toString() ?? '');
    });

    if (allNotifs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Semua Notifikasi Selesai Dibaca!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Tidak ada notifikasi baru. Notifikasi yang telah dibaca akan disembunyikan secara otomatis.',
                style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
                textAlign: TextAlign.center,
              ),
              if (_readNotifIds.isNotEmpty) ...[
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _clearAllReadState,
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('Tampilkan Riwayat Notifikasi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Belum dibaca (${allNotifs.length})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey),
              ),
              GestureDetector(
                onTap: () => _markAllVisibleAsRead(allNotifs),
                child: const Text(
                  'Tandai Semua Dibaca',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: allNotifs.length,
            itemBuilder: (context, i) {
              final item = allNotifs[i];
              final color = item['color'] as Color;
              final icon = item['icon'] as IconData;

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
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: InkWell(
                  onTap: () => _showDetailNotifikasiModal(context, item),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: color,
                                    ),
                                  ),
                                  StatusBadge(status: item['status']),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['message'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Formatters.tanggalIndo(item['date']),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Baca Lebih Lanjut',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdminNotificationList(
    BuildContext context,
    SetorSampahProvider setorProvider,
    PenukaranPoinProvider penukaranProvider,
  ) {
    if (setorProvider.isLoading || penukaranProvider.isLoading) {
      return const LoadingView();
    }

    final adminNotifs = <Map<String, dynamic>>[];

    // Add pending Setoran
    if (_filterType == 'semua' || _filterType == 'setor') {
      for (var s in setorProvider.adminSetorList) {
        if (!s.status.toLowerCase().contains('menunggu')) continue;
        final notifId = 'admin_setor_${s.id}';
        if (_readNotifIds.contains(notifId)) continue;

        adminNotifs.add({
          'id': notifId,
          'type': 'admin_setor',
          'raw_id': s.id,
          'kode': s.kodeSetor,
          'sub_detail': 'Nasabah: ${s.namaNasabah ?? '-'}',
          'date': s.tanggal,
          'raw_date': s.createdAt ?? s.tanggal,
          'title': 'Konfirmasi Penyetoran 📦',
          'message': 'Pengajuan setor sampah ${s.kodeSetor ?? ''} sebesar ${s.totalBeratKg} Kg dari ${s.namaNasabah ?? 'Nasabah'} membutuhkan konfirmasi Anda.',
          'status': 'Menunggu',
          'color': AppColors.primary,
          'icon': Icons.fact_check_rounded,
        });
      }
    }

    // Add pending Penukaran
    if (_filterType == 'semua' || _filterType == 'penukaran') {
      for (var p in penukaranProvider.adminPenukaranList) {
        final st = p.status.toLowerCase();
        if (st == 'selesai' || st == 'ditolak') continue;
        final notifId = 'admin_tukar_${p.id}';
        if (_readNotifIds.contains(notifId)) continue;

        adminNotifs.add({
          'id': notifId,
          'type': 'admin_penukaran',
          'raw_id': p.id,
          'kode': p.kodePenukaran,
          'sub_detail': 'Hadiah: ${p.namaHadiah ?? '-'} (${p.poinTerpakai} Poin)',
          'date': p.tanggal,
          'raw_date': p.createdAt ?? p.tanggal,
          'title': 'Konfirmasi Penukaran Hadiah 🎁',
          'message': 'Pengajuan penukaran poin untuk "${p.namaHadiah ?? 'Hadiah'}" (${p.poinTerpakai} Poin) oleh ${p.namaNasabah ?? 'Nasabah'} membutuhkan persetujuan Admin.',
          'status': p.status,
          'color': const Color(0xFFD97706),
          'icon': Icons.confirmation_number_rounded,
        });
      }
    }

    // Sort admin notifications by timestamp descending
    adminNotifs.sort((a, b) {
      final dateA = DateTime.tryParse(a['raw_date']?.toString() ?? a['date']?.toString() ?? '') ?? DateTime(1970);
      final dateB = DateTime.tryParse(b['raw_date']?.toString() ?? b['date']?.toString() ?? '') ?? DateTime(1970);
      final cmp = dateB.compareTo(dateA);
      if (cmp != 0) return cmp;

      // Priority for in-progress / pending items if date string is identical
      final statusA = (a['status']?.toString() ?? '').toLowerCase();
      final statusB = (b['status']?.toString() ?? '').toLowerCase();
      final isPendingA = statusA.contains('menunggu') || statusA.contains('proses');
      final isPendingB = statusB.contains('menunggu') || statusB.contains('proses');

      if (isPendingB && !isPendingA) return 1;
      if (isPendingA && !isPendingB) return -1;

      return (b['id']?.toString() ?? '').compareTo(a['id']?.toString() ?? '');
    });

    if (adminNotifs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Semua Pengajuan Selesai Dibaca!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Tidak ada pengajuan baru yang menunggu tindakan. Semua pemberitahuan telah dibaca.',
                style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
                textAlign: TextAlign.center,
              ),
              if (_readNotifIds.isNotEmpty) ...[
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _clearAllReadState,
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('Tampilkan Riwayat Notifikasi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengajuan Baru (${adminNotifs.length})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey),
              ),
              GestureDetector(
                onTap: () => _markAllVisibleAsRead(adminNotifs),
                child: const Text(
                  'Tandai Semua Dibaca',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: adminNotifs.length,
            itemBuilder: (context, i) {
              final item = adminNotifs[i];
              final color = item['color'] as Color;
              final icon = item['icon'] as IconData;

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
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: InkWell(
                  onTap: () => _showDetailNotifikasiModal(context, item),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: color,
                                    ),
                                  ),
                                  StatusBadge(status: item['status']),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['message'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Formatters.tanggalIndo(item['date']),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Baca Lebih Lanjut',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_rounded, size: 12, color: color),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
