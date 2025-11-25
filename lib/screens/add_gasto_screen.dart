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

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriaListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: categoriasAsync.when(
          data: (categories) => Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _tituloCtrl, 
                  decoration: const InputDecoration(labelText: 'Título'), 
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Preencha o título' : null
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
                  items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nome))).toList(),
                  value: selectedCategoryId,
                  onChanged: (v) => setState(() => selectedCategoryId = v),
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  validator: (v) => v == null || v.isEmpty ? 'Escolha uma categoria' : null,
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
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final value = double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0;
                    final gasto = Gasto(
                      id: const Uuid().v4(),
                      titulo: _tituloCtrl.text.trim(),
                      valor: value,
                      data: _data,
                      categoriaId: selectedCategoryId ?? '',
                      recorrente: isRecorrente,
                    );
                    await ref.read(gastoListProvider.notifier).addGasto(gasto);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Salvar'),
                )
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Erro: $e')),
        ),
      ),
    );
  }
}