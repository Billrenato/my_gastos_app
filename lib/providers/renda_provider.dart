import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/renda.dart';

final rendaProvider =
    StateNotifierProvider<RendaNotifier, double>((ref) {
  return RendaNotifier();
});

class RendaNotifier extends StateNotifier<double> {
  RendaNotifier() : super(0) {
    load();
  }

  Future<void> load() async {
    final box = await Hive.openBox<Renda>('rendaBox');

    if (box.isNotEmpty) {
      state = box.getAt(0)!.valor;
    }
  }

  Future<void> setRenda(double valor) async {
    final box = await Hive.openBox<Renda>('rendaBox');

    await box.clear();
    await box.add(Renda(valor: valor));

    state = valor;
  }
}