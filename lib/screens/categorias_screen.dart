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
  
  // Ícone padrão (ex: help/interrogação)
  int _selectedIconCode = Icons.help_outline.codePoint;

  // Lista de ícones sugeridos para categorias de gastos
  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.fastfood,
    Icons.local_cafe,
    Icons.icecream,
    Icons.lunch_dining,

    // 🛒 Compras
    Icons.shopping_cart,
    Icons.shopping_bag,
    Icons.store,
    Icons.local_mall,

    // 🚗 Transporte
    Icons.directions_car,
    Icons.directions_bus,
    Icons.local_taxi,
    Icons.motorcycle,
    Icons.local_gas_station,

    // 🏠 Casa
    Icons.home,
    Icons.chair,
    Icons.bed,
    Icons.kitchen,

    // 💊 Saúde
    Icons.medical_services,
    Icons.local_hospital,
    Icons.medication,
    Icons.health_and_safety,
    Icons.monitor_heart,

    // ⚡ Contas
    Icons.bolt,
    Icons.water_drop,
    Icons.wifi,
    Icons.receipt_long,
    Icons.attach_money,

    // ✈️ Viagem
    Icons.airplane_ticket,
    Icons.flight,
    Icons.hotel,
    Icons.luggage,

    // 🏋️ Lazer / Fitness
    Icons.fitness_center,
    Icons.sports_soccer,
    Icons.sports_esports,
    Icons.movie,
    Icons.music_note,

    // 🎓 Educação
    Icons.school,
    Icons.menu_book,
    Icons.computer,
    Icons.edit,

    // 🎉 Eventos
    Icons.celebration,
    Icons.cake,
    Icons.card_giftcard,

    // 💰 Finanças
    Icons.payments,
    Icons.account_balance,
    Icons.credit_card,
    Icons.savings,
    Icons.trending_up,
    Icons.trending_down,

    // 🐶 Outros
    Icons.pets,
    Icons.child_care,
    Icons.work,
    Icons.star,
    Icons.category,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    _nameController.clear();
    _selectedColorValue = AppColors.availableColors.first.value;
    _selectedIconCode = Icons.category.codePoint;

    _showDialog(
      title: 'Nova Categoria',
      onSave: () async {
        if (_nameController.text.trim().isEmpty) return;

        final newCategory = Categoria(
          id: const Uuid().v4(),
          nome: _nameController.text.trim(),
          colorValue: _selectedColorValue,
          iconCode: _selectedIconCode, // Salvando o ícone
        );

        await ref.read(categoriaListProvider.notifier).addCategoria(newCategory);
      },
    );
  }

  void _showEditDialog(Categoria categoria) {
    _nameController.text = categoria.nome;
    _selectedColorValue = categoria.colorValue;
    _selectedIconCode = categoria.iconCode;

    _showDialog(
      title: 'Editar Categoria',
      onSave: () async {
        final updated = Categoria(
          id: categoria.id,
          nome: _nameController.text.trim(),
          colorValue: _selectedColorValue,
          iconCode: _selectedIconCode,
        );

        await ref.read(categoriaListProvider.notifier).updateCategoria(updated);
      },
    );
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome da Categoria',
                          prefixIcon: Icon(IconData(_selectedIconCode, fontFamily: 'MaterialIcons')),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Cor da Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AppColors.availableColors.map((color) {
                          final isSelected = color.value == _selectedColorValue;
                          return GestureDetector(
                            onTap: () => setStateSB(() => _selectedColorValue = color.value),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: color,
                              child: isSelected
                                  ? Icon(Icons.check, 
                                      size: 20, 
                                      color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark 
                                        ? Colors.white : Colors.black)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text('Ícone', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemCount: _availableIcons.length,
                          itemBuilder: (context, index) {
                            final icon = _availableIcons[index];
                            final isSelected = icon.codePoint == _selectedIconCode;
                            
                            // Cor que o usuário escolheu lá em cima no seletor de cores
                            final corEscolhida = Color(_selectedColorValue);

                            return IconButton(
                              onPressed: () => setStateSB(() => _selectedIconCode = icon.codePoint),
                              icon: Icon(icon),
                              // Se selecionado, usa a cor da categoria, senão usa um cinza neutro
                              color: isSelected ? corEscolhida : colorScheme.onSurfaceVariant,
                              style: IconButton.styleFrom(
                                // Se selecionado, cria um fundo suave com a cor da categoria
                                backgroundColor: isSelected ? corEscolhida.withOpacity(0.2) : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected ? corEscolhida : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Future<void> _deleteCategoria(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir'),
        content: const Text('Deseja realmente excluir esta categoria?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(categoriaListProvider.notifier).deleteCategoria(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriaListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: categoriasAsync.when(
        data: (categorias) {
          if (categorias.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 80, color: colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  const Text('Nenhuma categoria cadastrada', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: categorias.length,
            padding: const EdgeInsets.all(16),
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
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
        error: (e, st) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Categoria'),
      ),
    );
  }
}