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
        title: const Text("Análise de Gastos"),
        centerTitle: true,
      ),
      body: categoriasAsync.when(
        data: (categorias) => gastosAsync.when(
          data: (gastos) {
            final now = DateTime.now();
            final startDate = DateTime(now.year, now.month - 5, 1);
            final endDate = DateTime(now.year, now.month + 1, 0);

            final gastosFiltrados = gastos.where((g) {
              final isDentro = g.data.isAfter(startDate.subtract(const Duration(days: 1))) &&
                               g.data.isBefore(endDate.add(const Duration(days: 1)));
              return isDentro || (g.recorrente && g.data.isBefore(endDate));
            }).toList();

            if (gastosFiltrados.isEmpty) {
              return _buildEmptyState(colors);
            }

            // Agrupamento
            final Map<String, List<Gasto>> grouped = {};
            for (var g in gastosFiltrados) {
              final key = DateFormat('yyyy-MM').format(g.data);
              grouped.putIfAbsent(key, () => []).add(g);
            }

            final months = grouped.keys.toList()..sort((a, b) => a.compareTo(b));
            final categoriasMap = {for (var c in categorias) c.id: c};

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeaderStats(gastosFiltrados, colors),
                const SizedBox(height: 24),
                
                _buildSectionTitle("Tendência Mensal"),
                const SizedBox(height: 16),
                _buildLineChart(months, grouped, colors),
                
                const SizedBox(height: 32),
                _buildSectionTitle("Histórico Detalhado"),
                const SizedBox(height: 16),
                
                ...months.reversed.map((monthKey) => _buildMonthCard(
                  monthKey, 
                  grouped[monthKey]!, 
                  categoriasMap, 
                  colors
                )),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Erro: $e")),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erro: $e")),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
    );
  }

  Widget _buildHeaderStats(List<Gasto> gastos, ColorScheme colors) {
    final total = gastos.fold(0.0, (sum, g) => sum + g.valor);
    final media = total / 6;

    return Row(
      children: [
        _statCard("Total 6 meses", total, colors.primary, colors.onPrimary),
        const SizedBox(width: 12),
        _statCard("Média Mensal", media, colors.secondaryContainer, colors.onSecondaryContainer),
      ],
    );
  }

  Widget _statCard(String label, double value, Color bg, Color text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: text.withOpacity(0.8), fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              "R\$ ${value.toStringAsFixed(2)}",
              style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<String> months, Map<String, List<Gasto>> grouped, ColorScheme colors) {
    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 20, top: 10),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  if (val.toInt() >= months.length) return const Text("");
                  final date = DateFormat('yyyy-MM').parse(months[val.toInt()]);
                  return Text(DateFormat('MMM').format(date), style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: months.asMap().entries.map((e) {
                final total = grouped[e.value]!.fold(0.0, (sum, g) => sum + g.valor);
                return FlSpot(e.key.toDouble(), total);
              }).toList(),
              isCurved: true,
              color: colors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: colors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard(String monthKey, List<Gasto> items, Map<String, dynamic> catMap, ColorScheme colors) {
    final date = DateFormat('yyyy-MM').parse(monthKey);
    final totalMes = items.fold(0.0, (sum, g) => sum + g.valor);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(
          DateFormat('MMMM yyyy').format(date).toUpperCase(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          "R\$ ${totalMes.toStringAsFixed(2)}",
          style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: items.map((g) {
                final cat = catMap[g.categoriaId];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.circle, size: 12, color: Color(cat?.colorValue ?? 0xFF888888)),
                  title: Text(g.titulo),
                  subtitle: Text(DateFormat('dd/MM').format(g.data)),
                  trailing: Text("R\$ ${g.valor.toStringAsFixed(2)}",
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: colors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text("Sem dados suficientes para gerar relatórios"),
        ],
      ),
    );
  }
}