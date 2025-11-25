import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_gastos_app/models/gasto.dart';
import 'package:my_gastos_app/models/categoria.dart';

class HiveService {
  static const String gastosBox = 'gastos_box';
  static const String categoriasBox = 'categorias_box';

  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Registrar adapters (verifique os IDs)
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(GastoAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoriaAdapter());

    await Hive.openBox<Gasto>(gastosBox);
    await Hive.openBox<Categoria>(categoriasBox);
  }

  static Box<Gasto> gastosBoxInstance() => Hive.box<Gasto>(gastosBox);
  static Box<Categoria> categoriasBoxInstance() => Hive.box<Categoria>(categoriasBox);
}