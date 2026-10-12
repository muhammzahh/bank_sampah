import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';
import '../nasabah/nasabah_home_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'register_nasabah_screen.dart';
import 'register_admin_screen.dart';

enum UserRole { nasabah, admin }

class LoginScreen extends StatefulWidget {
  final UserRole initialRole;
  const LoginScreen({super.key, this.initialRole = UserRole.nasabah});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool  _obscure  = true;
  late UserRole _role;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  bool get _isAdmin => _role == UserRole.admin;
  Color get _roleColor => _isAdmin ? const Color(0xFF1565C0) : AppColors.primary;

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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              user.isAdmin ? const AdminDashboardScreen() : const NasabahHomeScreen(),
        ),
        (r) => false,
      );
    } else {
      showErrorSnackbar(context, auth.errorMessage ?? 'Login gagal');
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
      builder: (_) => const _SetupBottomSheet(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final loading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: _isAdmin
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                      )
                    : AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Header Section ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        if (Navigator.canPop(context))
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                          ),
                          child: const Icon(Icons.recycling_rounded, size: 44, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Bank Sampah Digital',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola sampah, raih manfaat',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Form Card ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _roleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Silakan login untuk melanjutkan',
                              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                            ),
                            const SizedBox(height: 20),

                            // ── Toggle Role ───────────────────────────────
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  _RoleTab(
                                    label: 'Nasabah',
                                    icon: Icons.person_rounded,
                                    selected: !_isAdmin,
                                    color: AppColors.primary,
                                    onTap: () => setState(() => _role = UserRole.nasabah),
                                  ),
                                  _RoleTab(
                                    label: 'Admin',
                                    icon: Icons.admin_panel_settings_rounded,
                                    selected: _isAdmin,
                                    color: const Color(0xFF1565C0),
                                    onTap: () => setState(() => _role = UserRole.admin),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Username ──────────────────────────────────
                            TextFormField(
                              controller: _userCtrl,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                hintText: 'Masukkan username',
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: _roleColor, width: 2),
                                ),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Username wajib diisi' : null,
                            ),
                            const SizedBox(height: 14),

                            // ── Password ──────────────────────────────────
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Masukkan password',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: _roleColor, width: 2),
                                ),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Password wajib diisi' : null,
                            ),
                            const SizedBox(height: 24),

                            // ── Login Button ──────────────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _roleColor,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: loading ? null : _submit,
                                child: loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'MASUK',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Register link ─────────────────────────────
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => _isAdmin
                                        ? const RegisterAdminScreen()
                                        : const RegisterNasabahScreen(),
                                  ),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Belum punya akun? ',
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Daftar',
                                        style: TextStyle(
                                          color: _roleColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role Tab Widget
// ─────────────────────────────────────────────────────────────────────────────
class _RoleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _RoleTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: selected ? Colors.white : AppColors.textGrey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected ? Colors.white : AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Setup App Maker Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _SetupBottomSheet extends StatefulWidget {
  const _SetupBottomSheet();

  @override
  State<_SetupBottomSheet> createState() => _SetupBottomSheetState();
}

class _SetupBottomSheetState extends State<_SetupBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // ── Tab Daftar ──
  final _regFormKey  = GlobalKey<FormState>();
  final _regEmail    = TextEditingController();
  final _regPass     = TextEditingController();
  final _regNama     = TextEditingController();
  final _regKelas    = TextEditingController();
  final _regApp      = TextEditingController();

  // ── Tab Login ──
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmail   = TextEditingController();
  final _loginPass    = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _regEmail.dispose(); _regPass.dispose(); _regNama.dispose();
    _regKelas.dispose(); _regApp.dispose();
    _loginEmail.dispose(); _loginPass.dispose();
    super.dispose();
  }

  Future<void> _submitDaftar() async {
    if (!_regFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.setupAppMaker(
      email: _regEmail.text.trim(),
      password: _regPass.text,
      namaSiswa: _regNama.text.trim(),
      kelas: _regKelas.text.trim(),
      namaApp: _regApp.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      showSuccessSnackbar(context, 'Pendaftaran berhasil! Silakan login.');
      Navigator.of(context).pop(true);
    } else {
      showErrorSnackbar(context, auth.errorMessage ?? 'Pendaftaran gagal');
    }
  }

  Future<void> _submitLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginAppMaker(
      email: _loginEmail.text.trim(),
      password: _loginPass.text,
    );
    if (!mounted) return;
    if (ok) {
      showSuccessSnackbar(context, 'Berhasil! Silakan login.');
      Navigator.of(context).pop(true);
    } else {
      showErrorSnackbar(context, auth.errorMessage ?? 'Login App Maker gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final loading = auth.status == AuthStatus.loading;
    final bottom  = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_rounded, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          const Text(
            'Setup App Maker',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Diperlukan satu kali untuk mengaktifkan aplikasi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),

          // ── Tab bar ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textGrey,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Daftar Baru'),
                Tab(text: 'Sudah Terdaftar'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Tab views ──────────────────────────────────────────────────
          SizedBox(
            height: 340,
            child: TabBarView(
              controller: _tab,
              children: [
                // Tab 1: Daftar
                SingleChildScrollView(
                  child: Form(
                    key: _regFormKey,
                    child: Column(
                      children: [
                        _field(_regEmail, 'Email Siswa', Icons.email_outlined,
                            validator: (v) => (v == null || v.isEmpty) ? 'Email wajib diisi' : null),
                        const SizedBox(height: 10),
                        _field(_regPass, 'Password', Icons.lock_outline_rounded,
                            obscure: true,
                            validator: (v) => (v == null || v.length < 6) ? 'Min. 6 karakter' : null),
                        const SizedBox(height: 10),
                        _field(_regNama, 'Nama Siswa', Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null),
                        const SizedBox(height: 10),
                        _field(_regKelas, 'Kelas', Icons.class_outlined,
                            validator: (v) => (v == null || v.isEmpty) ? 'Kelas wajib diisi' : null),
                        const SizedBox(height: 10),
                        _field(_regApp, 'Nama Aplikasi', Icons.app_registration_rounded,
                            validator: (v) => (v == null || v.isEmpty) ? 'Nama aplikasi wajib diisi' : null),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Daftarkan Aplikasi',
                          loading: loading,
                          onPressed: _submitDaftar,
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab 2: Login
                SingleChildScrollView(
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Masukkan email & password App Maker\nyang sudah pernah didaftarkan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                        ),
                        const SizedBox(height: 16),
                        _field(_loginEmail, 'Email Siswa', Icons.email_outlined,
                            validator: (v) => (v == null || v.isEmpty) ? 'Email wajib diisi' : null),
                        const SizedBox(height: 10),
                        _field(_loginPass, 'Password', Icons.lock_outline_rounded,
                            obscure: true,
                            validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Ambil App Key',
                          loading: loading,
                          onPressed: _submitLogin,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        isDense: true,
      ),
    );
  }
}
