import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';

class RegisterNasabahScreen extends StatefulWidget {
  const RegisterNasabahScreen({super.key});

  @override
  State<RegisterNasabahScreen> createState() => _RegisterNasabahScreenState();
}

class _RegisterNasabahScreenState extends State<RegisterNasabahScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();
  File? _fotoFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _fotoFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.registerNasabah(
      username: _usernameCtrl.text.trim(),
      password: _passCtrl.text,
      namaNasabah: _namaCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
      telp: _telpCtrl.text.trim(),
      foto: _fotoFile,
    );
    if (!mounted) return;
    if (success) {
      showSuccessSnackbar(context, 'Registrasi berhasil, silakan login');
      Navigator.of(context).pop();
    } else {
      showErrorSnackbar(context, auth.errorMessage ?? 'Registrasi gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Daftar Akun Nasabah'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: _fotoFile != null ? FileImage(_fotoFile!) : null,
                      child: _fotoFile == null
                          ? const Icon(Icons.camera_alt, size: 32, color: AppColors.primary)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('Tap untuk pilih foto profil (opsional)', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _namaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _alamatCtrl,
                  decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telpCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'No. Telepon', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
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
