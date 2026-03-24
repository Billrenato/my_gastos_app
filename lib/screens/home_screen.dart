import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gastos_app/widgets/circular_status.dart';
import 'package:my_gastos_app/widgets/card_gasto.dart';
import 'package:my_gastos_app/providers/gasto_provider.dart';
import 'package:my_gastos_app/providers/categoria_provider.dart';
import 'package:my_gastos_app/providers/theme_provider.dart';
import 'package:my_gastos_app/providers/month_provider.dart';
import 'package:my_gastos_app/providers/renda_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastosAsync = ref.watch(gastoListProvider);
    final categoriasAsync = ref.watch(categoriaListProvider);
    final colors = Theme.of(context).colorScheme;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final themeMode = ref.watch(themeProvider);
    final renda = ref.watch(rendaProvider);

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
                          themeMode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: colors.onPrimary,
                        ),
                        onPressed: () {
                          final nextMode =
                              themeMode == ThemeMode.dark
                                  ? ThemeMode.light
                                  : ThemeMode.dark;

                          ref
                              .read(themeProvider.notifier)
                              .setTheme(nextMode);
                        },
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.attach_money,
                                color: colors.onPrimary),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed('/renda');
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.settings,
                                color: colors.onPrimary),
                            onPressed: () => Navigator.of(context)
                                .pushNamed('/categories'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    'Resumo mensal',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onPrimary.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 🔵 GRÁFICO
                  const CircularStatus(),

                  const SizedBox(height: 10),

                  // 💰 BLOCO DE SALDO (NOVO)
                  gastosAsync.when(
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

                      final totalGastos = gastosFiltrados.fold(
                          0.0, (sum, g) => sum + g.valor);

                      final saldo = renda - totalGastos;

                      return Column(
                        children: [
                          Text(
                            'Saldo atual',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  colors.onPrimary.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "R\$ ${saldo.toStringAsFixed(2).replaceAll('.', ',')}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: saldo >= 0
                                  ? Color(0xFF4CAF50) // verde material padrão
                                  : Color(0xFFF44336), // vermelho material padrão
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),

                  const SizedBox(height: 10),

                  
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
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
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, st) =>
                        Center(child: Text('Erro: $e')),
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (e, st) =>
                    Center(child: Text('Erro: $e')),
              ),
            ),
          ],
        ),
      ),

      // 🔥 NAVBAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurfaceVariant,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Calendário'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Relatórios'),
        ],
        onTap: (i) {
          if (i == 1)
            Navigator.of(context).pushNamed('/calendar');
          if (i == 2)
            Navigator.of(context).pushNamed('/reports');
        },
      ),

      // 🔥 FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 4,
        onPressed: () =>
            Navigator.of(context).pushNamed('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}