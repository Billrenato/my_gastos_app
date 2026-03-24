import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gastos_app/routes.dart';
import 'package:my_gastos_app/providers/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    // 🎨 PALETA CINZA (igual da imagem)
    const lightBg = Color(0xFFF2F2F2);
    const lightCard = Color(0xFFFFFFFF);
    const lightText = Color(0xFF5D5E61);
    const lightBorder = Color(0xFFE0E0E0);

    const darkBg = Color(0xFF1A1A1C);
    const darkCard = Color(0xFF2A2A2D);
    const darkText = Color(0xFFC6C6C9);
    const darkBorder = Color(0xFF3A3A3D);

    return MaterialApp(
      title: 'MyGastos',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,

      // 🌞 LIGHT — Minimalista Cinza
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBg,

        colorScheme: const ColorScheme.light(
          primary: Color(0xFF5D5E61),
          onPrimary: Colors.white,

          secondary: Color(0xFF8E8E93),
          onSecondary: Colors.white,

          surface: lightCard,
          onSurface: lightText,

          outline: lightBorder,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: lightBg,
          foregroundColor: lightText,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: lightText,
          ),
        ),

        cardTheme: CardThemeData(
          color: lightCard,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: lightBorder),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF5D5E61),
          foregroundColor: Colors.white,
          elevation: 2,
        ),

        dividerTheme: const DividerThemeData(
          color: lightBorder,
          thickness: 1,
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: lightText, fontSize: 14),
          titleMedium: TextStyle(
            color: lightText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 🌙 DARK — Minimalista Cinza Premium
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,

        colorScheme: const ColorScheme.dark(
          primary: darkText,
          onPrimary: darkBg,

          secondary: Color(0xFF9A9A9D),
          onSecondary: Colors.black,

          surface: darkCard,
          onSurface: darkText,

          outline: darkBorder,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: darkBg,
          foregroundColor: darkText,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: darkText,
          ),
        ),

        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: darkBorder),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: darkText,
          foregroundColor: darkBg,
          elevation: 3,
        ),

        dividerTheme: const DividerThemeData(
          color: darkBorder,
          thickness: 1,
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: darkText, fontSize: 14),
          titleMedium: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      initialRoute: Routes.home,
      routes: Routes.routes,
    );
  }
}