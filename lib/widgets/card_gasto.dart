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

      // 🔥 BACKGROUND DE EXCLUSÃO
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: colors.onError),
      ),

      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Excluir gasto'),
            content: const Text('Deseja realmente excluir este gasto?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
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

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gasto excluído'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },

      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/add', arguments: gasto);
        },

        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // 🎨 CATEGORIA COM ÍCONE DINÂMICO
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: categoriaColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  // AQUI ESTÁ A CORREÇÃO:
                  IconData(categoria.iconCode, fontFamily: 'MaterialIcons'),
                  color: categoriaColor,
                  size: 22, // Aumentei levemente para destaque
                ),
              ),

              const SizedBox(width: 14),

              // 🧾 INFORMAÇÕES DO GASTO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      gasto.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
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

              const SizedBox(width: 10),

              // 💰 VALOR FORMATADO
              Text(
                "R\$ ${gasto.valor.toStringAsFixed(2).replaceAll('.', ',')}",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}