import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_gastos_app/providers/gasto_provider.dart';
import 'package:my_gastos_app/providers/categoria_provider.dart';

class RelatoriosScreen extends ConsumerWidget {
  const RelatoriosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastosAsync = ref.watch(gastoListProvider);
    final categoriasAsync = ref.watch(categoriaListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatórios"),
      ),
      body: categoriasAsync.when(
        data: (categorias) {
          return gastosAsync.when(
            data: (gastos) {
              final now = DateTime.now();

              // 🔥 últimos 6 meses
              final startDate = DateTime(now.year, now.month - 5, 1);
              final endDate = DateTime(now.year, now.month + 1, 0);

              final gastosFiltrados = gastos.where((g) {
                final isDentroDoPeriodo =
                    g.data.isAfter(startDate.subtract(const Duration(days: 1))) &&
                    g.data.isBefore(endDate.add(const Duration(days: 1)));

                final isRecorrente =
                    g.recorrente && g.data.isBefore(endDate);

                return isDentroDoPeriodo || isRecorrente;
              }).toList();

              if (gastosFiltrados.isEmpty) {
                return const Center(
                  child: Text("Sem dados nos últimos meses"),
                );
              }

              // 🔥 ordena (mais recente primeiro)
              gastosFiltrados.sort((a, b) => b.data.compareTo(a.data));

              // 🔥 agrupa por mês
              final Map<String, List<dynamic>> grouped = {};

              for (var g in gastosFiltrados) {
                final key = DateFormat('MM/yyyy').format(g.data);

                if (!grouped.containsKey(key)) {
                  grouped[key] = [];
                }

                grouped[key]!.add(g);
              }

              final months = grouped.keys.toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final monthKey = months[index];
                  final items = grouped[monthKey]!;

                  final date = DateTime.parse("$monthKey-01");
                  final formattedMonth =
                      DateFormat('MMMM yyyy', 'pt_BR').format(date);

                  // 🔥 total do mês
                  final totalMes = items.fold(
                      0.0, (sum, g) => sum + g.valor);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 HEADER DO MÊS
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formattedMonth.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "R\$ ${totalMes.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 🔹 LISTA DE GASTOS
                      ...items.map((g) {
                        final cat = categorias.firstWhere(
                          (c) => c.id == g.categoriaId,
                          orElse: () => categorias.first,
                        );

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 6,
                                backgroundColor: Color(cat.colorValue),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(g.descricao),
                              ),
                              Text(
                                "R\$ ${g.valor.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 12),
                    ],
                  );
                },
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Erro: $e")),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erro: $e")),
      ),
    );
  }
}