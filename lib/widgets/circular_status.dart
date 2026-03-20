import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_gastos_app/providers/gasto_provider.dart';
import 'package:my_gastos_app/providers/categoria_provider.dart';
import 'package:my_gastos_app/providers/month_provider.dart';

class CircularStatus extends ConsumerWidget {
  const CircularStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastosAsync = ref.watch(gastoListProvider);
    final categoriasAsync = ref.watch(categoriaListProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 🔥 SELETOR DE MÊS
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                ref.read(selectedMonthProvider.notifier).state =
                    DateTime(selectedMonth.year, selectedMonth.month - 1);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            Text(
              "${selectedMonth.month.toString().padLeft(2, '0')}/${selectedMonth.year}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                ref.read(selectedMonthProvider.notifier).state =
                    DateTime(selectedMonth.year, selectedMonth.month + 1);
              },
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),

        gastosAsync.when(
          data: (gastos) {
            return categoriasAsync.when(
              data: (categorias) {
                // 🔥 FILTRO POR MÊS
                final gastosFiltrados = gastos.where((g) {
                  final isMesmoMes =
                      g.data.month == selectedMonth.month &&
                      g.data.year == selectedMonth.year;

                  final isRecorrente = g.recorrente &&
                      g.data.isBefore(DateTime(selectedMonth.year, selectedMonth.month + 1));

                  return isMesmoMes || isRecorrente;
                }).toList();

                if (gastosFiltrados.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: const [
                        Icon(Icons.pie_chart_outline,
                            size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Sem gastos neste mês"),
                      ],
                    ),
                  );
                }

                final total =
                    gastosFiltrados.fold(0.0, (sum, g) => sum + g.valor);

                final Map<String, double> mapa = {};

                for (var g in gastosFiltrados) {
                  mapa[g.categoriaId] =
                      (mapa[g.categoriaId] ?? 0) + g.valor;
                }

                // 🔥 ORDENA (melhora visual)
                final entries = mapa.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                final sections = entries.map((e) {
                  final cat = categorias.firstWhere(
                    (c) => c.id == e.key,
                    orElse: () => categorias.first,
                  );

                  final percent =
                      total == 0 ? 0 : (e.value / total) * 100;

                  return PieChartSectionData(
                    value: e.value,
                    color: Color(cat.colorValue),
                    radius: 35,
                    title: "${percent.toStringAsFixed(0)}%",
                    titleStyle: TextStyle(
                      fontSize: 10,
                      color: colors.onPrimary,
                    ),
                  );
                }).toList();

                return Column(
                  children: [
                    // 🔵 GRÁFICO DE PIZZA
                    SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: sections,
                              centerSpaceRadius: 60,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "R\$ ${total.toStringAsFixed(2)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                "Total",
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🟩 BARRA PROPORCIONAL
                    Container(
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: entries.map((e) {
                          final cat = categorias.firstWhere(
                            (c) => c.id == e.key,
                            orElse: () => categorias.first,
                          );

                          final percent =
                              total == 0 ? 0 : (e.value / total);

                          final isFirst = entries.first == e;
                          final isLast = entries.last == e;

                          return Expanded(
                            flex: ((percent * 100).toInt())
                                .clamp(1, 100), // 🔥 CORREÇÃO BUG
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(cat.colorValue),
                                borderRadius: BorderRadius.only(
                                  topLeft: isFirst
                                      ? const Radius.circular(6)
                                      : Radius.zero,
                                  bottomLeft: isFirst
                                      ? const Radius.circular(6)
                                      : Radius.zero,
                                  topRight: isLast
                                      ? const Radius.circular(6)
                                      : Radius.zero,
                                  bottomRight: isLast
                                      ? const Radius.circular(6)
                                      : Radius.zero,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
              loading: () =>
                  const CircularProgressIndicator(),
              error: (e, _) => Text("Erro: $e"),
            );
          },
          loading: () =>
              const CircularProgressIndicator(),
          error: (e, _) => Text("Erro: $e"),
        )
      ],
    );
  }
}