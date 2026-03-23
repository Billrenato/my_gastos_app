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

      // 🌞 LIGHT THEME (branco gelo moderno)
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFFFAFAFA), // ❄️ branco gelo

        colorScheme: const ColorScheme(
          brightness: Brightness.light,

          primary: Color(0xFFE5E7EB), // ❄️ cinza gelo MUITO leve
          onPrimary: Color(0xFF18181B),

          secondary: Color(0xFFF1F5F9), // ❄️ quase branco
          onSecondary: Color(0xFF18181B),

          background: Color(0xFFFAFAFA),
          onBackground: Color(0xFF18181B),

          surface: Color(0xFFFFFFFF), // cards brancos
          onSurface: Color(0xFF18181B),

          onSurfaceVariant: Color(0xFF71717A), // texto secundário leve

          error: Colors.red,
          onError: Colors.white,
        ),

        cardColor: Colors.white,

        dividerColor: const Color(0xFFF1F5F9), // ❄️ quase invisível

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF18181B),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFE5E7EB), // ❄️ botão gelo
          foregroundColor: Color(0xFF18181B),
        ),
      ),

      // 🌙 DARK THEME (preto premium)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFF09090B),

        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF27272A),
          onPrimary: Colors.white,

          secondary: Color(0xFF3F3F46),
          onSecondary: Colors.white,

          background: Color(0xFF09090B),
          onBackground: Colors.white,

          surface: Color(0xFF18181B),

          onSurface: Color(0xFFF4F4F5),        // 🔥 MAIS FORTE
          onSurfaceVariant: Color(0xFFD4D4D8), // 🔥 RESOLVE O CINZA APAGADO

          error: Colors.red,
          onError: Colors.white,
        ),

        cardColor: const Color(0xFF18181B),
        dividerColor: const Color(0xFF27272A),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF27272A),
          foregroundColor: Colors.white,
        ),
      ),

      initialRoute: Routes.home,
      routes: Routes.routes,
    );
  }
}