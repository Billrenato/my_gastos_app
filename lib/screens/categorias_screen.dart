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

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    _nameController.clear();
    _selectedColorValue = AppColors.availableColors.first.value;
    
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Nova Categoria'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome da Categoria'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Cor:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: AppColors.availableColors.map((color) {
                      final isSelected = color.value == _selectedColorValue;
                      return GestureDetector(
                        onTap: () {
                          setStateSB(() {
                            _selectedColorValue = color.value;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: isSelected ? 16 : 12,
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.trim().isEmpty) return;

                    final newCategory = Categoria(
                      id: const Uuid().v4(),
                      nome: _nameController.text.trim(),
                      colorValue: _selectedColorValue,
                    );

                    await ref.read(categoriaListProvider.notifier).addCategoria(newCategory);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Adicionar'),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Categorias')),
      body: categoriasAsync.when(
        data: (categorias) {
          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (ctx, i) => CategoriaItem(categoria: categorias[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro ao carregar categorias: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}