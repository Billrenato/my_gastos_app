import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:my_gastos_app/providers/gasto_provider.dart';
import 'package:my_gastos_app/providers/categoria_provider.dart';
import 'package:my_gastos_app/widgets/card_gasto.dart';

class CalendarioScreen extends ConsumerStatefulWidget {
  const CalendarioScreen({super.key});

  @override
  ConsumerState<CalendarioScreen> createState() =>
      _CalendarioScreenState();
}

class _CalendarioScreenState
    extends ConsumerState<CalendarioScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected = DateTime.now(); // já inicia selecionado

  @override
  Widget build(BuildContext context) {
    final gastosAsync = ref.watch(gastoListProvider);
    final categoriasAsync = ref.watch(categoriaListProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário')),

      body: gastosAsync.when(
        data: (gastos) {
          return categoriasAsync.when(
            data: (categorias) {
              // 🔵 função para marcar dias com gasto
              List eventLoader(DateTime day) {
                return gastos
                    .where((g) => isSameDay(g.data, day))
                    .toList();
              }

              // 📋 gastos do dia selecionado
              final gastosDoDia = gastos
                  .where((g) => isSameDay(g.data, _selected))
                  .toList();

              // 💰 total do dia
              final total = gastosDoDia.fold(
                  0.0, (sum, g) => sum + g.valor);

              return Column(
                children: [
                  // 📅 CALENDÁRIO
                  TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focused,
                    selectedDayPredicate: (d) =>
                        isSameDay(d, _selected),

                    eventLoader: eventLoader,

                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selected = selectedDay;
                        _focused = focusedDay;
                      });
                    },

                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: colors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 💰 TOTAL DO DIA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _selected == null
                            ? "Selecione um dia"
                            : "Total do dia: R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 📋 LISTA
                  Expanded(
                    child: _selected == null
                        ? const Center(
                            child: Text('Selecione um dia'),
                          )
                        : gastosDoDia.isEmpty
                            ? const Center(
                                child:
                                    Text('Nenhum gasto neste dia'),
                              )
                            : ListView.builder(
                                itemCount: gastosDoDia.length,
                                itemBuilder: (context, index) {
                                  final gasto = gastosDoDia[index];

                                  final categoria =
                                      categorias.firstWhere(
                                    (c) =>
                                        c.id == gasto.categoriaId,
                                    orElse: () =>
                                        categorias.first,
                                  );

                                  return CardGasto(
                                    gasto: gasto,
                                    categoria: categoria,
                                  );
                                },
                              ),
                  ),
                ],
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('Erro: $e')),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}