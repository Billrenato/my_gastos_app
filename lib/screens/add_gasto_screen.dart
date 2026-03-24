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
  bool _isInitialized = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(gastoEditando == null ? 'Adicionar gasto' : 'Editar gasto'),
      ),
      body: categoriasAsync.when(
        data: (categories) {
          if (selectedCategoryId != null && !categories.any((c) => c.id == selectedCategoryId)) {
            selectedCategoryId = null; 
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // CAMPO TÍTULO
                TextFormField(
                  controller: _tituloCtrl,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Título',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Preencha o título' : null,
                ),
                const SizedBox(height: 16),

                // CAMPO VALOR
                TextFormField(
                  controller: _valorCtrl,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixText: 'R\$ ',
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final parsed = double.tryParse(v?.replaceAll(',', '.') ?? '');
                    if (parsed == null || parsed <= 0) return 'Valor inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // DROPDOWN CATEGORIA
                DropdownButtonFormField<String>(
                  dropdownColor: colorScheme.surface,
                  value: selectedCategoryId,
                  style: TextStyle(color: colorScheme.onSurface),
                  items: categories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.nome),
                  )).toList(),
                  onChanged: (v) => setState(() => selectedCategoryId = v),
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null ? 'Escolha uma categoria' : null,
                ),

                const SizedBox(height: 16),

                // SELEÇÃO DE DATA
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Data: ${_data.day}/${_data.month}/${_data.year}',
                        style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _data,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _data = picked);
                        },
                        child: const Text('ALTERAR'),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // CHECKBOX RECORRENTE
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isRecorrente,
                  onChanged: (v) => setState(() => isRecorrente = v ?? false),
                  title: Text('Recorrente (mensal)', 
                    style: TextStyle(color: colorScheme.onSurface)),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: colorScheme.primary,
                ),

                const SizedBox(height: 32),
                
                // BOTÃO SALVAR (ESTILIZADO)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 56), // Botão largo e alto
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final value = double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0;

                    final gastoParaSalvar = Gasto(
                      id: gastoEditando?.id ?? const Uuid().v4(),
                      titulo: _tituloCtrl.text,
                      valor: value,
                      data: _data,
                      categoriaId: selectedCategoryId!,
                      recorrente: isRecorrente,
                    );

                    if (gastoEditando != null) {
                      await ref.read(gastoListProvider.notifier).updateGasto(gastoParaSalvar);
                    } else {
                      await ref.read(gastoListProvider.notifier).addGasto(gastoParaSalvar);
                    }

                    if (mounted) Navigator.pop(context);
                  },
                  child: Text(
                    gastoEditando == null ? 'SALVAR GASTO' : 'ATUALIZAR GASTO',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro: $e', style: TextStyle(color: colorScheme.error))),
      ),
    );
  }
}