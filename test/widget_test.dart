// Basic smoke test for the Bank Sampah app.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ukk_app_bank_sampah/app.dart';
import 'package:ukk_app_bank_sampah/providers/auth_provider.dart';
import 'package:ukk_app_bank_sampah/providers/kategori_sampah_provider.dart';
import 'package:ukk_app_bank_sampah/providers/setor_sampah_provider.dart';
import 'package:ukk_app_bank_sampah/providers/hadiah_provider.dart';
import 'package:ukk_app_bank_sampah/providers/penukaran_poin_provider.dart';
import 'package:ukk_app_bank_sampah/providers/admin_provider.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => KategoriSampahProvider()),
          ChangeNotifierProvider(create: (_) => SetorSampahProvider()),
          ChangeNotifierProvider(create: (_) => HadiahProvider()),
          ChangeNotifierProvider(create: (_) => PenukaranPoinProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
        ],
        child: const BankSampahApp(),
      ),
    );

    expect(find.byType(BankSampahApp), findsOneWidget);
  });
}
