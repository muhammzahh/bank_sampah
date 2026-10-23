import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';
import '../nasabah/nasabah_home_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'register_nasabah_screen.dart';
import 'register_admin_screen.dart';
import 'setup_app_maker_screen.dart';

enum UserRole { nasabah, admin }

class LoginScreen extends StatefulWidget {
  final UserRole initialRole;
  const LoginScreen({super.key, this.initialRole = UserRole.nasabah});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  late UserRole _role;

  static const Color _forestGreen = Color(0xFF144D37);
  static const Color _lime = Color(0xFFD4F67B);
  static const Color _textDark = Color(0xFF0F2F24);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _inputBorder = Color(0xFFCBD5E1);

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  bool get _isAdmin => _role == UserRole.admin;

  void _switchRole(UserRole newRole) {
    if (_role == newRole) return;
    setState(() {
      _role = newRole;
      _userCtrl.clear();
      _passCtrl.clear();
      _formKey.currentState?.reset();
    });
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();

    if (!auth.appMakerReady) {
      final ok = await _showSetupDialog();
      if (!ok || !mounted) return;
    }

    final success = await auth.login(
      username: _userCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      final user = auth.currentUser!;

      // ── Validasi Kesesuaian Role yang Dipilih ─────────────────────────
      if (_role == UserRole.admin && !user.isAdmin) {
        await auth.logout();
        if (!mounted) return;
        showErrorSnackbar(
          context,
          'Akun ini bukan akun Admin. Silakan pilih tab Nasabah untuk masuk.',
        );
        return;
      }

      if (_role == UserRole.nasabah && user.isAdmin) {
        await auth.logout();
        if (!mounted) return;
        showErrorSnackbar(
          context,
          'Akun ini adalah akun Admin. Silakan pilih tab Admin untuk masuk.',
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              user.isAdmin ? const AdminDashboardScreen() : const NasabahHomeScreen(),
        ),
        (r) => false,
      );
    } else {
      showErrorSnackbar(
        context,
        auth.errorMessage ?? 'Login gagal. Cek username dan password Anda.',
      );
    }
  }

  Future<bool> _showSetupDialog() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const SetupAppMakerScreen(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top Section (Concentric Circles & Hero Content) ───────────
            CustomPaint(
              painter: _ConcentricCirclesPainter(),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand Logo & Name
                      Row(
                        children: [
                          if (Navigator.canPop(context)) ...[
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: _lime,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.energy_savings_leaf_rounded,
                                color: _forestGreen,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Pilah',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),

                      // Headline
                      const Text(
                        'Pilah sampah,\ntabung hasilnya.',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      const Text(
                        'Setor ke bank sampah terdekat, kumpulkan saldo dan poin hijau dari setiap kilo.',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFD1E7DD),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Sheet (Form Card) ──────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Masuk ke akun',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Role Segmented Toggle (Nasabah / Admin)
                    Container(
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EFEA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildRoleSegment(
                              role: UserRole.nasabah,
                              label: 'Nasabah',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                          Expanded(
                            child: _buildRoleSegment(
                              role: UserRole.admin,
                              label: 'Admin',
                              icon: Icons.verified_user_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Username Label & Field
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _userCtrl,
                      style: const TextStyle(fontSize: 14, color: _textDark),
                      decoration: InputDecoration(
                        hintText: 'Masukkan username',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _inputBorder,
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _inputBorder,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _forestGreen,
                            width: 1.8,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Username wajib diisi' : null,
                    ),
                    const SizedBox(height: 18),

                    // Password Label & Field
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(fontSize: 14, color: _textDark),
                      decoration: InputDecoration(
                        hintText: 'Masukkan password',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _textMuted,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _inputBorder,
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _inputBorder,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _forestGreen,
                            width: 1.8,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button ("Lanjutkan")
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _forestGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: loading ? null : _submit,
                        child: loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Lanjutkan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum punya akun? ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _isAdmin
                                    ? const RegisterAdminScreen()
                                    : const RegisterNasabahScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 13,
                              color: _forestGreen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Footnote
                    const Center(
                      child: Text(
                        'Dengan masuk, kamu menyetujui Syarat & Ketentuan dan\nKebijakan Privasi Pilah.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: _textMuted,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSegment({
    required UserRole role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _role == role;
    return GestureDetector(
      onTap: () => _switchRole(role),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _forestGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _forestGreen.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter for Concentric Radar Rings Decoration
// ─────────────────────────────────────────────────────────────────────────────
class _ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF144D37),
    );
    final center = Offset(size.width * 0.78, size.height * 0.40);

    // Inner filled circle
    final fillPaint = Paint()
      ..color = const Color(0xFF1D5A43).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 54, fillPaint);

    // Outer concentric circle outlines
    final strokePaint = Paint()
      ..color = const Color(0xFF286D52).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final radii = [110.0, 165.0, 225.0, 290.0, 360.0];
    for (final r in radii) {
      canvas.drawCircle(center, r, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
