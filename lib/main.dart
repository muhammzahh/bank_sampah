import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/kategori_sampah_provider.dart';
import 'providers/setor_sampah_provider.dart';
import 'providers/hadiah_provider.dart';
import 'providers/penukaran_poin_provider.dart';
import 'providers/admin_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await initializeDateFormatting('id_ID', null);

  runApp( 
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
} 
