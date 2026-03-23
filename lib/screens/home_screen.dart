import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gastos_app/widgets/circular_status.dart';
import 'package:my_gastos_app/widgets/card_gasto.dart';
import 'package:my_gastos_app/providers/gasto_provider.dart';
import 'package:my_gastos_app/providers/categoria_provider.dart';
import 'package:my_gastos_app/providers/theme_provider.dart';
import 'package:my_gastos_app/providers/month_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastosAsync = ref.watch(gastoListProvider);
    final categoriasAsync = ref.watch(categoriaListProvider);
    final colors = Theme.of(context).colorScheme;
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔥 HEADER PREMIUM
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary,
                    colors.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 🔹 TOPO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.dark_mode,
                          color: colors.onPrimary,
                        ),
                        onPressed: () {
                          final current = ref.read(themeProvider);
                          ref.read(themeProvider.notifier).state =
                              current == ThemeMode.dark
                                  ? ThemeMode.light
                                  : ThemeMode.dark;
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: colors.onPrimary,
                        ),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/categories'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 🔵 GRÁFICO
                  const CircularStatus(),

                  const SizedBox(height: 16),

                  // 🔤 TEXTO
                  Text(
                    'Resumo mensal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 LISTA
            Expanded(
              child: categoriasAsync.when(
                data: (categorias) {
                  return gastosAsync.when(
                    data: (gastos) {
                      final gastosFiltrados = gastos.where((g) {
                        final isMesmoMes =
                            g.data.month == selectedMonth.month &&
                            g.data.year == selectedMonth.year;

                        final isRecorrente = g.recorrente &&
                            g.data.isBefore(
                              DateTime(
                                selectedMonth.year,
                                selectedMonth.month + 1,
                              ),
                            );

                        return isMesmoMes || isRecorrente;
                      }).toList();

                      if (gastosFiltrados.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhum gasto encontrado',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: gastosFiltrados.length,
                        itemBuilder: (context, index) {
                          final gasto = gastosFiltrados[index];

                          final categoria = categorias.firstWhere(
                            (c) => c.id == gasto.categoriaId,
                            orElse: () => categorias.first,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: CardGasto(
                              gasto: gasto,
                              categoria: categoria,
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Erro: $e')),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Erro: $e')),
              ),
            ),
          ],
        ),
      ),

      // 🔥 NAVBAR BONITA
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurfaceVariant,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendário'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: 'Relatórios'),
        ],
        onTap: (i) {
          if (i == 1) Navigator.of(context).pushNamed('/calendar');
          if (i == 2) Navigator.of(context).pushNamed('/reports');
        },
      ),

      // 🔥 FAB PREMIUM
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 4,
        onPressed: () => Navigator.of(context).pushNamed('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}