import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../models/kategori_sampah_model.dart';
import '../../models/setor_sampah_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kategori_sampah_provider.dart';
import '../../providers/setor_sampah_provider.dart';
import '../widgets/common_widgets.dart';
import 'status_setor_screen.dart';

class KategoriOptionItem {
  final String name;
  final IconData icon;
  final String keyword;
  final num defaultPrice;

  const KategoriOptionItem({
    required this.name,
    required this.icon,
    required this.keyword,
    required this.defaultPrice,
  });
}

class ScheduleDayItem {
  final String day;
  final String date;
  final DateTime fullDate;

  const ScheduleDayItem({
    required this.day,
    required this.date,
    required this.fullDate,
  });
}

class AjukanSetorScreen extends StatefulWidget {
  final bool isTab;
  final KategoriSampahModel? initialKategori;
  final VoidCallback? onBack;

  const AjukanSetorScreen({
    super.key,
    this.isTab = false,
    this.initialKategori,
    this.onBack,
  });

  @override
  State<AjukanSetorScreen> createState() => _AjukanSetorScreenState();
}

class _AjukanSetorScreenState extends State<AjukanSetorScreen> {
  static const Color _bgColor = Color(0xFFF6F8F5);
  static const Color _primaryDark = Color(0xFF144D37);
  static const Color _lime = Color(0xFFD4F67B);
  static const Color _textDark = Color(0xFF0F2F24);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE5E7EB);

  static const List<KategoriOptionItem> defaultKategoriOptions = [
    KategoriOptionItem(
      name: 'Plastik',
      icon: Icons.liquor_outlined,
      keyword: 'plastik',
      defaultPrice: 3200,
    ),
    KategoriOptionItem(
      name: 'Kardus',
      icon: Icons.inventory_2_outlined,
      keyword: 'kardus',
      defaultPrice: 1800,
    ),
    KategoriOptionItem(
      name: 'Kertas',
      icon: Icons.description_outlined,
      keyword: 'kertas',
      defaultPrice: 1500,
    ),
    KategoriOptionItem(
      name: 'Kaleng',
      icon: Icons.smart_screen_outlined,
      keyword: 'kaleng',
      defaultPrice: 4500,
    ),
    KategoriOptionItem(
      name: 'Kaca',
      icon: Icons.wine_bar_outlined,
      keyword: 'kaca',
      defaultPrice: 1200,
    ),
    KategoriOptionItem(
      name: 'Lainnya',
      icon: Icons.more_horiz_rounded,
      keyword: 'lainnya',
      defaultPrice: 2000,
    ),
  ];

  static const List<String> timeSlots = ['08.00–10.00', '13.00–15.00'];

  static const List<String> daysMap = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min'
  ];

  static const List<String> monthsMap = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];

  bool _isJemput = true;
  int _selectedCategoryIndex = 0;
  double _beratKg = 4.5;
  int _selectedDateIndex = 0;
  int _selectedSlotIndex = 0;
  String? _customAlamat;
  bool _isSubmitting = false;

  late final TextEditingController _beratCtrl;
  late final FocusNode _beratFocusNode;

  String _formatBerat(double val) {
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1).replaceAll('.', ',');
  }

  void _syncBeratCtrl() {
    _beratCtrl.text = _formatBerat(_beratKg);
  }

  void _decrementBerat() {
    if (_beratKg > 0.5) {
      setState(() {
        _beratKg = ((_beratKg - 0.5) * 10).round() / 10;
        _syncBeratCtrl();
      });
    }
  }

  void _incrementBerat() {
    setState(() {
      _beratKg = ((_beratKg + 0.5) * 10).round() / 10;
      _syncBeratCtrl();
    });
  }

  void _onBeratChanged(String value) {
    final clean = value.replaceAll(',', '.').trim();
    final parsed = double.tryParse(clean);
    if (parsed != null && parsed > 0) {
      setState(() {
        _beratKg = parsed;
      });
    }
  }

  void _onBeratBlur() {
    final clean = _beratCtrl.text.replaceAll(',', '.').trim();
    final parsed = double.tryParse(clean);
    if (parsed == null || parsed <= 0) {
      setState(() {
        _beratKg = 1.0;
        _syncBeratCtrl();
      });
    } else {
      setState(() {
        _beratKg = (parsed * 10).round() / 10;
        _syncBeratCtrl();
      });
    }
  }

  void _showEditBeratDialog() {
    final tempCtrl = TextEditingController(text: _formatBerat(_beratKg));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
            const SizedBox(height: 18),
            const Text(
              'Masukkan Perkiraan Berat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ketik berat sampah dalam satuan kilogram (kg)',
              style: TextStyle(fontSize: 13, color: _textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tempCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
              decoration: InputDecoration(
                suffixText: 'kg',
                suffixStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textMuted,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _primaryDark, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Quick preset chips
            Wrap(
              spacing: 8,
              children: [1.0, 2.0, 5.0, 10.0, 20.0].map((preset) {
                return ActionChip(
                  label: Text('${preset.toStringAsFixed(0)} kg'),
                  backgroundColor: const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onPressed: () {
                    tempCtrl.text = preset.toStringAsFixed(0);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  final clean = tempCtrl.text.replaceAll(',', '.').trim();
                  final parsed = double.tryParse(clean);
                  if (parsed != null && parsed > 0) {
                    setState(() {
                      _beratKg = (parsed * 10).round() / 10;
                      _syncBeratCtrl();
                    });
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan Berat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _safeCategoryIndex {
    if (_selectedCategoryIndex < 0 ||
        _selectedCategoryIndex >= defaultKategoriOptions.length) {
      return 0;
    }
    return _selectedCategoryIndex;
  }

  int get _safeDateIndex {
    if (_selectedDateIndex < 0 || _selectedDateIndex >= 3) {
      return 0;
    }
    return _selectedDateIndex;
  }

  int get _safeSlotIndex {
    if (_selectedSlotIndex < 0 || _selectedSlotIndex >= timeSlots.length) {
      return 0;
    }
    return _selectedSlotIndex;
  }

  @override
  void initState() {
    super.initState();
    _beratCtrl = TextEditingController(text: _formatBerat(_beratKg));
    _beratFocusNode = FocusNode();
    _beratFocusNode.addListener(() {
      if (!_beratFocusNode.hasFocus) {
        _onBeratBlur();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final katProv = context.read<KategoriSampahProvider>();
      if (katProv.kategoriList.isEmpty) {
        await katProv.fetchAll();
      }
      if (!mounted) return;
      if (widget.initialKategori != null) {
        _applyInitialKategori(widget.initialKategori!);
      }
    });
  }

  @override
  void dispose() {
    _beratCtrl.dispose();
    _beratFocusNode.dispose();
    super.dispose();
  }

  void _applyInitialKategori(KategoriSampahModel k) {
    final lowerName = '${k.namaKategori} ${k.jenis}'.toLowerCase();
    for (int i = 0; i < defaultKategoriOptions.length; i++) {
      final kw = defaultKategoriOptions[i].keyword.toLowerCase();
      if (lowerName.contains(kw)) {
        setState(() => _selectedCategoryIndex = i);
        return;
      }
    }
    setState(() => _selectedCategoryIndex = 5); // default Lainnya
  }

  List<ScheduleDayItem> _getScheduleDays() {
    final now = DateTime.now();
    return List.generate(3, (i) {
      final date = now.add(Duration(days: i + 1));
      final weekdayIndex = (date.weekday - 1).clamp(0, daysMap.length - 1);
      final monthIndex = (date.month - 1).clamp(0, monthsMap.length - 1);
      return ScheduleDayItem(
        day: daysMap[weekdayIndex],
        date: '${date.day} ${monthsMap[monthIndex]}',
        fullDate: date,
      );
    });
  }

  KategoriSampahModel? _findMatchingKategori(
      int index, List<KategoriSampahModel> kategoriList) {
    if (kategoriList.isEmpty) return null;
    final safeIdx =
        index.clamp(0, defaultKategoriOptions.length - 1);
    final keyword = defaultKategoriOptions[safeIdx].keyword.toLowerCase();

    for (final k in kategoriList) {
      final name = k.namaKategori.toLowerCase();
      final jenis = k.jenis.toLowerCase();
      if (name.contains(keyword) || jenis.contains(keyword)) {
        return k;
      }
    }

    if (safeIdx == 5) {
      final others = kategoriList.where((k) {
        final n = k.namaKategori.toLowerCase();
        final j = k.jenis.toLowerCase();
        return !n.contains('plastik') &&
            !n.contains('kardus') &&
            !n.contains('kertas') &&
            !n.contains('kaleng') &&
            !n.contains('logam') &&
            !n.contains('kaca') &&
            !j.contains('plastik') &&
            !j.contains('kertas') &&
            !j.contains('logam') &&
            !j.contains('kaca');
      }).toList();
      if (others.isNotEmpty) return others.first;
    }

    return kategoriList.isNotEmpty ? kategoriList.first : null;
  }

  num _getPricePerKg(int index, List<KategoriSampahModel> kategoriList) {
    final safeIdx =
        index.clamp(0, defaultKategoriOptions.length - 1);
    final k = _findMatchingKategori(safeIdx, kategoriList);
    if (k != null) {
      if (k.hargaPerKg > 0) return k.hargaPerKg;
      if (k.poinPerKg > 0) return k.poinPerKg * 1000;
    }
    return defaultKategoriOptions[safeIdx].defaultPrice;
  }

  num _getEstimasiNilai(List<KategoriSampahModel> kategoriList) {
    final price = _getPricePerKg(_safeCategoryIndex, kategoriList);
    return (_beratKg * price).round();
  }

  String _getAlamat(AuthProvider auth) {
    if (_customAlamat != null && _customAlamat!.trim().isNotEmpty) {
      return _customAlamat!.trim();
    }
    final nasabahAlamat = auth.currentUser?.nasabah?.alamat;
    if (nasabahAlamat != null && nasabahAlamat.trim().isNotEmpty) {
      return nasabahAlamat.trim();
    }
    return 'Jl. Melati No. 12, RT 03/RW 05';
  }

  void _showEditAlamatSheet() {
    final auth = context.read<AuthProvider>();
    final current = _getAlamat(auth);
    final controller = TextEditingController(text: current);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
              'Ubah Alamat Jemput',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 2,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat penjemputan lengkap...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primaryDark, width: 1.5),
                ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    setState(() => _customAlamat = text);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Gunakan Alamat Ini',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSetor() async {
    if (_isSubmitting) return;

    final katProv = context.read<KategoriSampahProvider>();
    if (katProv.kategoriList.isEmpty) {
      await katProv.fetchAll();
      if (!mounted) return;
    }

    final selectedKategori =
        _findMatchingKategori(_safeCategoryIndex, katProv.kategoriList);
    final kategoriId = selectedKategori?.id ??
        (katProv.kategoriList.isNotEmpty ? katProv.kategoriList.first.id : null);

    if (kategoriId == null) {
      showErrorSnackbar(context, 'Kategori sampah belum tersedia di server');
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final setorProvider = context.read<SetorSampahProvider>();

    final scheduleDays = _getScheduleDays();
    final selectedDay = scheduleDays[_safeDateIndex];
    final selectedSlot = timeSlots[_safeSlotIndex];
    final alamat = _getAlamat(auth);
    final estimasi = _getEstimasiNilai(katProv.kategoriList);
    final kategoriName = defaultKategoriOptions[_safeCategoryIndex].name;

    final tanggalSchedule =
        selectedDay.fullDate.toUtc().toIso8601String();
    final catatan = _isJemput
        ? '[Jemput: ${selectedDay.day} ${selectedDay.date}, $selectedSlot] Alamat: $alamat'
        : '[Antar Sendiri: ${selectedDay.day} ${selectedDay.date}, $selectedSlot]';

    setorProvider.clearCart();
    setorProvider.addToCart(
      ItemSetorInput(kategoriSampahId: kategoriId, beratKg: _beratKg),
    );

    final success = await setorProvider.ajukanSetor(
      tanggal: tanggalSchedule,
      catatan: catatan,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      setorProvider.fetchMySetor();
      _showSuccessDialog(
        kategoriName: kategoriName,
        beratKg: _beratKg,
        estimasi: estimasi,
        jadwal: '${selectedDay.day} ${selectedDay.date} ($selectedSlot)',
        isJemput: _isJemput,
        alamat: alamat,
      );
    } else {
      showErrorSnackbar(
        context,
        setorProvider.errorMessage ?? 'Gagal mengajukan penyetoran',
      );
    }
  }

  void _showSuccessDialog({
    required String kategoriName,
    required double beratKg,
    required num estimasi,
    required String jadwal,
    required bool isJemput,
    required String alamat,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 20),
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: _primaryDark,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isJemput
                  ? 'Pengajuan Jemputan Berhasil!'
                  : 'Setor Sampah Berhasil Diajukan!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Petugas akan memverifikasi pengajuanmu. Pastikan sampah siap pada jadwal yang ditentukan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Jenis sampah', kategoriName),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Perkiraan berat',
                      '${beratKg.toStringAsFixed(1).replaceAll('.', ',')} kg'),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                      'Estimasi nilai', Formatters.rupiah(estimasi),
                      isHighlight: true),
                  const Divider(height: 20, color: _borderColor),
                  _buildSummaryRow('Jadwal', jadwal),
                  if (isJemput) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow('Alamat jemput', alamat),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryDark,
                      side: const BorderSide(color: _primaryDark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const StatusSetorScreen()),
                      );
                    },
                    child: const Text(
                      'Riwayat Setor',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Selesai',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: _textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: isHighlight ? 15 : 13,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
              color: isHighlight ? _primaryDark : _textDark,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    if (widget.isTab) {
      return Container(
        color: _bgColor,
        child: content,
      );
    }
    return Scaffold(
      backgroundColor: _bgColor,
      body: content,
    );
  }

  Widget _buildContent() {
    final auth = context.watch<AuthProvider>();
    final katProv = context.watch<KategoriSampahProvider>();
    final scheduleDays = _getScheduleDays();
    final estimasiNilai = _getEstimasiNilai(katProv.kategoriList);
    final currentAlamat = _getAlamat(auth);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ── Scrollable Form Section ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header (Back Button & Title) ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.onBack != null) {
                              widget.onBack!();
                            } else if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: _borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: _textDark,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Setor sampah',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Mode Switcher (Dijemput vs Antar Sendiri) ────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EDE7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isJemput = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _isJemput
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _isJemput
                                      ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Dijemput',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _isJemput
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _isJemput
                                        ? _primaryDark
                                        : const Color(0xFF5A6B63),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isJemput = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: !_isJemput
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: !_isJemput
                                      ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Antar sendiri',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: !_isJemput
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: !_isJemput
                                        ? _primaryDark
                                        : const Color(0xFF5A6B63),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Section: Jenis Sampah (2x3 Grid) ────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jenis sampah',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: defaultKategoriOptions.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.12,
                          ),
                          itemBuilder: (context, index) {
                            final isSelected = _safeCategoryIndex == index;
                            final opt = defaultKategoriOptions[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedCategoryIndex = index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: isSelected ? _primaryDark : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? _primaryDark
                                        : _borderColor,
                                    width: 1.2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: _primaryDark
                                                .withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.02),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      opt.icon,
                                      size: 28,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF1F2937),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      opt.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // ── Section: Perkiraan Berat ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Perkiraan berat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: _borderColor, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Minus Button
                              GestureDetector(
                                onTap: _decrementBerat,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: _borderColor, width: 1.2),
                                  ),
                                  child: const Icon(
                                    Icons.remove_rounded,
                                    color: Color(0xFF1F2937),
                                    size: 24,
                                  ),
                                ),
                              ),

                              // Weight Display & Direct Editor
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _beratFocusNode.requestFocus();
                                    _beratCtrl.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset: _beratCtrl.text.length,
                                    );
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      IntrinsicWidth(
                                        child: TextField(
                                          controller: _beratCtrl,
                                          focusNode: _beratFocusNode,
                                          keyboardType: const TextInputType.numberWithOptions(
                                              decimal: true),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: _textDark,
                                            letterSpacing: -0.5,
                                          ),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal: 2, vertical: 0),
                                            border: InputBorder.none,
                                          ),
                                          onChanged: _onBeratChanged,
                                          onSubmitted: (_) {
                                            _beratFocusNode.unfocus();
                                            _onBeratBlur();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'kg',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _textMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: _showEditBeratDialog,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: const Icon(
                                            Icons.edit_rounded,
                                            size: 13,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Plus Button
                              GestureDetector(
                                onTap: _incrementBerat,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: _lime,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: _primaryDark,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Section: Jadwal Jemput / Antar ───────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isJemput ? 'Jadwal jemput' : 'Jadwal antar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 3 horizontal date cards
                        Row(
                          children: List.generate(scheduleDays.length, (i) {
                            final isSelected = _safeDateIndex == i;
                            final item = scheduleDays[i];
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedDateIndex = i),
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: i < scheduleDays.length - 1 ? 10 : 0,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _primaryDark
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? _primaryDark
                                          : _borderColor,
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.02),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        item.day,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white70
                                              : _textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.date,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected
                                              ? Colors.white
                                              : _textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        // 2 horizontal time slots
                        Row(
                          children: List.generate(timeSlots.length, (i) {
                            final isSelected = _safeSlotIndex == i;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedSlotIndex = i),
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: i < timeSlots.length - 1 ? 10 : 0,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? _lime : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? _primaryDark
                                          : _borderColor,
                                      width: isSelected ? 1.5 : 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    timeSlots[i],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? _primaryDark
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // ── Section: Alamat Jemput / Drop-off ────────────────────
                  if (_isJemput)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _borderColor, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: _primaryDark,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Alamat jemput',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentAlamat,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _showEditAlamatSheet,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Text(
                                  'Ubah',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0D9488),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _borderColor, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.storefront_outlined,
                                color: _primaryDark,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lokasi Bank Sampah',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Bank Sampah Induk, Jl. Merdeka No. 45',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
                                  ),
                                ],
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

          // ── Sticky Bottom Bar (Above Navigation Bar) ────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: _borderColor, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Estimasi nilai',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.rupiah(estimasiNilai),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitSetor,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isJemput ? 'Ajukan jemputan' : 'Setor sekarang',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
