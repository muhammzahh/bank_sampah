import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/penukaran_poin_model.dart';
import '../../services/penukaran_poin_service.dart';
import '../widgets/common_widgets.dart';

class NotaPenukaranScreen extends StatefulWidget {
  final String penukaranId;
  const NotaPenukaranScreen({super.key, required this.penukaranId});

  @override
  State<NotaPenukaranScreen> createState() => _NotaPenukaranScreenState();
}

class _NotaPenukaranScreenState extends State<NotaPenukaranScreen> {
  PenukaranPoinModel? _data;
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
      _data = await PenukaranPoinService.getNota(widget.penukaranId);
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
        title: const Text('Bukti Penukaran Hadiah'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? EmptyView(message: _error!)
              : _buildNota(),
    );
  }

  Widget _buildNota() {
    final p = _data!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Penukaran Hadiah',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 32),
            _row('Kode Penukaran', p.kodePenukaran ?? p.id),
            _row('Tanggal', Formatters.tanggalIndo(p.tanggal)),
            if (p.namaNasabah != null) _row('Nasabah', p.namaNasabah!),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(status: p.status),
            ),
            const Divider(height: 32),
            const Text('Detail Hadiah', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _row('Nama Hadiah', p.namaHadiah ?? '-'),
            _row('Poin Dibutuhkan', '${p.poinDibutuhkanHadiah ?? 0} Poin'),
            const Divider(height: 32),
            _row('Poin Ditukar', '${p.poinTerpakai} Poin', bold: true),
            if (p.sisaSaldoPoin != null)
              _row('Sisa Saldo Poin', '${p.sisaSaldoPoin} Poin', bold: true),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Terima kasih telah menukarkan poin Anda!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Simpan'),
                    onPressed: () {
                      showSuccessSnackbar(context, 'Nota penukaran berhasil disimpan ke galeri/dokumen');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Cetak'),
                    onPressed: () {
                      showSuccessSnackbar(context, 'Mengirim perintah cetak nota penukaran...');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
