import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/setor_sampah_model.dart';
import '../../services/setor_sampah_service.dart';
import '../widgets/common_widgets.dart';

class NotaSetorScreen extends StatefulWidget {
  final String setorId;
  const NotaSetorScreen({super.key, required this.setorId});

  @override
  State<NotaSetorScreen> createState() => _NotaSetorScreenState();
}

class _NotaSetorScreenState extends State<NotaSetorScreen> {
  SetorSampahModel? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _data = await SetorSampahService.getDetail(widget.setorId);
    } catch (e) {
      _error = e.toString();
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bukti / Nota Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? EmptyView(message: _error!)
              : _buildNota(),
    );
  }

  Widget _buildNota() {
    final s = _data!;
    final detail = s.detailSetors.isNotEmpty ? s.detailSetors.first : null;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight, size: 80),
          const SizedBox(height: 24),
          const Text(
            'Setor Sampah Berhasil!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ini adalah bukti transaksi setor sampah Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textGrey),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: StatusBadge(status: s.status),
                ),
                const Divider(height: 32),
                _row('No. Transaksi', s.kodeSetor ?? s.id),
                const SizedBox(height: 12),
                _row('Tanggal', Formatters.tanggalIndo(s.tanggal)),
                if (s.namaNasabah != null) ...[
                  const SizedBox(height: 12),
                  _row('Nasabah', s.namaNasabah!),
                ],
                const SizedBox(height: 12),
                _row('Jenis Sampah', detail?.namaKategori ?? '-'),
                const SizedBox(height: 12),
                _row('Berat', '${s.totalBeratKg} kg'),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Saldo', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Rp ${s.totalPoin ?? s.estimasiTotalPoin ?? 0}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    showSuccessSnackbar(context, 'Nota transaksi berhasil disimpan ke galeri/dokumen');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Cetak', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    showSuccessSnackbar(context, 'Mengirim perintah cetak nota transaksi...');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
        ),
      ],
    );
  }
}
