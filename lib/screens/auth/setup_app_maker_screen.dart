import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

/// Layar setup App Maker – dilakukan SATU KALI sebelum fitur lain bisa dipakai.
/// Mendaftarkan aplikasi ke backend UKK dan menyimpan appKey secara lokal.
class SetupAppMakerScreen extends StatefulWidget {
  const SetupAppMakerScreen({super.key});

  @override
  State<SetupAppMakerScreen> createState() => _SetupAppMakerScreenState();
}

class _SetupAppMakerScreenState extends State<SetupAppMakerScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _namaCtrl  = TextEditingController();
  final _kelasCtrl = TextEditingController();
  final _appCtrl   = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _namaCtrl.dispose();
    _kelasCtrl.dispose();
    _appCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.setupAppMaker(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      namaSiswa: _namaCtrl.text.trim(),
      kelas: _kelasCtrl.text.trim(),
      namaApp: _appCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      showSuccessSnackbar(context, 'Setup berhasil! Silakan pilih akses login.');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      showErrorSnackbar(context, auth.errorMessage ?? 'Setup gagal, coba lagi');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.storefront, size: 72, color: AppColors.primary),
                const SizedBox(height: 12),
                const Text(
                  'Setup App Maker',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Lakukan sekali untuk mendaftarkan aplikasi ini ke server UKK.\nMasukkan data identitas siswa pembuat aplikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 28),
                _field(_emailCtrl, 'Email Siswa', Icons.email_outlined,
                    validator: (v) => (v == null || v.isEmpty) ? 'Email wajib diisi' : null),
                const SizedBox(height: 12),
                _field(_passCtrl, 'Password', Icons.lock_outline,
                    obscure: true,
                    validator: (v) => (v == null || v.length < 6) ? 'Min. 6 karakter' : null),
                const SizedBox(height: 12),
                _field(_namaCtrl, 'Nama Siswa', Icons.person_outline,
                    validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null),
                const SizedBox(height: 12),
                _field(_kelasCtrl, 'Kelas', Icons.class_outlined,
                    validator: (v) => (v == null || v.isEmpty) ? 'Kelas wajib diisi' : null),
                const SizedBox(height: 12),
                _field(_appCtrl, 'Nama Aplikasi', Icons.app_registration,
                    validator: (v) => (v == null || v.isEmpty) ? 'Nama aplikasi wajib diisi' : null),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Daftarkan Aplikasi',
                  loading: loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
