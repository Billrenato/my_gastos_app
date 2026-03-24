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

  Future<void> _deleteCategoria(String id) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir'),
        content: const Text('Deseja realmente excluir esta categoria?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: colorScheme.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(categoriaListProvider.notifier).deleteCategoria(id);
    }
  }

  void _showDialog({
    required String title,
    required Future<void> Function() onSave,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: Text(title, style: TextStyle(color: colorScheme.onSurface)),
              content: SingleChildScrollView( // Evita erro de overflow em telas menores
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Nome da Categoria',
                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Cor Selecionada:',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: AppColors.availableColors.map((color) {
                        final isSelected = color.value == _selectedColorValue;

                        return GestureDetector(
                          onTap: () {
                            setStateSB(() {
                              _selectedColorValue = color.value;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? colorScheme.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: color,
                              radius: 16,
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 18,
                                      // Logica para o check ser branco ou preto dependendo da cor de fundo
                                      color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark 
                                          ? Colors.white 
                                          : Colors.black87,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancelar', style: TextStyle(color: colorScheme.primary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    await onSave();
                    if (context.mounted) Navigator.pop(ctx);
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

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriaListProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
                style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: categorias.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e', style: TextStyle(color: colorScheme.error))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }
}