import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gastos_app/routes.dart';
import 'package:my_gastos_app/providers/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'MyGastos',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,

      // 🌞 LIGHT — SaaS Clean
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        scaffoldBackgroundColor: const Color(0xFFF8FAFC),

        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF2563EB), // azul SaaS moderno
          onPrimary: Colors.white,
          secondary: Color(0xFF10B981), // verde financeiro
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF0F172A),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2563EB),
          foregroundColor: Colors.white,
        ),

        dividerColor: const Color(0xFFE2E8F0),
      ),

      // 🌙 DARK — SaaS Premium
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        scaffoldBackgroundColor: const Color(0xFF020617),

        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF3B82F6),
          onPrimary: Colors.white,
          secondary: Color(0xFF22C55E),
          onSecondary: Colors.black,
          error: Colors.red,
          onError: Colors.white,
          surface: Color(0xFF0F172A),
          onSurface: Color(0xFFE2E8F0),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFF0F172A),
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1E293B)),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF3B82F6),
          foregroundColor: Colors.white,
        ),

        dividerColor: const Color(0xFF1E293B),
      ),

      initialRoute: Routes.home,
      routes: Routes.routes,
    );
  }
}