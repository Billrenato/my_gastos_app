import 'package:hive/hive.dart';
part 'categoria.g.dart'; // NECESSITA DE build_runner

@HiveType(typeId: 1)
class Categoria extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  int colorValue;

  Categoria({required this.id, required this.nome, required this.colorValue});
}