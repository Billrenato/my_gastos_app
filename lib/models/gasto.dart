import 'package:hive/hive.dart';
part 'gasto.g.dart'; // NECESSITA DE build_runner

@HiveType(typeId: 0)
class Gasto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String titulo;

  @HiveField(2)
  double valor;

  @HiveField(3)
  DateTime data;

  @HiveField(4)
  String categoriaId;

  @HiveField(5)
  bool recorrente;

  Gasto({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.data,
    required this.categoriaId,
    this.recorrente = false,
  });
}