import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'data/shared_data.dart'; // ← AJOUT
import 'pages/login_page.dart';

void main() async {
  // ← AJOUT async
  // ✅ Ces lignes sont OBLIGATOIRES pour SQLite
  WidgetsFlutterBinding.ensureInitialized();
  // Initialiser le factory pour le support web/desktop
  sqfliteFfiInit();
  await SharedData().init(); // Charger les données depuis SQLite

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenTontine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00853F),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00853F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
