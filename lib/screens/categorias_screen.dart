import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:my_gastos_app/models/categoria.dart';
import 'package:my_gastos_app/providers/categoria_provider.dart';
import 'package:my_gastos_app/widgets/categoria_item.dart';
import 'package:my_gastos_app/utils/app_colors.dart';

class CategoriasScreen extends ConsumerStatefulWidget {
  const CategoriasScreen({super.key});

  @override
  ConsumerState<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends ConsumerState<CategoriasScreen> {
  final _nameController = TextEditingController();
  int _selectedColorValue = AppColors.availableColors.first.value;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ========================
  // 🟢 ADICIONAR
  // ========================
  void _showAddDialog() {
    _nameController.clear();
    _selectedColorValue = AppColors.availableColors.first.value;

    _showDialog(
      title: 'Nova Categoria',
      onSave: () async {
        if (_nameController.text.trim().isEmpty) return;

        final newCategory = Categoria(
          id: const Uuid().v4(),
          nome: _nameController.text.trim(),
          colorValue: _selectedColorValue,
        );

        await ref
            .read(categoriaListProvider.notifier)
            .addCategoria(newCategory);
      },
    );
  }

  // ========================
  // ✏️ EDITAR
  // ========================
  void _showEditDialog(Categoria categoria) {
    _nameController.text = categoria.nome;
    _selectedColorValue = categoria.colorValue;

    _showDialog(
      title: 'Editar Categoria',
      onSave: () async {
        final updated = Categoria(
          id: categoria.id,
          nome: _nameController.text.trim(),
          colorValue: _selectedColorValue,
        );

        await ref
            .read(categoriaListProvider.notifier)
            .updateCategoria(updated);
      },
    );
  }

  // ========================
  // 🗑️ EXCLUIR
  // ========================
  Future<void> _deleteCategoria(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir'),
        content: const Text('Deseja realmente excluir esta categoria?'),
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

    if (confirm == true) {
      await ref
          .read(categoriaListProvider.notifier)
          .deleteCategoria(id);
    }
  }

  // ========================
  // 🔥 DIALOG PADRÃO
  // ========================
  void _showDialog({
    required String title,
    required Future<void> Function() onSave,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Categoria',
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Cor:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppColors.availableColors.map((color) {
                      final isSelected =
                          color.value == _selectedColorValue;

                      return GestureDetector(
                        onTap: () {
                          setStateSB(() {
                            _selectedColorValue = color.value;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: isSelected ? 18 : 14,
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await onSave();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ========================
  // UI
  // ========================
  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriaListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: categoriasAsync.when(
        data: (categorias) {
          if (categorias.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma categoria cadastrada',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (ctx, i) {
              final categoria = categorias[i];

              return CategoriaItem(
                categoria: categoria,
                onEdit: () => _showEditDialog(categoria),
                onDelete: () => _deleteCategoria(categoria.id),
              );
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}