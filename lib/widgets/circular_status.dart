import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_gastos_app/models/gasto.dart';
import 'package:my_gastos_app/models/categoria.dart';
import 'package:my_gastos_app/providers/gasto_provider.dart';
import 'package:my_gastos_app/providers/categoria_provider.dart';

class CircularStatus extends ConsumerWidget {
  const CircularStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastosAsync = ref.watch(gastoListProvider);
    final categoriasAsync = ref.watch(categoriaListProvider);

    return gastosAsync.when(
      data: (gastos) {
        return categoriasAsync.when(
          data: (categorias) {
            if (gastos.isEmpty) {
              return const Text("Sem gastos ainda");
            }

            final totalGeral = gastos.fold(0.0, (sum, g) => sum + g.valor);

            // Mapa de categoriaId -> soma do valor
            final Map<String, double> somaPorCategoria = {};
            for (var g in gastos) {
              somaPorCategoria[g.categoriaId] =
                  (somaPorCategoria[g.categoriaId] ?? 0) + g.valor;
            }

            final sections = somaPorCategoria.entries.map((entry) {
              final cat = categorias.firstWhere((c) => c.id == entry.key,
                  orElse: () => Categoria(
                      id: '0', nome: 'Outros', colorValue: Colors.grey.value));
              return PieChartSectionData(
                value: entry.value,
                color: Color(cat.colorValue),
                radius: 40,
                showTitle: false,
              );
            }).toList();

            return SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: sections,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "R\$ ${totalGeral.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Gastos totais",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text("Erro ao carregar categorias: $e"),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("Erro ao carregar gastos: $e"),
    );
  }
}
