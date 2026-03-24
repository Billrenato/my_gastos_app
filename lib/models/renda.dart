import 'package:hive/hive.dart';

part 'renda.g.dart';

@HiveType(typeId: 2)
class Renda extends HiveObject {
  @HiveField(0)
  double valor;

  Renda({required this.valor});
}