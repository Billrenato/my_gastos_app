import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:my_gastos_app/providers/gasto_provider.dart';
import 'package:my_gastos_app/providers/categoria_provider.dart';
import 'package:my_gastos_app/models/gasto.dart';

class RelatoriosScreen extends ConsumerWidget {
  const RelatoriosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastosAsync = ref.watch(gastoListProvider);
    final categoriasAsync = ref.watch(categoriaListProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatórios"),
        centerTitle: true,
      ),
      body: categoriasAsync.when(
        data: (categorias) {
          return gastosAsync.when(
            data: (gastos) {
              final now = DateTime.now();

              // Define intervalo de 6 meses
              final startDate = DateTime(now.year, now.month - 5, 1);
              final endDate = DateTime(now.year, now.month + 1, 0);

              final gastosFiltrados = gastos.where((g) {
                final isDentroDoPeriodo =
                    g.data.isAfter(startDate.subtract(const Duration(days: 1))) &&
                    g.data.isBefore(endDate.add(const Duration(days: 1)));

                final isRecorrente = g.recorrente && g.data.isBefore(endDate);
                return isDentroDoPeriodo || isRecorrente;
              }).toList();

              if (gastosFiltrados.isEmpty) {
                return const Center(child: Text("Sem dados nos últimos meses"));
              }

              // Ordenar para o gráfico de linha (crescente)
              gastosFiltrados.sort((a, b) => a.data.compareTo(b.data));

              final categoriasMap = {for (var c in categorias) c.id: c};

              // Agrupar por mês
              final Map<String, List<Gasto>> grouped = {};
              for (var g in gastosFiltrados) {
                final key = DateFormat('yyyy-MM').format(g.data);
                grouped.putIfAbsent(key, () => []);
                grouped[key]!.add(g);
              }

              final months = grouped.keys.toList()..sort((a, b) => a.compareTo(b));
              const mesesNomes = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];

              // Dados do gráfico de linha (topo)
              final spots = <FlSpot>[];
              for (int i = 0; i < months.length; i++) {
                final total = grouped[months[i]]!.fold(0.0, (sum, g) => sum + g.valor);
                spots.add(FlSpot(i.toDouble(), total));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // --- GRÁFICO GERAL DE TENDÊNCIA ---
                  const Text("Tendência de Gastos (6 meses)", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 150,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 4,
                            color: colors.primary,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: colors.primary.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Divider(height: 40),

                  // --- LINHA DO TEMPO COM BARRAS ---
                  ...months.reversed.map((monthKey) {
                    final items = grouped[monthKey]!;
                    final parts = monthKey.split('-');
                    final monthIdx = int.parse(parts[1]) - 1;
                    final totalMes = items.fold(0.0, (sum, g) => sum + g.valor);

                    // Agrupar categorias do mês para o gráfico de barras
                    final Map<String, double> catData = {};
                    for (var item in items) {
                      catData[item.categoriaId] = (catData[item.categoriaId] ?? 0) + item.valor;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${mesesNomes[monthIdx]} ${parts[0]}", 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Total: R\$ ${totalMes.toStringAsFixed(2)}",
                              style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        
                        // Gráfico de Barras do Mês
                        SizedBox(
                          height: 100,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.start,
                              maxY: catData.values.isEmpty ? 10 : catData.values.reduce((a, b) => a > b ? a : b) * 1.1,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: const FlTitlesData(show: false),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: catData.entries.toList().asMap().entries.map((entry) {
                                final cat = categoriasMap[entry.value.key];
                                return BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.value,
                                      color: Color(cat?.colorValue ?? 0xFF888888),
                                      width: 18,
                                      borderRadius: BorderRadius.circular(4),
                                    )
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Lista de itens do mês
                        ...items.map((g) {
                          final cat = categoriasMap[g.categoriaId];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 5,
                              backgroundColor: Color(cat?.colorValue ?? 0xFF888888),
                            ),
                            title: Text(g.titulo, style: const TextStyle(fontSize: 14)),
                            subtitle: Text(DateFormat('dd/MM').format(g.data)),
                            trailing: Text("R\$ ${g.valor.toStringAsFixed(2)}", 
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          );
                        }),
                        const SizedBox(height: 30),
                      ],
                    );
                  }),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Erro: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erro: $e")),
      ),
    );
  }
}