import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Halaman Login Admin Bank Sampah (Desain Modern Pilah).
class LoginAdminScreen extends StatelessWidget {
  const LoginAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(initialRole: UserRole.admin);
  }
}
