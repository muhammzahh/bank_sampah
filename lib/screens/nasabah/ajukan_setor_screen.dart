import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/kategori_sampah_model.dart';
import '../../models/setor_sampah_model.dart';
import '../../providers/kategori_sampah_provider.dart';
import '../../providers/setor_sampah_provider.dart';
import '../widgets/common_widgets.dart';

class AjukanSetorScreen extends StatefulWidget {
  final bool isTab;
  final KategoriSampahModel? initialKategori;
  const AjukanSetorScreen({super.key, this.isTab = false, this.initialKategori});

  @override
  State<AjukanSetorScreen> createState() => _AjukanSetorScreenState();
}

class _AjukanSetorScreenState extends State<AjukanSetorScreen> {
  int _currentStep = 1;
  KategoriSampahModel? _selectedKategori;
  double _beratKg = 1.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final katProv = context.read<KategoriSampahProvider>();
      if (katProv.kategoriList.isEmpty) {
        await katProv.fetchAll();
      }
      if (widget.initialKategori != null && mounted) {
        setState(() {
          _selectedKategori = widget.initialKategori;
        });
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedKategori == null || _beratKg <= 0) return;
    
    setState(() => _isSubmitting = true);
    final provider = context.read<SetorSampahProvider>();
    
    provider.clearCart();
    provider.addToCart(
      ItemSetorInput(kategoriSampahId: _selectedKategori!.id, beratKg: _beratKg),
    );

    final success = await provider.ajukanSetor(
      tanggal: DateTime.now().toUtc().toIso8601String(),
      catatan: '',
    );
    
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    
    if (success) {
      provider.fetchMySetor();
      setState(() {
        _currentStep = 3;
      });
    } else {
      showErrorSnackbar(context, provider.errorMessage ?? 'Gagal mengajukan setor');
    }
  }

  Widget _buildStepper() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(1, 'Pilih Jenis'),
          _buildStepDivider(1),
          _buildStepItem(2, 'Timbang'),
          _buildStepDivider(2),
          _buildStepItem(3, 'Konfirmasi'),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String title) {
    final isActive = _currentStep == step;
    final isPast = _currentStep > step;
    final color = isActive || isPast ? AppColors.primary : AppColors.textLight;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isPast ? AppColors.primary : Colors.white,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: isPast
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: isActive || isPast ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int stepIndex) {
    final isPast = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 2,
        color: isPast ? AppColors.primary : AppColors.textLight.withValues(alpha: 0.3),
        margin: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 24),
      ),
    );
  }

  Widget _buildStep1() {
    final kategoriProvider = context.watch<KategoriSampahProvider>();
    return Column(
      children: [
        Expanded(
          child: kategoriProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: kategoriProvider.kategoriList.length,
                  itemBuilder: (context, index) {
                    final k = kategoriProvider.kategoriList[index];
                    final isSelected = _selectedKategori?.id == k.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedKategori = k;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: k.id,
                              groupValue: _selectedKategori?.id,
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                setState(() {
                                  _selectedKategori = k;
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    k.namaKategori,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${k.poinPerKg.toInt()} / kg',
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedKategori == null
                  ? null
                  : () {
                      setState(() {
                        _currentStep = 2;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lanjut', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    if (_selectedKategori == null) return const SizedBox();
    
    final totalSaldo = _beratKg * _selectedKategori!.poinPerKg;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.monitor_weight_rounded, size: 60, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Masukkan berat sampah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_beratKg > 0.5) {
                          setState(() => _beratKg -= 0.5);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '${_beratKg.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed: () {
                        setState(() => _beratKg += 0.5);
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 40, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jenis Sampah', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                          Text(_selectedKategori!.namaKategori, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Harga per kg', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                          Text('Rp ${_selectedKategori!.poinPerKg.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Saldo', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Rp ${totalSaldo.toInt()}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _currentStep = 1;
                          });
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Lanjut ke Konfirmasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final totalSaldo = _beratKg * (_selectedKategori?.poinPerKg ?? 0);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight, size: 100),
          const SizedBox(height: 24),
          const Text(
            'Setor Sampah Berhasil!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sampahmu telah berhasil disetor. Silahkan serahkan sampah ke petugas untuk ditimbang ulang.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textGrey),
          ),
          const SizedBox(height: 40),
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jenis Sampah', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                    Text(_selectedKategori?.namaKategori ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Berat', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                    Text('${_beratKg.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Saldo', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Rp ${totalSaldo.toInt()}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Setor Sampah'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: _currentStep == 1
                ? _buildStep1()
                : _currentStep == 2
                    ? _buildStep2()
                    : _buildStep3(),
          ),
        ],
      ),
    );
  }
}
