import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/setup_app_maker_screen.dart';
import '../screens/auth/login_nasabah_screen.dart';
import '../screens/auth/login_admin_screen.dart';
import '../screens/auth/register_nasabah_screen.dart';

import '../screens/nasabah/nasabah_home_screen.dart';
import '../screens/nasabah/kategori_sampah_screen.dart';
import '../screens/nasabah/ajukan_setor_screen.dart';
import '../screens/nasabah/status_setor_screen.dart';
import '../screens/nasabah/nota_setor_screen.dart';
import '../screens/nasabah/nota_penukaran_screen.dart';
import '../screens/nasabah/hadiah_screen.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/nasabah_crud_screen.dart';
import '../screens/admin/kategori_crud_screen.dart';
import '../screens/admin/hadiah_crud_screen.dart';
import '../screens/admin/konfirmasi_setor_screen.dart';
import '../screens/admin/rekapitulasi_screen.dart';

/// Kumpulan nama route (dipakai dengan Navigator.pushNamed).
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String setupAppMaker = '/setup-app-maker';
  static const String login = '/login';
  static const String loginNasabah = '/login-nasabah';
  static const String loginAdmin = '/login-admin';
  static const String registerNasabah = '/register-nasabah';

  // Nasabah
  static const String nasabahHome = '/nasabah/home';
  static const String kategoriSampah = '/nasabah/kategori-sampah';
  static const String ajukanSetor = '/nasabah/ajukan-setor';
  static const String statusSetor = '/nasabah/status-setor';
  static const String notaSetor = '/nasabah/nota-setor'; // butuh argument: setorId
  static const String notaPenukaran = '/nasabah/nota-penukaran'; // butuh argument: penukaranId
  static const String hadiah = '/nasabah/hadiah';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminNasabah = '/admin/nasabah';
  static const String adminKategori = '/admin/kategori-sampah';
  static const String adminHadiah = '/admin/hadiah';
  static const String adminKonfirmasiSetor = '/admin/konfirmasi-setor';
  static const String adminRekapitulasi = '/admin/rekapitulasi';

  /// Generator route terpusat. Dipakai di MaterialApp(onGenerateRoute: ...)
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _page(const SplashScreen());
      case onboarding:
        return _page(const OnboardingScreen());
      case setupAppMaker:
        return _page(const SetupAppMakerScreen());
      case login:
      case loginNasabah:
        return _page(const LoginNasabahScreen());
      case loginAdmin:
        return _page(const LoginAdminScreen());
      case registerNasabah:
        return _page(const RegisterNasabahScreen());

      // ---- Nasabah ----
      case nasabahHome:
        return _page(const NasabahHomeScreen());
      case kategoriSampah:
        return _page(const KategoriSampahScreen());
      case ajukanSetor:
        return _page(const AjukanSetorScreen());
      case statusSetor:
        return _page(const StatusSetorScreen());
      case notaSetor:
        final setorId = settings.arguments as String;
        return _page(NotaSetorScreen(setorId: setorId));
      case notaPenukaran:
        final penukaranId = settings.arguments as String;
        return _page(NotaPenukaranScreen(penukaranId: penukaranId));
      case hadiah:
        return _page(const HadiahScreen());

      // ---- Admin ----
      case adminDashboard:
        return _page(const AdminDashboardScreen());
      case adminNasabah:
        return _page(const NasabahCrudScreen());
      case adminKategori:
        return _page(const KategoriCrudScreen());
      case adminHadiah:
        return _page(const HadiahCrudScreen());
      case adminKonfirmasiSetor:
        return _page(const KonfirmasiSetorScreen());
      case adminRekapitulasi:
        return _page(const RekapitulasiScreen());

      default:
        return _page(
          Scaffold(
            body: Center(child: Text('Halaman "${settings.name}" tidak ditemukan')),
          ),
        );
    }
  }

  static PageRoute _page(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
