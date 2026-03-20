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
          seedColor: const Color(0xFF3D59A1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F2F6),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7AA2F7),
          brightness: Brightness.dark,
          surface: const Color(0xFF1A1B26),
        ),
        scaffoldBackgroundColor: const Color(0xFF16161E),
        useMaterial3: true,
      ),

      initialRoute: Routes.home,
      routes: Routes.routes,
    );
  }
}