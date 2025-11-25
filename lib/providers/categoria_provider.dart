import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:my_gastos_app/models/categoria.dart';
import 'package:my_gastos_app/services/hive_service.dart';
import 'package:flutter/material.dart';

final categoriaListProvider = StateNotifierProvider<CategoriaNotifier, AsyncValue<List<Categoria>>>((ref) {
  return CategoriaNotifier();
});

class CategoriaNotifier extends StateNotifier<AsyncValue<List<Categoria>>> {
  CategoriaNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final box = HiveService.categoriasBoxInstance();
      var list = box.values.toList();
      if (list.isEmpty) {
        // categorias iniciais
        final c1 = Categoria(id: const Uuid().v4(), nome: 'Alimentação', colorValue: const Color(0xFF4CAF50).value);
        final c2 = Categoria(id: const Uuid().v4(), nome: 'Transporte', colorValue: const Color(0xFFFF9800).value);
        final c3 = Categoria(id: const Uuid().v4(), nome: 'Assinaturas', colorValue: const Color(0xFF2196F3).value);
        await box.put(c1.id, c1);
        await box.put(c2.id, c2);
        await box.put(c3.id, c3);
        list = box.values.toList();
      }
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategoria(Categoria c) async {
    try {
      final box = HiveService.categoriasBoxInstance();
      await box.put(c.id, c);
      // Recarregar a lista após adicionar
      state = AsyncValue.data(box.values.toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}