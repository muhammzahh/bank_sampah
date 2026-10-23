import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Halaman Login Nasabah Bank Sampah (Desain Modern Pilah).
class LoginNasabahScreen extends StatelessWidget {
  const LoginNasabahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(initialRole: UserRole.nasabah);
  }
}
