import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../models/setor_sampah_model.dart';
import '../../providers/setor_sampah_provider.dart';
import '../../providers/kategori_sampah_provider.dart';
import '../../services/setor_sampah_service.dart';
import '../widgets/common_widgets.dart';

class KonfirmasiSetorScreen extends StatefulWidget {
  final SetorSampahModel? initialSetor;
  const KonfirmasiSetorScreen({super.key, this.initialSetor});

  @override
  State<KonfirmasiSetorScreen> createState() => _KonfirmasiSetorScreenState();
}

class _KonfirmasiSetorScreenState extends State<KonfirmasiSetorScreen> {
  SetorSampahModel? _currentSetor;
  final TextEditingController _catatanCtrl = TextEditingController();
  final Map<int, TextEditingController> _weightControllers = {};

  static const Color _primaryDark = Color(0xFF144D37);
  static const Color _accentLime = Color(0xFFD4F67B);
  static const Color _textDark = Color(0xFF0F2F24);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _bgSoft = Color(0xFFF6F8F5);

  @override
  void initState() {
    super.initState();
    _currentSetor = widget.initialSetor;
    _initWeightControllers();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final setor = _currentSetor;
      if (setor != null) {
        try {
          final full = await SetorSampahService.getDetail(setor.id);
          if (mounted && full.detailSetors.isNotEmpty) {
            setState(() {
              _currentSetor = full;
              _initWeightControllers();
            });
          }
        } catch (_) {}
      } else {
        final provider = context.read<SetorSampahProvider>();
        await provider.fetchAdminList(status: 'menunggu_konfirmasi');
        if (mounted && provider.adminSetorList.isNotEmpty) {
          final first = provider.adminSetorList.first;
          try {
            final full = await SetorSampahService.getDetail(first.id);
            if (mounted) {
              setState(() {
                _currentSetor = full;
                _initWeightControllers();
              });
            }
          } catch (_) {
            if (mounted) {
              setState(() {
                _currentSetor = first;
                _initWeightControllers();
              });
            }
          }
        }
      }
    });
  }

  void _initWeightControllers() {
    _weightControllers.clear();
    final details = _currentSetor?.detailSetors;
    if (details != null && details.isNotEmpty) {
      for (int i = 0; i < details.length; i++) {
        final initialKg = details[i].beratKg.toDouble();
        final text = initialKg == initialKg.toInt()
            ? '${initialKg.toInt()},0'
            : initialKg.toStringAsFixed(1).replaceAll('.', ',');
        _weightControllers[i] = TextEditingController(text: text);
      }
    } else {
      // Fallback dummy matching mockup if no details exist
      _weightControllers[0] = TextEditingController(text: '10,0');
      _weightControllers[1] = TextEditingController(text: '9,0');
      _weightControllers[2] = TextEditingController(text: '5,5');
    }
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    for (final c in _weightControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _parseWeight(String text) {
    final cleaned = text.replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  double _calculateTotalWeight() {
    double total = 0.0;
    for (final c in _weightControllers.values) {
      total += _parseWeight(c.text);
    }
    return total;
  }

  int _calculateTotalPoints() {
    final details = _currentSetor?.detailSetors;
    if (details != null && details.isNotEmpty) {
      double totalPoints = 0;
      for (int i = 0; i < details.length; i++) {
        final w = _parseWeight(_weightControllers[i]?.text ?? '0');
        final rate = details[i].poinPerKg ??
            (details[i].beratKg > 0 ? (details[i].subtotalPoin / details[i].beratKg) : 90);
        totalPoints += w * rate;
      }
      return totalPoints.round();
    }
    // Fallback point calculation for dummy mockup
    final totalW = _calculateTotalWeight();
    return (totalW * 90).round();
  }

  Future<void> _handleKonfirmasi() async {
    final setorId = _currentSetor?.id;
    if (setorId == null) {
      Navigator.pop(context);
      return;
    }

    final provider = context.read<SetorSampahProvider>();
    final itemsReal = <Map<String, dynamic>>[];
    final details = _currentSetor?.detailSetors;

    if (details != null && details.isNotEmpty) {
      for (int i = 0; i < details.length; i++) {
        final w = _parseWeight(_weightControllers[i]?.text ?? '0');
        if (w <= 0) {
          showErrorSnackbar(
            context,
            'Berat aktual untuk ${details[i].namaKategori ?? "sampah"} harus lebih dari 0 kg',
          );
          return;
        }

        String? katId = details[i].kategoriSampahId;
        if (katId == null || katId.isEmpty) {
          try {
            final allKategori = context.read<KategoriSampahProvider>().kategoriList;
            final match = allKategori.where((k) =>
                k.namaKategori.toLowerCase() == (details[i].namaKategori ?? '').toLowerCase() ||
                k.jenis.toLowerCase() == (details[i].jenis ?? '').toLowerCase());
            if (match.isNotEmpty) {
              katId = match.first.id;
            }
          } catch (_) {}
        }

        final itemPayload = <String, dynamic>{
          'beratKgReal': w,
          'beratKg': w,
        };
        if (katId != null && katId.isNotEmpty) {
          itemPayload['kategoriSampahId'] = katId;
        }
        if (details[i].id != null && details[i].id!.isNotEmpty) {
          itemPayload['id'] = details[i].id;
          itemPayload['detailSetorId'] = details[i].id;
        }

        itemsReal.add(itemPayload);
      }
    }

    final ok = await provider.verify(
      id: setorId,
      status: 'selesai',
      catatanAdmin: _catatanCtrl.text.trim(),
      itemsReal: itemsReal.isNotEmpty ? itemsReal : null,
    );

    if (mounted) {
      if (ok) {
        showSuccessSnackbar(context, 'Setoran berhasil dikonfirmasi!');
        Navigator.pop(context);
      } else {
        showErrorSnackbar(context, provider.errorMessage ?? 'Gagal memproses setoran');
      }
    }
  }

  Future<void> _handleTolak() async {
    final setorId = _currentSetor?.id;
    if (setorId == null) {
      Navigator.pop(context);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tolak Setoran?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menolak pengajuan setoran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tolak Setoran'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<SetorSampahProvider>();
      final ok = await provider.verify(
        id: setorId,
        status: 'ditolak',
        catatanAdmin: _catatanCtrl.text.trim(),
      );
      if (mounted) {
        if (ok) {
          showSuccessSnackbar(context, 'Setoran telah ditolak');
          Navigator.pop(context);
        } else {
          showErrorSnackbar(context, provider.errorMessage ?? 'Gagal menolak setoran');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final setor = _currentSetor;
    final totalW = _calculateTotalWeight();
    final totalWFormatted = totalW.toStringAsFixed(1).replaceAll('.', ',');
    final totalPoin = _calculateTotalPoints();
    final totalPoinFormatted = NumberFormat.decimalPattern('id_ID').format(totalPoin);

    final String kodeSetor = setor?.kodeSetor ?? 'STR-261021-9085';
    final String namaNasabah = setor?.namaNasabah ?? 'riski';
    final String tanggalJemput = setor != null
        ? '${Formatters.tanggalSingkat(setor.tanggal)}, 08.00–10.00'
        : '22/10/2026, 08.00–10.00';

    final details = setor?.detailSetors;
    final bool hasDetails = details != null && details.isNotEmpty;

    return Scaffold(
      backgroundColor: _bgSoft,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Verifikasi setoran',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Scrollable Form Content ─────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Info Card
                    Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                kodeSetor,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Menunggu',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$namaNasabah · jemput $tanggalJemput',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section Heading: Timbang & cocokkan berat
                    const Text(
                      'Timbang & cocokkan berat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Items Container Card
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
                        children: hasDetails
                            ? List.generate(details.length, (i) {
                                final d = details[i];
                                final name = d.namaKategori ?? d.jenis ?? 'Sampah';
                                final diajukanKg = d.beratKg.toStringAsFixed(1).replaceAll('.', ',');
                                return Column(
                                  children: [
                                    _buildWeighRow(
                                      title: name,
                                      subtitle: 'Diajukan $diajukanKg kg',
                                      controller: _weightControllers[i] ?? TextEditingController(),
                                    ),
                                    if (i < details.length - 1)
                                      const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                                  ],
                                );
                              })
                            : [
                                _buildWeighRow(
                                  title: 'Plastik PET',
                                  subtitle: 'Diajukan 10,0 kg',
                                  controller: _weightControllers[0] ?? TextEditingController(),
                                ),
                                const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                                _buildWeighRow(
                                  title: 'Kardus',
                                  subtitle: 'Diajukan 9,0 kg',
                                  controller: _weightControllers[1] ?? TextEditingController(),
                                ),
                                const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                                _buildWeighRow(
                                  title: 'Kaleng aluminium',
                                  subtitle: 'Diajukan 5,5 kg',
                                  controller: _weightControllers[2] ?? TextEditingController(),
                                ),
                              ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Dark Green Summary Banner ────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: _primaryDark,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryDark.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total berat aktual',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalWFormatted kg',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Poin diterbitkan',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                totalPoinFormatted,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: _accentLime,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section Heading: Catatan (opsional)
                    const Text(
                      'Catatan (opsional)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Catatan TextField
                    TextField(
                      controller: _catatanCtrl,
                      decoration: InputDecoration(
                        hintText: 'Contoh: kardus sedikit basah',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: _cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: _cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: _primaryDark, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Fixed Action Buttons ──────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: _cardBorder, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Button Tolak
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textDark,
                        side: const BorderSide(color: _cardBorder, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _handleTolak,
                      child: const Text(
                        'Tolak',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Button Konfirmasi Setoran
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _handleKonfirmasi,
                      child: const Text(
                        'Konfirmasi setoran',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeighRow({
    required String title,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Editable weight box
          Container(
            width: 80,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cardBorder, width: 1.2),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                color: _textDark,
              ),
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
