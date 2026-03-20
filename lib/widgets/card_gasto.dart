import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gastos_app/models/gasto.dart';
import 'package:my_gastos_app/models/categoria.dart';
import 'package:my_gastos_app/providers/gasto_provider.dart';
import 'package:intl/intl.dart';

class CardGasto extends ConsumerWidget {
  final Gasto gasto;
  final Categoria categoria;

  const CardGasto({
    super.key,
    required this.gasto,
    required this.categoria,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final df = DateFormat('dd/MM');

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final categoriaColor = Color(categoria.colorValue);

    return Dismissible(
      key: Key(gasto.id),
      direction: DismissDirection.endToStart,

      // 🔥 BACKGROUND COM TEMA
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete,
          color: colors.onError,
        ),
      ),

      // 🔥 CONFIRMAÇÃO (PROFISSIONAL)
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir gasto'),
            content: const Text('Deseja realmente excluir este gasto?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
      },

      onDismissed: (_) async {
        await ref
            .read(gastoListProvider.notifier)
            .removeGasto(gasto.id);

        // 🔥 feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto excluído')),
        );
      },

      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/add', arguments: gasto);
        },

        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: colors.surface, // 🔥 TEMA
            borderRadius: BorderRadius.circular(16),

            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.1),
                blurRadius: 10,
              )
            ],
          ),

          child: Row(
            children: [
              // 🎨 CATEGORIA
              CircleAvatar(
                backgroundColor: categoriaColor.withOpacity(0.2),
                child: Icon(
                  Icons.label,
                  color: categoriaColor,
                ),
              ),

              const SizedBox(width: 12),

              // 🧾 INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gasto.titulo,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${df.format(gasto.data)} • ${categoria.nome}",
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // 💰 VALOR
              Text(
                "R\$ ${gasto.valor.toStringAsFixed(2)}",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}