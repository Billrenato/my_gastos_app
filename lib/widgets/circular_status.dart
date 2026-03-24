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
        // 🔥 SELETOR DE MÊS MELHORADO
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MonthButton(
                icon: Icons.chevron_left,
                onPressed: () => ref.read(selectedMonthProvider.notifier).state =
                    DateTime(selectedMonth.year, selectedMonth.month - 1),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.onPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${selectedMonth.month.toString().padLeft(2, '0')}/${selectedMonth.year}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimary,
                  ),
                ),
              ),
              _MonthButton(
                icon: Icons.chevron_right,
                onPressed: () => ref.read(selectedMonthProvider.notifier).state =
                    DateTime(selectedMonth.year, selectedMonth.month + 1),
              ),
            ],
          ),
        ),

        gastosAsync.when(
          data: (gastos) => categoriasAsync.when(
            data: (categorias) {
              final gastosFiltrados = gastos.where((g) {
                final isMesmoMes = g.data.month == selectedMonth.month &&
                    g.data.year == selectedMonth.year;

                final isRecorrente = g.recorrente &&
                    g.data.isBefore(
                        DateTime(selectedMonth.year, selectedMonth.month + 1));

                return isMesmoMes || isRecorrente;
              }).toList();

              if (gastosFiltrados.isEmpty) {
                return _EmptyState(colors: colors);
              }

              final total =
                  gastosFiltrados.fold(0.0, (sum, g) => sum + g.valor);

              final Map<String, double> mapa = {};
              for (var g in gastosFiltrados) {
                mapa[g.categoriaId] =
                    (mapa[g.categoriaId] ?? 0) + g.valor;
              }

              final entries = mapa.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              // 🔥 MELHORIAS VISUAIS AQUI
              final sections = entries.map((e) {
                final cat = categorias.firstWhere(
                  (c) => c.id == e.key,
                  orElse: () => categorias.first,
                );

                final baseColor = Color(cat.colorValue);

                return PieChartSectionData(
                  value: e.value,
                  color: baseColor,
                  gradient: LinearGradient(
                    colors: [
                      baseColor,
                      baseColor.withOpacity(0.7),
                    ],
                  ),
                  radius: 26, // mais moderno
                  showTitle: true,
                  title:
                      "${((e.value / total) * 100).toStringAsFixed(0)}%",
                  titleStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimary,
                  ),
                );
              }).toList();

              return Column(
                children: [
                  // 🔥 GRÁFICO MELHORADO
                  SizedBox(
                    height: 210,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sections: sections,
                            centerSpaceRadius: 70,
                            sectionsSpace: 4,
                            startDegreeOffset: -90,
                            borderData: FlBorderData(show: false),
                          ),
                          swapAnimationDuration:
                              const Duration(milliseconds: 500),
                          swapAnimationCurve: Curves.easeOut,
                        ),

                        _CenterLabel(total: total, colors: colors),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔥 BARRA MELHORADA
                  Container(
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.08),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: entries.map((e) {
                        final cat = categorias.firstWhere(
                          (c) => c.id == e.key,
                          orElse: () => categorias.first,
                        );

                        return Expanded(
                          flex: (e.value / total * 100)
                              .toInt()
                              .clamp(1, 100),
                          child:
                              Container(color: Color(cat.colorValue)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text("Erro: $e"),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text("Erro: $e"),
        )
      ],
    );
  }
}

// 🔘 BOTÃO
class _MonthButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MonthButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: colors.onPrimary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon, color: colors.onPrimary, size: 24),
    );
  }
}

// 🎯 CENTRO
class _CenterLabel extends StatelessWidget {
  final double total;
  final ColorScheme colors;

  const _CenterLabel({
    required this.total,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}",
          style: TextStyle(
            color: colors.onPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Total",
          style: TextStyle(
            color: colors.onPrimary.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// 🚫 EMPTY
class _EmptyState extends StatelessWidget {
  final ColorScheme colors;

  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline,
              size: 56,
              color: colors.onPrimary.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            "Nenhum gasto ainda",
            style: TextStyle(
              color: colors.onPrimary.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Adicione um gasto para começar",
            style: TextStyle(
              color: colors.onPrimary.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}