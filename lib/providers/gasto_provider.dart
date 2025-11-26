import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_gastos_app/models/gasto.dart';
import 'package:my_gastos_app/services/hive_service.dart';

final gastoListProvider = StateNotifierProvider<GastoNotifier, AsyncValue<List<Gasto>>>((ref) {
  return GastoNotifier();
});

class GastoNotifier extends StateNotifier<AsyncValue<List<Gasto>>> {
  GastoNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final box = HiveService.gastosBoxInstance();
      state = AsyncValue.data(box.values.toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addGasto(Gasto gasto) async {
    try {
      final box = HiveService.gastosBoxInstance();
      await box.put(gasto.id, gasto);
      state = AsyncValue.data(box.values.toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateGasto(Gasto gasto) async {
    try {
      final box = HiveService.gastosBoxInstance();
      await box.put(gasto.id, gasto);
      state = AsyncValue.data(box.values.toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeGasto(String id) async {
    try {
      final box = HiveService.gastosBoxInstance();
      await box.delete(id);
      state = AsyncValue.data(box.values.toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}