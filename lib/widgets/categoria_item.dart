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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            Icons.label,
            color: color,
          ),
        ),
        title: Text(
          categoria.nome,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}