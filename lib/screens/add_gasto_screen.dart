import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:my_gastos_app/models/gasto.dart';
import 'package:my_gastos_app/providers/gasto_provider.dart';
import 'package:my_gastos_app/providers/categoria_provider.dart';

class AddGastoScreen extends ConsumerStatefulWidget {
  const AddGastoScreen({super.key});

  @override
  ConsumerState<AddGastoScreen> createState() => _AddGastoScreenState();
}

class _AddGastoScreenState extends ConsumerState<AddGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();

  DateTime _data = DateTime.now();
  String? selectedCategoryId;
  bool isRecorrente = false;
  Gasto? gastoEditando;
  bool _isInitialized = false; // 🔥 CORREÇÃO 1: Impede resetar os dados ao reconstruir

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Só carrega os argumentos uma vez
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Gasto) {
        gastoEditando = args;
        _tituloCtrl.text = args.titulo;
        _valorCtrl.text = args.valor.toString();
        _data = args.data;
        selectedCategoryId = args.categoriaId;
        isRecorrente = args.recorrente;
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriaListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(gastoEditando == null ? 'Adicionar gasto' : 'Editar gasto'),
      ),
      body: categoriasAsync.when(
        data: (categories) {
          // 🔥 CORREÇÃO 2: Garante que o selectedCategoryId seja válido dentro das categorias existentes
          if (selectedCategoryId != null && !categories.any((c) => c.id == selectedCategoryId)) {
             // Se a categoria do gasto não existe mais, limpa ou reseta
             selectedCategoryId = null; 
          }

          return Form(
            key: _formKey,
            child: ListView( // Melhor que Column para evitar erro de overflow com teclado
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _tituloCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Preencha o título' : null,
                ),
                TextFormField(
                  controller: _valorCtrl,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final parsed = double.tryParse(v?.replaceAll(',', '.') ?? '');
                    if (parsed == null || parsed <= 0) return 'Valor inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  items: categories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.nome),
                  )).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedCategoryId = v; // Atualiza o estado local para o "Salvar" usar
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  validator: (v) => v == null ? 'Escolha uma categoria' : null,
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Data: ${_data.day}/${_data.month}/${_data.year}'),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _data,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _data = picked);
                      },
                      child: const Text('Selecionar'),
                    )
                  ],
                ),
                CheckboxListTile(
                  value: isRecorrente,
                  onChanged: (v) => setState(() => isRecorrente = v ?? false),
                  title: const Text('Recorrente (mensal)'),
                ),
                const SizedBox(height: 30),
                
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final value = double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0;

                    // 🔥 CORREÇÃO 3: Criar um NOVO objeto com os dados ATUALIZADOS da tela
                    final gastoParaSalvar = Gasto(
                      id: gastoEditando?.id ?? const Uuid().v4(),
                      titulo: _tituloCtrl.text,
                      valor: value,
                      data: _data,
                      categoriaId: selectedCategoryId!, // O valor vindo do setState
                      recorrente: isRecorrente,
                    );

                    if (gastoEditando != null) {
                      await ref.read(gastoListProvider.notifier).updateGasto(gastoParaSalvar);
                    } else {
                      await ref.read(gastoListProvider.notifier).addGasto(gastoParaSalvar);
                    }

                    if (mounted) Navigator.pop(context);
                  },
                  child: Text(gastoEditando == null ? 'Salvar' : 'Atualizar'),
                )
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}