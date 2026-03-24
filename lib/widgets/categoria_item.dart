import 'package:flutter/material.dart';
import 'package:my_gastos_app/models/categoria.dart';

class CategoriaItem extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoriaItem({
    super.key,
    required this.categoria,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(categoria.colorValue);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0, // Menos sombra para um look mais clean e moderno
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15), // Fundo suave baseado na cor da categoria
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            // AQUI ESTÁ A MUDANÇA PRINCIPAL:
            IconData(categoria.iconCode, fontFamily: 'MaterialIcons'),
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          categoria.nome,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Excluir',
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}