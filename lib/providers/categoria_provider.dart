import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:my_gastos_app/models/categoria.dart';
import 'package:my_gastos_app/services/hive_service.dart';
import 'package:flutter/material.dart';

final categoriaListProvider =
    StateNotifierProvider<CategoriaNotifier, AsyncValue<List<Categoria>>>((ref) {
  return CategoriaNotifier();
});

class CategoriaNotifier
    extends StateNotifier<AsyncValue<List<Categoria>>> {
  CategoriaNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  // ========================
  // 🔄 LOAD INICIAL
  // ========================
  Future<void> _load() async {
    try {
      final box = HiveService.categoriasBoxInstance();
      var list = box.values.toList();

      if (list.isEmpty) {
        final categoriasIniciais = [
          Categoria(
            id: const Uuid().v4(),
            nome: 'Alimentação',
            colorValue: const Color(0xFF22C55E).value,
          ),
          Categoria(
            id: const Uuid().v4(),
            nome: 'Transporte',
            colorValue: const Color(0xFF3B82F6).value,
          ),
          Categoria(
            id: const Uuid().v4(),
            nome: 'Assinaturas',
            colorValue: const Color(0xFF8B5CF6).value,
          ),
        ];

        for (var c in categoriasIniciais) {
          await box.put(c.id, c);
        }

        list = box.values.toList();
      }

      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ========================
  // ➕ ADICIONAR
  // ========================
  Future<void> addCategoria(Categoria c) async {
    try {
      final box = HiveService.categoriasBoxInstance();
      await box.put(c.id, c);

      state = AsyncValue.data(box.values.toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ========================
  // ✏️ EDITAR
  // ========================
  Future<void> updateCategoria(Categoria c) async {
    try {
      final box = HiveService.categoriasBoxInstance();

      if (!box.containsKey(c.id)) return;

      await box.put(c.id, c);

      state = AsyncValue.data(box.values.toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ========================
  // 🗑️ EXCLUIR
  // ========================
  Future<void> deleteCategoria(String id) async {
    try {
      final box = HiveService.categoriasBoxInstance();

      await box.delete(id);

      state = AsyncValue.data(box.values.toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}