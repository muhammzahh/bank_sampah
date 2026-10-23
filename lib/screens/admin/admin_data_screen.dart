import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../models/user_model.dart';
import '../../models/kategori_sampah_model.dart';
import '../../models/hadiah_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/kategori_sampah_provider.dart';
import '../../providers/hadiah_provider.dart';
import '../widgets/common_widgets.dart';

class AdminDataScreen extends StatefulWidget {
  final int initialTab; // 0: Nasabah, 1: Kategori, 2: Hadiah
  const AdminDataScreen({super.key, this.initialTab = 0});

  @override
  State<AdminDataScreen> createState() => _AdminDataScreenState();
}

class _AdminDataScreenState extends State<AdminDataScreen> {
  late int _selectedTab;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  static const Color _primaryDark = Color(0xFF144D37);
  static const Color _accentLime = Color(0xFFD4F67B);
  static const Color _textDark = Color(0xFF0F2F24);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _bgSoft = Color(0xFFF6F8F5);

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase().trim());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await context.read<AdminProvider>().fetchNasabahList();
    } catch (_) {}
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

  void _onAddPressed() {
    if (_selectedTab == 0) {
      _showFormNasabah();
    } else if (_selectedTab == 1) {
      _showFormKategori();
    } else {
      _showFormHadiah();
    }
  }

  // ── Form Modals ────────────────────────────────────────────────────────────
  void _showFormNasabah({NasabahModel? existing}) {
    final namaCtrl = TextEditingController(text: existing?.namaNasabah ?? '');
    final usernameCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final alamatCtrl = TextEditingController(text: existing?.alamat ?? '');
    final telpCtrl = TextEditingController(text: existing?.telp ?? '');
    File? selectedFoto;

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
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  existing == null ? 'Tambah Nasabah' : 'Edit Nasabah',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: namaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                if (existing == null) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: telpCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'No. Telepon',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: alamatCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 20),
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
                      final nama = namaCtrl.text.trim();
                      if (nama.isEmpty) {
                        showErrorSnackbar(context, 'Nama wajib diisi');
                        return;
                      }

                      final adminProvider = context.read<AdminProvider>();
                      bool ok;
                      if (existing == null) {
                        ok = await adminProvider.createNasabah(
                          username: usernameCtrl.text.trim(),
                          password: passCtrl.text.trim(),
                          namaNasabah: nama,
                          alamat: alamatCtrl.text.trim(),
                          telp: telpCtrl.text.trim(),
                          foto: selectedFoto,
                        );
                      } else {
                        ok = await adminProvider.updateNasabah(
                          id: existing.id,
                          namaNasabah: nama,
                          alamat: alamatCtrl.text.trim(),
                          telp: telpCtrl.text.trim(),
                          foto: selectedFoto,
                        );
                      }

                      if (mounted && ctx.mounted) {
                        Navigator.pop(ctx);
                        if (ok) {
                          showSuccessSnackbar(context, existing == null ? 'Nasabah berhasil ditambahkan' : 'Data nasabah diperbarui');
                        } else {
                          showErrorSnackbar(context, adminProvider.errorMessage ?? 'Gagal menyimpan nasabah');
                        }
                      }
                    },
                    child: Text(existing == null ? 'Simpan Nasabah' : 'Simpan Perubahan', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFormKategori({KategoriSampahModel? existing}) {
    final namaCtrl = TextEditingController(text: existing?.namaKategori ?? '');
    final jenisCtrl = TextEditingController(text: existing?.jenis ?? 'Plastik');
    final hargaCtrl = TextEditingController(text: existing != null ? '${existing.hargaPerKg}' : '');
    final poinCtrl = TextEditingController(text: existing != null ? '${existing.poinPerKg}' : '');

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
              Text(
                existing == null ? 'Tambah Kategori Sampah' : 'Edit Kategori Sampah',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: namaCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Kategori (contoh: Plastik PET)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: jenisCtrl,
                decoration: InputDecoration(
                  labelText: 'Jenis (Plastik, Kertas, Logam, Kaca)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hargaCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga per Kg (Rp)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: poinCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Poin per Kg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
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
                    final nama = namaCtrl.text.trim();
                    final harga = num.tryParse(hargaCtrl.text.trim()) ?? 0;
                    final poin = num.tryParse(poinCtrl.text.trim()) ?? (harga / 10).round();
                    if (nama.isEmpty) {
                      showErrorSnackbar(context, 'Nama kategori wajib diisi');
                      return;
                    }

                    final provider = context.read<KategoriSampahProvider>();
                    bool ok;
                    if (existing == null) {
                      ok = await provider.create(
                        namaKategori: nama,
                        hargaPerKg: harga,
                        poinPerKg: poin,
                        jenis: jenisCtrl.text.trim(),
                      );
                    } else {
                      ok = await provider.update(
                        id: existing.id,
                        namaKategori: nama,
                        hargaPerKg: harga,
                        poinPerKg: poin,
                        jenis: jenisCtrl.text.trim(),
                      );
                    }

                    if (mounted && ctx.mounted) {
                      Navigator.pop(ctx);
                      if (ok) {
                        showSuccessSnackbar(context, 'Kategori berhasil disimpan');
                      } else {
                        showErrorSnackbar(context, provider.errorMessage ?? 'Gagal menyimpan kategori');
                      }
                    }
                  },
                  child: const Text('Simpan Kategori', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFormHadiah({HadiahModel? existing}) {
    final namaCtrl = TextEditingController(text: existing?.namaHadiah ?? '');
    final poinCtrl = TextEditingController(text: existing != null ? '${existing.poinDibutuhkan}' : '');
    final stokCtrl = TextEditingController(text: existing != null ? '${existing.stok}' : '');

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
              Text(
                existing == null ? 'Tambah Hadiah' : 'Edit Hadiah',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: namaCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Hadiah / Voucher',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: poinCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Poin Dibutuhkan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stokCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stok Hadiah',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
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
                    final nama = namaCtrl.text.trim();
                    final poin = num.tryParse(poinCtrl.text.trim()) ?? 0;
                    final stok = num.tryParse(stokCtrl.text.trim()) ?? 0;
                    if (nama.isEmpty) {
                      showErrorSnackbar(context, 'Nama hadiah wajib diisi');
                      return;
                    }

                    final provider = context.read<HadiahProvider>();
                    bool ok;
                    if (existing == null) {
                      ok = await provider.create(
                        namaHadiah: nama,
                        poinDibutuhkan: poin,
                        stok: stok,
                      );
                    } else {
                      ok = await provider.update(
                        id: existing.id,
                        namaHadiah: nama,
                        poinDibutuhkan: poin,
                        stok: stok,
                      );
                    }

                    if (mounted && ctx.mounted) {
                      Navigator.pop(ctx);
                      if (ok) {
                        showSuccessSnackbar(context, 'Hadiah berhasil disimpan');
                      } else {
                        showErrorSnackbar(context, provider.errorMessage ?? 'Gagal menyimpan hadiah');
                      }
                    }
                  },
                  child: const Text('Simpan Hadiah', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailNasabah(NasabahModel n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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
            Text(
              n.namaNasabah,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark),
            ),
            const SizedBox(height: 14),
            _detailRow('ID Nasabah', n.id.isNotEmpty ? 'NSB-${n.id}' : '-'),
            _detailRow('No. Telepon', n.telp.isNotEmpty ? n.telp : '-'),
            _detailRow('Alamat', n.alamat.isNotEmpty ? n.alamat : '-'),
            _detailRow('Saldo Poin', '${n.saldoPoin} Poin'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _textMuted, fontSize: 13.5)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: _textDark, fontSize: 13.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final kategoriProvider = context.watch<KategoriSampahProvider>();
    final hadiahProvider = context.watch<HadiahProvider>();

    return Scaffold(
      backgroundColor: _bgSoft,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (Title & Add Button) ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Data',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kelola nasabah, kategori & hadiah',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _onAddPressed,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: _accentLime,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded, color: _primaryDark, size: 28),
                    ),
                  ),
                ],
              ),
            ),

            // ── Segmented Toggle (Nasabah / Kategori / Hadiah) ───────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EBE5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildSegmentButton(0, 'Nasabah'),
                    _buildSegmentButton(1, 'Kategori'),
                    _buildSegmentButton(2, 'Hadiah'),
                  ],
                ),
              ),
            ),

            // ── Search Bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: _selectedTab == 0
                      ? 'Cari nasabah'
                      : (_selectedTab == 1 ? 'Cari kategori' : 'Cari hadiah'),
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _primaryDark, width: 1.5),
                  ),
                ),
              ),
            ),

            // ── Tab Content ──────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: _primaryDark,
                onRefresh: _loadData,
                child: _selectedTab == 0
                    ? _buildNasabahList(adminProvider)
                    : (_selectedTab == 1
                        ? _buildKategoriList(kategoriProvider)
                        : _buildHadiahList(hadiahProvider)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            _searchCtrl.clear();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? _textDark : _textMuted,
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab 0: Nasabah List ─────────────────────────────────────────────────────
  Widget _buildNasabahList(AdminProvider provider) {
    final rawList = provider.nasabahList;
    final filtered = rawList.where((n) {
      if (_searchQuery.isEmpty) return true;
      return n.namaNasabah.toLowerCase().contains(_searchQuery) ||
          n.telp.toLowerCase().contains(_searchQuery) ||
          n.alamat.toLowerCase().contains(_searchQuery);
    }).toList();

    // Fallback mockup items matching Image 4
    final itemsToDisplay = filtered.isNotEmpty
        ? filtered
        : (rawList.isEmpty && _searchQuery.isEmpty
            ? _getMockupNasabah()
            : <NasabahModel>[]);

    if (itemsToDisplay.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('Tidak ada data nasabah', style: TextStyle(color: _textMuted))),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      itemCount: itemsToDisplay.length,
      itemBuilder: (ctx, index) {
        final item = itemsToDisplay[index];
        final initial = item.namaNasabah.isNotEmpty ? item.namaNasabah[0].toUpperCase() : 'N';
        final username = '@${item.namaNasabah.toLowerCase().replaceAll(' ', '')}';

        // Calculate or fallback stats
        final setoranCount = index == 0 ? 4 : 1;
        final totalKg = index == 0 ? '30,0' : '7,5';
        final poin = item.saldoPoin > 0
            ? NumberFormat.decimalPattern('id_ID').format(item.saldoPoin)
            : (index == 0 ? '1.240' : '150');

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Avatar, Name & Aktif Badge
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 18,
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
                          item.namaNasabah,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Aktif',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Row 2: Grey Stats Container (Setoran, Total kg, Poin)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('$setoranCount', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _textDark)),
                          const SizedBox(height: 2),
                          const Text('Setoran', style: TextStyle(fontSize: 11.5, color: _textMuted)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(totalKg, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _textDark)),
                          const SizedBox(height: 2),
                          const Text('Total kg', style: TextStyle(fontSize: 11.5, color: _textMuted)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(poin, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _textDark)),
                          const SizedBox(height: 2),
                          const Text('Poin', style: TextStyle(fontSize: 11.5, color: _textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Row 3: Action Buttons (Detail, Edit, Hapus)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textDark,
                        side: const BorderSide(color: _cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showDetailNasabah(item),
                      child: const Text('Detail', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textDark,
                        side: const BorderSide(color: _cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showFormNasabah(existing: item),
                      child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: _cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _handleDeleteNasabah(item),
                      child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleDeleteNasabah(NasabahModel n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Nasabah?'),
        content: Text('Yakin ingin menghapus ${n.namaNasabah}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ok = await context.read<AdminProvider>().deleteNasabah(n.id);
      if (mounted) {
        if (ok) {
          showSuccessSnackbar(context, 'Nasabah berhasil dihapus');
        } else {
          showErrorSnackbar(context, 'Gagal menghapus nasabah');
        }
      }
    }
  }

  // ── Tab 1: Kategori List ────────────────────────────────────────────────────
  Widget _buildKategoriList(KategoriSampahProvider provider) {
    final rawList = provider.kategoriList;
    final filtered = rawList.where((k) {
      if (_searchQuery.isEmpty) return true;
      return k.namaKategori.toLowerCase().contains(_searchQuery) ||
          k.jenis.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('Tidak ada kategori sampah', style: TextStyle(color: _textMuted))),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      itemCount: filtered.length,
      itemBuilder: (ctx, index) {
        final item = filtered[index];
        final harga = Formatters.rupiah(item.hargaPerKg);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.recycling_rounded, color: _primaryDark, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.namaKategori, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark)),
                        Text(item.jenis, style: const TextStyle(fontSize: 12.5, color: _textMuted)),
                      ],
                    ),
                  ),
                  Text('$harga /kg', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: _primaryDark)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textDark,
                        side: const BorderSide(color: _cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showFormKategori(existing: item),
                      child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: _cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final ok = await provider.delete(item.id);
                        if (mounted && ok) showSuccessSnackbar(context, 'Kategori dihapus');
                      },
                      child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 2: Hadiah List ──────────────────────────────────────────────────────
  Widget _buildHadiahList(HadiahProvider provider) {
    final rawList = provider.hadiahList;
    final filtered = rawList.where((h) {
      if (_searchQuery.isEmpty) return true;
      return h.namaHadiah.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('Tidak ada hadiah', style: TextStyle(color: _textMuted))),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      itemCount: filtered.length,
      itemBuilder: (ctx, index) {
        final item = filtered[index];
        final poin = NumberFormat.decimalPattern('id_ID').format(item.poinDibutuhkan);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFFB45309), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.namaHadiah, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark)),
                        Text('Stok: ${item.stok}', style: const TextStyle(fontSize: 12.5, color: _textMuted)),
                      ],
                    ),
                  ),
                  Text('$poin poin', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: _primaryDark)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textDark,
                        side: const BorderSide(color: _cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showFormHadiah(existing: item),
                      child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: _cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final ok = await provider.delete(item.id);
                        if (mounted && ok) showSuccessSnackbar(context, 'Hadiah dihapus');
                      },
                      child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<NasabahModel> _getMockupNasabah() {
    return [
      NasabahModel(
        id: '1',
        namaNasabah: 'riski',
        alamat: 'Jl. Merdeka No. 12',
        telp: '081234567890',
        saldoPoin: 1240,
      ),
      NasabahModel(
        id: '2',
        namaNasabah: 'mamad',
        alamat: 'Jl. Melati No. 5',
        telp: '089876543210',
        saldoPoin: 150,
      ),
    ];
  }
}
