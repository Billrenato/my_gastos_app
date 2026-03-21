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

      themeMode: themeMode, // 🔥 AGORA FUNCIONA

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF18181B), // 🔥 preto/cinza
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA), // 🔥 mais clean
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE5E7EB), // 🔥 branco suave
          brightness: Brightness.dark,
          surface: const Color(0xFF18181B), // 🔥 card mais bonito
        ),
        scaffoldBackgroundColor: const Color(0xFF09090B), // 🔥 preto premium
        useMaterial3: true,
      ),

      initialRoute: Routes.home,
      routes: Routes.routes,
    );
  }
}