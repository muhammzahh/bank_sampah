import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';

class RegisterAdminScreen extends StatefulWidget {
  const RegisterAdminScreen({super.key});

  @override
  State<RegisterAdminScreen> createState() => _RegisterAdminScreenState();
}

class _RegisterAdminScreenState extends State<RegisterAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _namaUnitCtrl = TextEditingController();
  final _namaPengelolaCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.registerAdminBank(
      username: _usernameCtrl.text.trim(),
      password: _passCtrl.text,
      namaUnit: _namaUnitCtrl.text.trim(),
      namaPengelola: _namaPengelolaCtrl.text.trim(),
      telp: _telpCtrl.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      showSuccessSnackbar(context, 'Pendaftaran unit bank sampah berhasil, silakan login');
      Navigator.of(context).pop();
    } else {
      showErrorSnackbar(context, auth.errorMessage ?? 'Pendaftaran gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Unit Bank Sampah'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Icon(Icons.storefront, size: 64, color: AppColors.primary),
                const SizedBox(height: 8),
                const Text(
                  'Daftarkan unit Bank Sampah Anda untuk mulai mengelola nasabah, '
                  'kategori sampah, dan hadiah.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _namaUnitCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Unit Bank Sampah', border: OutlineInputBorder()),
                  validator: (v) => Validators.required(v, field: 'Nama unit'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _namaPengelolaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Pengelola', border: OutlineInputBorder()),
                  validator: (v) => Validators.required(v, field: 'Nama pengelola'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telpCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'No. Telepon', border: OutlineInputBorder()),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  validator: (v) => Validators.required(v, field: 'Username'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  validator: Validators.password,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Daftar',
                  loading: auth.status == AuthStatus.loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
